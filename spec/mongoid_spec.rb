require 'spec_helper'
require 'dino/base'
require 'dino/mongoid'
require 'rack/test'

class TestMongoidApp < Dino::Base
  include Dino::MongoidApp
  include Mocha::API

  put '/400' do
    do_put do
      raise Mongoid::Errors::Validations.new(stub('document', errors: stub('errors', full_messages: ['Bad request'])))
    end
  end

  put '/404' do
    do_put do
      raise Mongoid::Errors::DocumentNotFound.new(Class, [1])
    end
  end
end

describe Dino::Base do
  include Rack::Test::Methods

  def app
    TestMongoidApp
  end

  context "#load_mongoid" do
    let(:config_file) { 'mongoid.yml' }

    before do
      Mongoid.expects(:load!).with(config_file)
      app.load_mongoid(config_file)
    end

    it "disallows dynamic fields" do
      Mongoid.allow_dynamic_fields.should be_false
    end
  end

  context "Mongoid::Errors::Validations" do
    before { put '/400' }

    it "returns status 400" do
      last_response.status.should == 400
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Bad request/
    end
  end

  context "Mongoid::Errors::DocumentNotFound" do
    before { put '/404' }

    it "returns status 404" do
      last_response.status.should == 404
    end

    it "returns error message in entity" do
      last_response.body.should =~ /not found/
    end
  end
end
