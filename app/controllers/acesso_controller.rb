# encoding: utf-8

class Prodam::Idealize::AcessoController < Prodam::Idealize::ApplicationController
  before do
    @page = controllers[:acesso_controller]
  end

  before '/:id/?:action?' do |id, action|
    @usuario = Prodam::Idealize::Usuario[id.to_i]
  end

  get '/', authenticate: true do
    @usuario ||= Prodam::Idealize::Usuario[session[:user][:id]]
    view 'acesso/forms/usuario'
  end

  put '/:id', authenticate: true do |id|
    @usuario.update(params[:usuario])
    message.update(level: :information, text: 'Dados da conta foram atualizados.')
    redirect path_to(:conta), 303
  end

  put '/:id/senha', authenticate: true do |id|
    if @usuario.save_password(*params[:usuario].values)
      message.update(level: :success, text: 'Senha atualizada.')
    else
      message.update(level: :error, text: 'A senha informada não foi confirmada corretamente.')
    end
    redirect path_to(:conta), 303
  end

  get '/acessar' do
    view 'acesso/form', layout: :signin
  end

  post '/acessar' do
    if @usuario = Prodam::Idealize::Usuario.authenticate(params[:usuario])
      authenticate(@usuario.id, @usuario.administrador?, @usuario.moderador?)
      redirect path_to(:home), 303
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
