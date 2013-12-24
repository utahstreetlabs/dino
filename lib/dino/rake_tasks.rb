require 'active_support/inflector'
require 'mongoid'
require 'rake'
require 'rake/tasklib'

module Dino
  class RakeTasks < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def initialize(name)
      $: << File.join(Dir.pwd, 'lib')
      require "#{name}/models"

      if test_like?
        require 'rspec/core/rake_task'
        RSpec::Core::RakeTask.new(:spec)
        task :default => :spec
      end

      namespace :mongo do
        task :create_indexes do
          ENV['RACK_ENV'] ||= 'development'
          mongoid_config = File.expand_path(File.join(Dir.pwd, 'config', 'mongoid.yml'))
          Mongoid.load!(mongoid_config)
          get_mongoid_models.each { |m| m.create_indexes }
        end
      end

      namespace name do
        desc "Start the server"
        task :start do
          start_server
        end

        namespace :test do
          desc "Start the test server"
          task :start do
            ENV['RACK_ENV'] = 'test'
            start_server(true)
          end

          desc "Stop the test server"
          task :stop do
            ENV['RACK_ENV'] = 'test'
            stop_server
          end
        end
      end
    end

    def rack_env
      ENV['RACK_ENV'] || 'development'
    end

    def test_like?
      [:test, :development].include?(rack_env.to_sym)
    end

    def get_mongoid_models
      documents = []
      Dir.glob("lib/*/models/*.rb").sort.each do |file|
        model_path = file[0..-4].split('/')[-1]
        begin
          klass = model_path.camelize.constantize
          if klass.ancestors.include?(Mongoid::Document) && !klass.embedded
            documents << klass
          end
        rescue => e
          # Just for non-mongoid objects that dont have the embedded
          # attribute at the class level.
        end
      end
      documents
    end

    def pid_file
      File.expand_path(File.join('tmp', 'pids', "unicorn-#{rack_env}.pid"))
    end

    def start_server(daemonize = false)
      if File.exists?(pid_file)
        puts "Pid file #{pid_file} found - server is running"
      else
        args = "-c config/unicorn.rb -E #{rack_env}"
        args += ' -D' if daemonize
        `bin/unicorn #{args}`
      end
    end

    def stop_server
      if File.exists?(pid_file)
        Process.kill 'QUIT', File.open(pid_file).read.to_i
      else
        puts "Pid file #{pid_file} does not exist - is the server running?"
      end
    end
  end
end
