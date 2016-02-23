# encoding: utf-8

class Prodam::Idealize::AcessoController < Prodam::Idealize::ApplicationController
  get '/', authenticate: true do
    @usuario ||= Prodam::Idealize::Usuario[session[:user_id]]
    view 'acesso/forms/usuario'
  end

  put '/:id', authenticate: true do |id|
    @usuario = Prodam::Idealize::Usuario[id]
    @usuario.update(params[:usuario])
    message.update(level: :information, text: 'Dados da conta foram atualizados.')
    redirect to('/'), 200
  end

  put '/:id/senha', authenticate: true do |id|
    @usuario = Prodam::Idealize::Usuario[id]
    if @usuario.save(params[:usuario])
      message.update(level: :information, text: 'Senha atualizada.')
    end
    redirect path_to('/conta'), 303
  end

  get '/acessar' do
    view 'acesso/form', layout: :signin
  end

  post '/acessar' do
    if @usuario = Prodam::Idealize::Usuario.authenticate(params[:usuario])
      authenticate(@usuario.id, @usuario.administrador?)
      redirect to('/'), 303
    else
      message.update level: :error, text: 'Usuário não encontrado ou senha inválida'
      redirect to('/'), 303
    end
  end

  get '/sair' do
    @usuario = nil
    disconect!
    redirect path_to('/'), 303
  end
end
