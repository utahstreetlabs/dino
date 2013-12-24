require 'rspec/core'
require 'rspec/matchers'

module Dino
  module Test
    module Matchers
      RSpec::Matchers.define :be_json do
        match do |response|
          response.content_type =~ /^application\/json/
        end
        failure_message_for_should do |response|
          "Response should have application/json content type"
        end
        failure_message_for_should_not do |response|
          "Response should not have application/json content type"
        end
      end
    end
  end
end
