# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ais_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "ais_tools"
  spec.version       = AisTools::VERSION
  spec.authors       = ["Sergey Gridasov"]
  spec.email         = ["grindars@gmail.com"]
  spec.description   = %q{Compiler and decompiler for TI AIS bootloader scripts.}
  spec.summary       = %q{Compiler and decompiler for TI AIS bootloader scripts.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency 'trollop'
  spec.add_dependency 'serialport'
end
