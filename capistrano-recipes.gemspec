# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-recipes/version'

Gem::Specification.new do |spec|
  spec.name          = "j-cap-recipes"
  spec.version       = Capistrano::Recipes::VERSION
  spec.authors       = ["Michael Nikitochkin"]
  spec.email         = ["miry.sof@gmail.com"]
  spec.description   = %q{}
  spec.summary       = %q{Capistrano 3 recipes for nginx, monit, rails log, setup, unicorn}
  spec.homepage      = "https://github.com/jetthoughts/capistrano-recipes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "capistrano", '>= 3.0.0'
end
