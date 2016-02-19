# encoding: utf-8

require 'sinatra/base'

class Prodam::Idealize::Application < Sinatra::Base
  class << self
    def load_config(file, env = :development)
      @config = Prodam::Idealize::Configuration.load_file(file)
    end

    def routes
      controllers.each_with_object({}) do |(id, controller), routes|
        routes[controller[:url_path]] = Prodam::Idealize.const_get controller[:const_name]
      end
    end

    def controllers
      @controllers ||= config[:application][:routes].each_with_object({}) do |(path, data), controller|
        id = data[:controller].underscore.to_sym
        data[:require_path] = format('%s/%s', :controllers, id)
        data[:url_path] = path
        data[:const_name] = data[:controller].to_sym
        controller[id] = data
      end
    end
  end

  set :public_folder, 'public'
  set :views, 'app/views'
  set :auth do |*any|
    condition do
      redirect to('/'), 303 unless authenticated?
    end
  end
  enable :method_override
  enable :sessions
end
