
class Device
  API_VERSION="0.4.13"

  def self.api_version
    Device::API_VERSION
  end

  def self.version
    adapter.version
  end
end

