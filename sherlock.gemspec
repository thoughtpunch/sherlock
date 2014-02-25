# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sherlock/version'

Gem::Specification.new do |gem|
  gem.name          = "sherlock"
  gem.version       = Sherlock::VERSION
  gem.authors       = ["Dan Barrett"]
  gem.email         = ["dbarrett83@gmail.com"]
  gem.description   = %q{Sherlock: The URL Detective}
  gem.summary       = %q{Sherlock will extract just about any information from a given HTTP URL}
  gem.homepage      = "http://mauled.by.bears"

  gem.files += Dir.glob("lib/**/*.rb")
  gem.files += Dir.glob("spec/**/*")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  #DEPENDENCIES
  # NOTE: version lock these ASAP
  gem.add_dependency 'domainatrix'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'ruby-readability'
  gem.add_dependency 'faraday', '0.8.9'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'typhoeus'
  gem.add_dependency 'json'
  gem.add_dependency 'hashie'
  gem.add_dependency "rspec"
end