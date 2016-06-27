# encoding: utf-8

require 'sinatra/json'

module Prodam::Idealize

class UsuariosController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:usuarios_controller]
  end

  before '/:id/?:action?' do |id, action|
    @usuario = Usuario[id.to_i]
  end

  get '/' do
    message.update(level: :information, text: 'Página de usuários em desenvolvimento')
    redirect path_to :home
  end

  get '/novo' do
    @usuario = Usuario.new
    view 'usuarios/form', layout: :signin
  end

  post '/' do
    @usuario = Usuario.new(params[:usuario]).set_password(*params[:acesso].values)

    if @usuario.valid?
      @usuario.save
      message.update(level: :information, text: 'Oba! Agora você já pode acessar e compartilhar suas ideias.')
      redirect path_to(:home)
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      view 'usuarios/form', layout: :signin
    end
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

  put '/:id', authenticate: true do |id|
    @usuario.set_all(params[:usuario])
    params[:acesso] && !params[:acesso].values.join.empty? && @usuario.set_password(*params[:acesso].values)

    if @usuario.valid?
      @usuario.save
      message.update(level: :information, text: 'Dados da conta foram atualizados.')
      redirect path_to(:conta), 303
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      view 'usuarios/form'
    end
  end
end

end # module
