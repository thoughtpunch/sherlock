# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sherlock/version'

Gem::Specification.new do |gem|
  gem.name          = "sherlock"
  gem.version       = Sherlock::VERSION
  gem.authors       = ["Dan Barrett"]
  gem.email         = ["dbarrett83@gmail.com"]
  gem.description   = %q{Sherlock: The URI Detective}
  gem.summary       = %q{Sherlock will extract just about any information from a given URI}
  gem.homepage      = "http://mauled.by.bears"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  #DEPENDENCIES
  # NOTE: version lock these ASAP
  gem.add_development_dependency 'domainatrix'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'ruby-readability'
  gem.add_development_dependency 'faraday'
  gem.add_development_dependency 'faraday_middleware'
  gem.add_development_dependency 'typhoeus'
  gem.add_development_dependency 'uri'
  gem.add_development_dependency 'json'
  gem.add_development_dependency "rspec"
end
