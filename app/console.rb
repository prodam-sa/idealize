# unicode: utf-8

require 'prodam/idealize'

env = ENV['RACK_ENV'] || :development

Prodam::Idealize.initialize env
