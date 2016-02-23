# encoding: utf-8

class Prodam::Idealize::AcessoController < Prodam::Idealize::ApplicationController
  get '/' do
    if authenticated?
      view 'acesso/index'
    else
      view 'acesso/form', layout: :signin
    end
  end

  post '/acessar' do
    if @usuario = Prodam::Idealize::Usuario.authenticate(params[:usuario])
      authenticate(@usuario.id, @usuario.administrador?)
      redirect path_to('/'), 303
    else
      message.update level: :error, text: 'Usuário não encontrado ou senha inválida'
      redirect path_to('/'), 303
    end
  end

  get '/sair' do
    @usuario = nil
    disconect!
    redirect path_to('/'), 303
  end

  get '/conta', authenticate: :authenticate do
    @usuario ||= Prodam::Idealize::Usuario[session[:user_id]]
    view 'acesso/forms/usuario'
  end

  put '/conta/:id', authenticate: :authenticate do |id|
    @usuario = Prodam::Idealize::Usuario[id]
    @usuario.update(params[:usuario])
    message.update(level: :information, text: 'Dados da conta foram atualizados.')
    redirect path_to('/conta'), 200
  end

  put '/conta/:id/senha', authenticate: :authenticate do |id|
    @usuario = Prodam::Idealize::Usuario[id]
    if @usuario.save(params[:usuario])
      message.update(level: :information, text: 'Senha atualizada.')
    end
    redirect path_to('/conta'), 303
  end

  get '/ajuda' do
    message.update level: :warning, text: 'Página de "ajuda" está em desenvolvimento.'
    redirect path_to('/pesquisas'), 303
  end
end
