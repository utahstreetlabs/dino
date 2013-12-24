require 'spec_helper'
require 'dino/model'

describe Dino::Model do
  class Nug
    include Dino::Model
  end

  it 'is instantiable' do
    expect { Nug.new }.to_not raise_error
  end
end
