# encoding: utf-8

class Prodam::Idealize::Configuration #:nodoc:
  def self.load_file(file)
    YAML.load_file(file)
  end
end
