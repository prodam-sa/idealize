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
    # Base
    autoload :Configuration, 'prodam/idealize/configuration'
    autoload :Database, 'prodam/idealize/database'
    autoload :Application, 'prodam/idealize/application'

    # Models
    autoload :Usuario, 'models/usuario'

    def self.initialize(env = :development)
      Database.load_config('config/database.yml', env)
      Application.load_config('config/application.yml', env)
    end
  end
end
