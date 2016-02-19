# encoding: utf-8

require 'date'
require 'pathname'
require 'yaml'
require 'sequel'
require 'json'
require 'prodam/idealize/version'

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Prodam
  module Idealize

    class << self
      def root_directory
        @root_directory ||= Pathname.new(File.expand_path("#{File.basename(__FILE__)}/.."))
      end

      def environment
        (ENV['RACK_ENV'].nil? ? :development : ENV['RACK_ENV']).to_sym
      end

      def load_config(file)
        YAML.load_file(root_directory.join('config').join("#{file}.yml"))
      end

      def application_config
        @application_config ||= load_config(:application)
      end

      def database_config
        @database_config ||= load_config(:database)
      end

      def routes
        controllers.each_with_object({}) do |(id, controller), routes|
          routes[controller[:url_path]] = Prodam::Idealize.const_get controller[:const_name]
        end
      end

      def controllers
        @controllers ||= application_config[:routes].each_with_object({}) do |(path, data), controller|
          id = data[:controller].underscore.to_sym
          data[:require_path] = format('%s/%s', :controllers, id)
          data[:url_path] = path
          data[:const_name] = data[:controller].to_sym
          controller[id] = data
        end
      end
    end

    class Prodam::Idealize::Database
      class << self
        attr_reader :uri
        attr_reader :options

        def connection(env = Prodam::Idealize.environment)
          @uri = Prodam::Idealize.database_config[env.to_sym][:uri]
          @options = { prefetch_rows: 50 }
          if env == :development
            require 'logger'
            @options[:loggers] = [Logger.new($stdout)]
          end
          @connection ||= Sequel.connect @uri, @options
        end

        def [](dataset)
          connection[dataset]
        end
      end
    end

    class Prodam::Idealize::Model
      def self.[](dataset)
        Sequel::Model(Database[dataset])
      end
    end

    # Models
    autoload :Usuario, 'models/usuario'

    # Controllers
    autoload :Application, 'controllers/application_controller'

    controllers.each do |id, controller|
      autoload controller[:const_name], controller[:require_path]
    end
  end
end
