
class Device
  class Notification
    DEFAULT_TIMEOUT           = 20
    DEFAULT_INTERVAL          = 10
    DEFAULT_STREAM_TIMEOUT    = 0
    DEFAULT_CREATION_INTERVAL = 3600

    class << self
      attr_accessor :callbacks, :current, :last_creation, :creation_interval
    end

    self.callbacks = Hash.new
    self.creation_interval = DEFAULT_CREATION_INTERVAL

    attr_reader :fiber, :timeout, :interval, :last_check, :stream_timeout

    def self.check
      self.current.check if self.current
    end

    def self.execute(event)
      calls = self.callbacks[event.callback]
      return unless calls
      [:before, :on, :after].each do |moment|
        calls.each{|callback| callback.call(event, moment)}
      end
    end

    def self.schedule(callback)
      self.callbacks[callback.description] ||= []
      self.callbacks[callback.description] << callback
    end

    def self.config
      self.creation_interval      = Device::Setting.notification_socket_timeout.empty? DEFAULT_CREATION_INTERVAL : Device::Setting.notification_socket_timeout.to_i
      notification_timeout        = Device::Setting.notification_timeout.empty? ? DEFAULT_TIMEOUT : Device::Setting.notification_timeout.to_i
      notification_interval       = Device::Setting.notification_interval.empty? ? DEFAULT_INTERVAL : Device::Setting.notification_interval.to_i
      notification_stream_timeout = Device::Setting.notification_stream_timeout.empty? ? DEFAULT_STREAM_TIMEOUT : Device::Setting.notification_stream_timeout.to_i
      [notification_timeout, notification_interval, notification_stream_timeout]
    end

    def self.start
      if create_fiber? && Device::Network.connected?
        unless Device::Notification.current && Device::Notification.current.closed?
          self.new(*self.config)
        end
      end
    end

    def self.setup
      NotificationCallback.new "APP_UPDATE", :on => Proc.new { Device::ParamsDat.update_apps(true) }
      NotificationCallback.new "SETUP_DEVICE_CONFIG", :on => Proc.new { Device::ParamsDat.update_apps(true) }
      NotificationCallback.new "RESET_DEVICE_CONFIG", :on => Proc.new { Device::ParamsDat.format! }

      NotificationCallback.new "SYSTEM_UPDATE", :on => Proc.new { |file| }
      NotificationCallback.new "CANCEL_SYSTEM_UPDATE", :on => Proc.new { }
      NotificationCallback.new "TIMEZONE_UPDATE", :on => Proc.new { Device::Setting.cw_pos_timezone = "" }
      NotificationCallback.new "SHOW_MESSAGE", :on => Proc.new { |message, datetime|
        Device::Display.clear
        date = datetime.sub(" ", "-").split("-")
        Device::Display.print_line("#{date[1]}/#{date[0]}/#{date[2]} #{date[3]}", 0)
        Device::Display.print_line("#{message}", 2)
        getc(0)
      }
    end

    def self.create_fiber?
      (! Device::Setting.company_name.empty?) && (! Device::Setting.logical_number.empty?) && self.valid_creation_interval?
    end

    def self.valid_creation_interval?
      if @last_creation
        (@last_creation + self.creation_interval) < Time.now
      else
        true
      end
    end

    def initialize(timeout = DEFAULT_TIMEOUT, interval = DEFAULT_INTERVAL, stream_timeout = DEFAULT_STREAM_TIMEOUT)
      @timeout        = timeout
      @stream_timeout = stream_timeout
      @interval       = interval
      Device::Notification.current = self
      @fiber = create_fiber
    end

    # Check if there is any notification
    def check
      if valid_check_interval? && Device::Network.connected?
        if @fiber.alive?
          if (notification = @fiber.resume)
            Notification.execute(NotificationEvent.new(notification))
          end
          @last_check = Time.now
          if Device::Notification.create_fiber?
            self.close
            @fiber = create_fiber
          end
        end
      end
    end

    # Close socket and finish Fiber execution
    def close
      if closed?
        true
      else
        ! @fiber.resume "close"
      end
    end

    def closed?
      ! @fiber.alive?
    end

    def valid_check_interval?
      if @last_check
        (@last_check + self.interval) < Time.now
      else
        true
      end
    end

    private
    def reply(conn, ev)
      if ev.is_a?(Hash)
        if ev["Event"] == "user" && ev["Payload"] && ev["Payload"].include?("Id")
          index = ev["Payload"].index("\"Id")
          id = ev["Payload"][(index+7)..(index+38)]
          conn.event(event_name, "{\"Id\"=>\"#{id}\"}", false)
        end
      end
    end

    def check_errors(exception)
      case exception.message
      when "Invalid authentication token"
        Device::Setting.cw_pos_timezone = "" # Clear timezone if authentication error
      when "Socket closed"
      else
      end
      false
    end

    def create_fiber
      Fiber.new do
        begin
          Serfx.connect(socket_block: Device::Network.socket, timeout: timeout, stream_timeout: stream_timeout) do |conn|
            conn.auth(CloudwalkTOTP.at)
            Device::Notification.last_creation = Time.now
            conn.stream(subscription) { |ev| reply(conn, ev) }
          end
          true
        rescue Serfx::RPCError => exception
          check_errors(exception)
        end
      end
    end

    def subscription
      "user:#{event_name}"
    end

    def event_name
      "#{Device::Setting.company_name};#{Device::Setting.logical_number}"
    end
  end
end

