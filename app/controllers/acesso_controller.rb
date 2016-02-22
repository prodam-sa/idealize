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
      message.update level: :error, text: 'Usuário não encontrado ou senha inválida', url: '/'
      redirect path_to('/'), 303
    end
  end

  get '/sair' do
    @usuario = nil
    disconect!
    redirect path_to('/'), 303
  end

  get '/ajuda' do
    message.update level: :warning, text: 'Página de "ajuda" está em desenvolvimento.'
    redirect path_to('/pesquisas'), 303
  end
end
