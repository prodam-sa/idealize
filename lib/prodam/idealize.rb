# encoding: utf-8

require 'date'
require 'pathname'
require 'yaml'
require 'sequel'
require 'json'
require 'prodam/idealize/version'

module Prodam
  module Idealize
    # Base
    autoload :Configuration, 'prodam/idealize/configuration'
    autoload :Database, 'prodam/idealize/database'

    def self.initialize(env = :development)
      Database.load_config('config/database.yml', env)
      Application.load_config('config/application.yml', env)
    end
  end
end
