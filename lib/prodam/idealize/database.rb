class Prodam::Idealize::Database
  class << self
    attr_reader :uri

    def load_config(file, env = :development)
      @config = Prodam::Idealize::Configuration.load_file(file)
      @uri = @config[env][:uri]
    end

    def connection
      @connection ||= Sequel.connect @uri, prefetch_rows: 50
    end

    def [](dataset)
      @connection[dataset]
    end
  end
end
