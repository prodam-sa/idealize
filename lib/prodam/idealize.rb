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
  end
end
