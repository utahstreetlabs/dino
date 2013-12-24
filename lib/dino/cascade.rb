module Dino
  # Inspired by +Rack::Cascade+, this app passes requests through a chain of sub-apps. If a sub-app signals that it
  # cannot handle a particular request by setting the +X-Cascade+ response header to +true+, the request is passed to
  # the next app in the chain. If no app in the chain can handle the request, a 404 response is returned. All apps that
  # attempted to handle the request are named in the +X-Cascade-Apps+ response header.
  class Cascade
    attr_reader :apps

    def initialize(*args)
      raise "Must provide at least one app" if args.empty?
      puts "HERE I AM IN INITIALIZE"
      @apps = args
    end

    def call(env)
      cascaded_apps = []
      result = nil

      apps.each do |app|
        cascaded_apps << app
        result = app.call(env)
        break unless result[1]['X-Cascade'] == 'pass'
      end

      result[1].delete('X-Cascade')
      result[1]['X-Cascade-Apps'] = cascaded_apps.join(', ') if cascaded_apps.any?

      result
    end
  end
end
