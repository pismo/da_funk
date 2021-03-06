
class FileDb
  attr_accessor :path, :hash

  def initialize(path, default_value = {})
    @hash = default_value.dup
    @path = path
    self.open
  end

  def open
    if File.exist?(@path)
      file = File.open(@path)
      self.parse(file.read)
    end
  ensure
    file.close if file
  end

  def parse(text)
    text.split("\n").compact.each do |line|
      key_value = line.split("=", 2)
      key, value = sanitize(key_value[0]), sanitize(key_value[1])
      @hash[key] = value unless value.empty?
    end
  end

  def each(&block)
    @hash.each(&block)
  end

  def save
    file_new = File.open(@path, "w+")
    @hash.each do |line_key, line_value|
      file_new.puts("#{line_key}=#{line_value}")
    end
    true
  rescue
    false
  ensure
    file_new.close
  end

  def []=(key, value)
    value = value.to_s
    old = @hash[key.to_s]
    ret = @hash[key.to_s] = value
    save if old != value
    ret
  end

  def [](key)
    @hash[key]
  end

  def update_attributes(values = Hash.new)
    values.each do |key, value|
      @hash[key.to_s] = value.to_s
    end
    save
  end

  private
  def sanitize(string)
    new_string = string.to_s.strip
    if new_string[0] == "\"" && new_string[-1] == "\""
      new_string = new_string[1..-2]
    end
    new_string
  end
end

