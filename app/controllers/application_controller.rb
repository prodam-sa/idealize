# encoding: utf-8

require 'sinatra/base'

class Prodam::Idealize::ApplicationController < Sinatra::Base
  set :public_folder, 'public'
  set :views, 'app/views'
  set :authenticate do |required|
    condition do
      redirect to('/'), 303 if required && !authenticated?
    end
  end
  set :authorize do |required|
    condition do
      redirect to('/'), 303 if required && !authorized?
    end
  end
  enable :method_override
  enable :sessions

  helpers Prodam::Idealize::AuthenticationHelper
  helpers Prodam::Idealize::ViewHelper
  helpers Prodam::Idealize::UrlHelper

  before do
    @page = { title: 'Caixa de Ideias' }
  end
end
