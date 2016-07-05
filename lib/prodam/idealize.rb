# encoding: utf-8

ENV['NLS_LANG'] = 'AMERICAN_AMERICA.UTF8'
ENV['NLS_SORT'] = 'BINARY_AI'
ENV['NLS_COMP'] = 'LINGUISTIC'
DEFAULT_OCI8_ENCODING = 'utf-8'

require 'date'
require 'pathname'
require 'yaml'
require 'sequel'
require 'json'
require 'prodam/idealize/version'

class String
  def camelcase
    gsub('/', ' :: ').
    gsub(/([a-z]+)_([a-z]+)/,'\1 \2').
    split(' ').map(&:capitalize).join
  end

  def underscore
    gsub(/::/, '/').
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
        load_yaml(:config, file)
      end

      def load_data(file)
        load_yaml(:db, file)
      end

      def application_config
        @application_config ||= load_config(:application)
      end

      def database_config
        @database_config ||= load_config(:database)
      end

      def routing(routing = controllers)
        @routes ||= routing.each_with_object({}) do |(id, controller), routers|
          controller[:routes] && routers.merge(routing(controller[:routes]))
          routers[controller[:url_path]] = const_get controller[:const_name]
        end
        @routes
      end

      def controllers(routing = application_config[:routes], prefix_path = '')
        @controllers ||= routing.each_with_object({}) do |(path, data), controller|
          id = data[:controller].underscore.to_sym
          data[:require_path] = format('%s/%s', :controllers, id)
          data[:url_path] = prefix_path + path
          data[:const_name] = data[:controller].to_sym
          data[:routes] = data[:routes] && controllers(data[:routes], data[:url_path])
          controller[id] = data
        end
        @controllers
      end

      def sections(sections = nil)
        (sections || application_config[:pages]).each_with_object({}) do |(path, data), page|
          id = path.gsub('/','').underscore.to_sym
          data[:url_path] = path
          page[id] = data
        end
      end
      alias pages sections

      def sources_from(*pathnames)
        pathnames.each_with_object({}) do |pathname, sources|
          Dir[root_directory.join('app').join(pathname.to_s).join('*.rb')].each do |source|
            id = File.basename(source.gsub(/.*\/#{pathname}/, ''), '.rb')
            sources[id.to_sym] = {
              require_path: "#{pathname}/#{id}",
              const_name: id.camelcase.to_sym
            }
          end
        end
      end

    private

      def load_yaml(prefix, file)
        YAML.load_file(root_directory.join(prefix.to_s, "#{file}.yml"))
      end
    end

  class Database
    # Sequel::Inflections.clear

    Sequel.inflections do |inflect|
      inflect.irregular 'coautor', 'coautores'
      inflect.irregular 'apoiador', 'apoiadores'
      inflect.irregular 'modificacao', 'modificacoes'
      inflect.irregular 'criterio_multiplo', 'criterios_multiplos'
    end

    class << self
      attr_reader :options

      def connection(env = Idealize.environment)
        @options = Idealize.database_config[env.to_sym]
        @options[:prefetch_rows] = 50
        if @options[:debug]
          require 'logger'
          @options[:loggers] = [Logger.new($stdout)]
        end
        @connection ||= Sequel.connect @options
      end

      def [](dataset)
        connection[dataset]
      end
    end
  end # Database

  module Model
    def self.[](dataset_name)
      klass = Sequel::Model(Database[dataset_name])
      klass.dataset = klass.dataset.sequence("s_#{dataset_name}".to_sym)
      klass
    end

    def param_name
      id || ''
    end

    def to_url_param(prefix = nil)
      [prefix, param_name].compact.join('/')
    end
  end # Model

  # Controllers
  autoload :ApplicationController, 'controllers/application_controller'

  def self.autoload_controllers(controllers = self.controllers)
    controllers.each do |id, controller|
      autoload controller[:const_name], controller[:require_path]
      controller[:routes] && autoload_controllers(controller[:routes])
    end
  end

  def self.autoload_sources
    sources_from(:models, :helpers).each do |id, source|
      autoload source[:const_name], source[:require_path]
    end
  end

  autoload_controllers
  autoload_sources
end

end # Prodam::idealize
