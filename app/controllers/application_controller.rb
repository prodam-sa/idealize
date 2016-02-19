# encoding: utf-8

require 'sinatra/base'

class Prodam::Idealize::ApplicationController < Sinatra::Base
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
