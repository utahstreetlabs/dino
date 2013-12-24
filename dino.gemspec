# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dino/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'dino'
  s.version = Dino::VERSION.dup
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.authors = ['Brian Moseley']
  s.description = 'An HTTP service framework based on Sinatra'
  s.email = ['bcm@copious.com']
  s.homepage = 'http://github.com/utahstreetlabs/dino'
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options = ['--charset=UTF-8']
  s.summary = "A framework for building HTTP services using Sinatra"
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files -- lib/*`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('gemfury')
  s.add_runtime_dependency('activemodel', ['~> 3.2.1'])
  s.add_runtime_dependency('sinatra', ["~> 1.3.2"])
  s.add_runtime_dependency('mongoid', ['~> 2.4.3'])
  s.add_runtime_dependency('bson_ext')
  s.add_runtime_dependency('yajl-ruby')
  s.add_runtime_dependency('kaminari', ['~> 0.13.0'])
  s.add_runtime_dependency('log_weasel', '~> 0.1.0')
end
