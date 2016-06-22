# encoding: utf-8

require 'sinatra/json'

module Prodam::Idealize

class UsuariosController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:usuarios_controller]
  end

  get '/' do
    message.update(level: :information, text: 'Página de usuários em desenvolvimento')
    redirect path_to :home
  end

  get '/pesquisa.json' do
    content_type :json
    @termo = params[:termo] || 'a'
    @usuarios = Usuario.search(@termo).select(:id, :nome_usuario, :nome, :email).all.map(&:to_hash)
    hash = { status: 'ok', data: @usuarios }
    response.body = json hash
    response
  end

  get '/:id' do |id|
    message.update(level: :information, text: 'Página de usuários em desenvolvimento')
    redirect path_to :home
  end
end

end # module
