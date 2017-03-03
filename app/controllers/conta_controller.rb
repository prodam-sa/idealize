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

  post '/' do
    @usuario = Usuario.new(params[:usuario]).set_password(*params[:acesso].values)

    if @usuario.valid?
      @usuario.save
      message.update(level: :information, text: 'Oba! Agora você já pode acessar e compartilhar suas ideias.')
      redirect path_to(:home)
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
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

  put '/', authenticate: true do
    @usuario.set_all(params[:usuario])
    params[:acesso] && !params[:acesso].values.join.empty? && @usuario.set_password(*params[:acesso].values)

    if @usuario.valid?
      @usuario.save
      message.update(level: :information, text: 'Dados da conta foram atualizados.')
      redirect path_to(:conta), 303
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      view 'conta/index'
    end
  end
end

end # module
