# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

tasks = File.expand_path('../tasks', __FILE__)
$LOAD_PATH.unshift(tasks) unless $LOAD_PATH.include?(tasks)

require 'device/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "da_funk"
  spec.version       = Device::API_VERSION
  spec.authors       = ["Thiago Scalone"]
  spec.email         = ["thiago@cloudwalk.io"]
  spec.summary       = "MRuby Embedded System Framework"
  spec.description   = "DaFunk is a Embedded System Framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration."
  spec.homepage      = "http://github.com/cloudwalkio/da_funk"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0") << "out/da_funk.mrb"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency "rake", "~> 10.4"
  spec.add_dependency "bundler", "~> 1.7"
  spec.add_dependency "yard", "~> 0.8"
  spec.add_dependency "cloudwalk_handshake", "~> 0.5"
  spec.add_dependency "posxml_parser", "~> 0.6"
end
