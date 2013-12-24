require 'yajl'
require 'rack/test'

module Dino
  module Test
    module Response
      def json
        obj = Yajl::Parser.parse(body)
        obj.symbolize_keys! if obj.is_a?(Hash)
        obj
      end
    end
  end
end

Rack::MockResponse.send :include, Dino::Test::Response

# Remove this stuff once patch support gets merged into rack-test -
# there's an outstanding patch [har] but it needs sinatra 1.3 to be
# released
module Rack
  module Test
    class Session
      def patch(uri, params = {}, env = {}, &block)
        env = env_for(uri, env.merge(:method => "PATCH", :params => params))
        process_request(uri, env, &block)
      end
    end
  end
end

module Rack
  module Test
    module Methods
      def_delegators :current_session, :patch
    end
  end
end
