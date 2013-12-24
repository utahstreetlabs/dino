require 'spec_helper'
require 'dino/base'
require 'rack/test'
require 'yajl'

class TestApp < Dino::Base
  set :show_exceptions, false

  get '/songs/:id' do
    do_get do
      {id: params[:id], title: 'The Rover'}
    end
  end

  post '/songs' do
    do_post do |attrs|
      attrs
    end
  end

  put '/songs/:id' do
    do_put do |attrs|
      attrs
    end
  end

  delete '/songs/:id' do
    do_delete do
    end
  end

  put '/400' do
    raise Dino::BadRequest, 'Bad request'
  end

  put '/403' do
    raise Dino::Forbidden, 'Forbidden'
  end

  put '/404' do
    raise Dino::NotFound, 'Not found'
  end

  put '/409' do
    raise Dino::Conflict, 'Conflict'
  end

  put '/422' do
    raise Dino::UnprocessableEntity, 'Unprocessable entity'
  end
end

describe Dino::Base do
  include Rack::Test::Methods

  def app
    TestApp
  end

  context "#do_get" do
    before { get '/songs/3' }

    it "returns status 200" do
      last_response.status.should == 200
    end

    it "returns the song" do
      last_response.body.should =~ /The Rover/
    end
  end

  context "#do_post" do
    before { post '/songs', Yajl::Encoder.encode({title: 'Achilles Last Stand'}) }

    it "returns status 201" do
      last_response.status.should == 201
    end

    it "returns the song" do
      last_response.body.should =~ /Achilles Last Stand/
    end
  end

  context "#do_put" do
    before { put '/songs/1', Yajl::Encoder.encode({awesome: 'yes'}) }

    it "returns status 200" do
      last_response.status.should == 200
    end

    it "returns the song" do
      last_response.body.should =~ /yes/
    end
  end

  context "#do_delete" do
    before { delete '/songs/23' }

    it "returns status 204" do
      last_response.status.should == 204
    end

    it "returns no entity" do
      last_response.body.should == ''
    end
  end

  context "BadRequest" do
    before { put '/400' }

    it "returns status 400" do
      last_response.status.should == 400
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Bad request/
    end
  end

  context "Forbidden" do
    before { put '/403' }

    it "returns status 403" do
      last_response.status.should == 403
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Forbidden/
    end
  end

  context "NotFound" do
    before { put '/404' }

    it "returns status 404" do
      last_response.status.should == 404
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Not found/
    end
  end

  context "Conflict" do
    before { put '/409' }

    it "returns status 409" do
      last_response.status.should == 409
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Conflict/
    end
  end

  context "UnprocessableEntity" do
    before { put '/422' }

    it "returns status 422" do
      last_response.status.should == 422
    end

    it "returns error message in entity" do
      last_response.body.should =~ /Unprocessable entity/
    end
  end
end
