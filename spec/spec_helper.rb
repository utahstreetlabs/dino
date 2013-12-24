require 'rubygems'
require 'bundler'

Bundler.setup

require 'rspec'
require 'mocha'
require 'dino'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.mock_with :mocha
end

Dino.logger = Logger.new('/dev/null')
