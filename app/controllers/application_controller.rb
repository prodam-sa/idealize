# encoding: utf-8

require 'sinatra/base'

class Prodam::Idealize::ApplicationController < Sinatra::Base
  set :public_folder, 'public'
  set :views, 'app/views'
  set :authenticate do |required|
    condition do
      if required && !authenticated?
        message.update level: :warning, text: "Você precisa estar autenticado."
        redirect path_to(:conta, :acessar), 303
      end
    end
  end
  set :authorize do |action|
    condition do
      unless authorized?
        message.update level: :warning, text: "Você não possui permissão para #{action}."
        redirect path_to(:home), 303
      else
        pass
      end
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
