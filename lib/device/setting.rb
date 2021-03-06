
class Device
  class Setting
    FILE_PATH       = "./main/config.dat"
    HOST_PRODUCTION = "switch.cloudwalk.io"
    HOST_STAGING    = "switch-staging.cloudwalk.io"
    PORT_TCP        = "31415"
    PORT_TCP_SSL    = "31416"

    DEFAULT     = {
      "host"                        => HOST_PRODUCTION,
      "host_port"                   => PORT_TCP_SSL,
      "ssl"                         => "1",
      "user"                        => "",
      "password"                    => "", #WIFI
      "apn"                         => "",
      "sim_pin"                     => "",
      "sim_slot"                    => "0",
      "sim_dual"                    => "0",
      "authentication"              => "", #WIFI
      "essid"                       => "", #WIFI
      "bssid"                       => "", #WIFI
      "cipher"                      => "", #WIFI
      "mode"                        => "", #WIFI
      "channel"                     => "", #WIFI
      "media"                       => "",
      "ip"                          => "",
      "gateway"                     => "",
      "dns1"                        => "",
      "dns2"                        => "",
      "subnet"                      => "",
      "phone"                       => "",
      "modem_speed"                 => "",
      "logical_number"              => "",
      "network_configured"          => "",
      "touchscreen"                 => "",
      "environment"                 => "",
      "attach_gprs_timeout"         => "",
      "attach_tries"                => "",
      "notification_socket_timeout" => "", # Period to create fiber
      "notification_timeout"        => "", # Time to wait message to read
      "notification_interval"       => "", # Check interval
      "notification_stream_timeout" => "", # Time to wait stream message to read
      "cw_switch_version"           => "",
      "cw_pos_timezone"             => "",
      "tcp_recv_timeout"            => "14",
      "iso8583_recv_tries"          => "0",
      "iso8583_send_tries"          => "0",
      "crypto_dukpt_slot"           => "",
      "ctls"                        => "",
      "locale"                      => "en",
      "company_name"                => ""
    }

    def self.setup
      @file = FileDb.new(FILE_PATH, DEFAULT)
      self.check_environment!
      @file
    end

    def self.check_environment!
      if self.staging?
        self.to_staging!
      else
        self.to_production!
      end
    end

    def self.production?
      self.environment == "production"
    end

    def self.staging?
      self.environment == "staging"
    end

    def self.to_production!
      if self.environment != "production"
        @file.update_attributes("company_name" => "", "environment" => "production", "host" => HOST_PRODUCTION)
        return true
      end
      false
    end

    def self.to_staging!
      if self.environment != "staging"
        @file.update_attributes("company_name" => "", "environment" => "staging", "host" => HOST_STAGING)
        return true
      end
      false
    end

    def self.update_attributes(*args)
      @file.update_attributes(*args)
    end

    def self.method_missing(method, *args, &block)
      setup unless @file
      param = method.to_s
      if @file[param]
        @file[param]
      elsif (param[-1..-1] == "=" && @file[param[0..-2]])
        @file[param[0..-2]] = args.first
      else
        super
      end
    end
  end
end

