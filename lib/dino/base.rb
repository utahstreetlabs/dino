require 'active_support/core_ext/class/attribute_accessors'
require 'sinatra/base'
require 'yajl'
require 'dino'
require 'dino/benchmark'
require 'dino/exceptions'
require 'kaminari/models/array_extension'

module Dino
  class Base < Sinatra::Base
    include Dino::Benchmark

    cattr_accessor :logger, instance_writer: false
    @@logger = Dino.logger

    # turn off all built-in error handling so that our error handlers work
    set :raise_errors, Proc.new { false }
    set :show_exceptions, false

    def do_get(&block)
      receive(with_entity: false) do
        # XXX: caching
        rv = yield
        rv.is_a?(Array) && !rv.is_a?(Kaminari::PaginatableArray) ? rv : [200, {}, rv]
      end
    end

    def do_post(&block)
      receive do |request_entity|
        # XXX: Content-Location
        rv = yield(request_entity)
        rv.is_a?(Array) ? rv : [201, {}, rv]
      end
    end

    def do_put(&block)
      receive do |request_entity|
        # XXX: Content-Location
        rv = yield(request_entity)
        rv.is_a?(Array) ? rv : [200, {}, rv]
      end
    end

    def do_delete(&block)
      receive(with_entity: false) do
        rv = yield
        rv.is_a?(Array) ? rv : [204, {}, nil]
      end
    end

    def do_patch(&block)
      receive do |request_entity|
        rv = yield(request_entity)
        rv.is_a?(Array) ? rv : [200, {}, rv]
      end
    end

    error BadRequest do
      respond_to_error(400)
    end

    error Forbidden do
      respond_to_error(403)
    end

    error NotFound do
      respond_to_error(404)
    end

    error Conflict do
      respond_to_error(409)
    end

    error UnprocessableEntity do
      respond_to_error(422)
    end

    error do
      respond_to_error(500)
    end

    # Override Sinatra's default behavior to return a 404 with a JSON response and the +X-Cascade+ response header
    # set to +pass+. If the app is part of a +Dino::Cascade+ app chain, this will forward the request to the next
    # app in the chain.
    def route_missing
      respond_to_error(404, {errors: 'Route missing'}, 'X-Cascade' => 'pass')
    end

    def parse_datetime_param(key, options = {})
      if params[key].blank?
        options.fetch(:required, false) and
          raise Dino::BadRequest.new("#{key} param required")
        return nil
      end
      timestamp = begin
        Integer(params[key])
      rescue ArgumentError
        raise Dino::BadRequest.new("#{key} param must have unix timestamp value")
      end
      Time.at(timestamp).utc
    end

    def receive(options = {}, &block)
      if request.content_length.to_i > 0 && options.fetch(:with_entity, true)
        request_entity = decode_entity(request.body)
      end
      (status, headers, response_entity) = benchmark "Compute response" do
         yield(request_entity)
      end
      respond(status, headers, response_entity)
    end

    def decode_entity(entity)
      logger.debug "Beginning request entity parse"
      benchmark("Parse request entity") do
        Yajl::Parser.parse(entity)
      end
    end

    def respond(status, headers = {}, entity = nil)
      if status != 204 and entity
        if entity.respond_to?(:total_count)
          entity = {total: entity.total_count, results: entity, params: params}
        end
        data = OutputStream.new(entity)
      end
      headers.merge!('Content-Type' => 'application/json; charset=UTF-8')
      [status, headers, data]
    end

    def respond_to_error(status, entity = nil, headers = {})
      unless entity
        entity = {}
        if env.include?('sinatra.error')
          exception = env['sinatra.error'].is_a?(Exception) ? env['sinatra.error'] : Exception.new(env['sinatra.error'])
          entity[:errors] = exception.message
          logger.error("#{exception.message}\n#{exception.backtrace.join("\n")}")
        end
      end
      respond(status, headers, entity)
    end

    def logger
      Dino.logger
    end

    def self.logger
      Dino.logger
    end
  end

  class OutputStream
    def initialize(entity)
      @encoder = Yajl::Encoder
      @entity = entity
    end

    def each
      @encoder.encode(@entity) { |chunk| yield(chunk) }
    end
  end
end
