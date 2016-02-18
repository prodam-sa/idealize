# encoding: utf-8

class Prodam::Idealize::Database
  class << self
    attr_reader :uri
    attr_reader :options

    def load_config(file, env = :development)
      @config = Prodam::Idealize::Configuration.load_file(file)
      @uri = @config[env.to_sym][:uri]
      @options = { prefetch_rows: 50 }
      if env == :development
        require 'logger'
        @options[:loggers] = [Logger.new($stdout)]
      end
    end

    def connection
      @connection ||= Sequel.connect @uri, @options
    end

    def [](dataset)
      connection[dataset]
    end
  end
end
