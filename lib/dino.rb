require 'dino/version'

require 'active_support/core_ext/module/attribute_accessors'
require 'securerandom' # required by log_weasel
require 'log_weasel'

require 'mongoid'
require 'kaminari'

module Dino
  mattr_accessor :logger, instance_writer: false
  @@logger = LogWeasel::BufferedLogger.new($stdout)
end
