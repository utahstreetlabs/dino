require 'mongoid'

module Dino
  module MongoidApp
    def self.included(base)
      base.extend(ClassMethods)
    end

    # XXX: I don't understand why I can't just set up sinatra error handlers. they seem to be totally ignored.
    def receive(*args, &block)
      begin
        super(*args, &block)
      rescue Mongoid::Errors::Validations => e
        # XXX: I also don't understand why I can't just raise BadRequest and have that Dino::Base error handlers
        # catch it.
        respond_to_error(400, {:errors => e.message})
#        raise BadRequest, e.message
      rescue Mongoid::Errors::DocumentNotFound => e
        respond_to_error(404, {:errors => e.message})
#        raise NotFound
      end
    end

    module ClassMethods
      def load_mongoid(config_file)
        Mongoid.allow_dynamic_fields = false
        Mongoid.logger = Dino.logger
        Mongoid.load!(config_file)
        Dino.logger.info("Connecting to MongoDB at #{Mongoid.database.name}") unless test?
      end
    end
  end
end
