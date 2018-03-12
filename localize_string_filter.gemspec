# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localize_string_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "localize_string_filter"
  spec.version       = LocalizeStringFilter::VERSION
  spec.authors       = ["HongliYu"]
  spec.email         = ["yhlssdone@gmail.com"]

  spec.summary       = %q{Remove keys which never referenced by project in Localizable.strings.}
  spec.description   = %q{Remove keys which never referenced by project in Localizable.strings.}
  spec.homepage      = "https://github.com/HongliYu/localize_string_filter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = "localize_string_filter"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0.0'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
end
