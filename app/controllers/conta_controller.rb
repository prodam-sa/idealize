# encoding: utf-8

module Prodam::Idealize

class ContaController < ApplicationController
  before do
    @page = controllers[:conta]
  end

  before '/:id/?:action?' do |id, action|
    id.to_i > 0 && @usuario = Usuario[id.to_i]
  end

  get '/' do
    if id = session_user[:id]
      @usuario = Usuario[id]
      view 'conta/index'
    else
      redirect path_to(:conta, :nova)
    end
  end

  get '/nova' do
    if id = session_user[:id]
      redirect path_to(:conta)
    else
      @usuario = Usuario.new
      view 'conta/new'
    end
  end

  get '/acessar' do
    view 'conta/login', layout: :signin
  end

  post '/acessar' do
    if params[:usuario] && (@usuario = Usuario.authenticate(params[:usuario]))
      authenticate(@usuario.id, @usuario.email, *@usuario.profiles)
      message.update level: :information, text: "Olá, #{@usuario.nome}. Bem-vindo!"
      path = params[:url] ? to(params[:url]) : path_to(:home)
      redirect path, 303
    else
      message.update level: :error, text: 'Usuário não encontrado ou senha inválida'
      redirect to('/acessar'), 303
    end
  end

  get '/sair' do
    @usuario = nil
    disconect!
    redirect path_to('/'), 303
  end
end

end # module
