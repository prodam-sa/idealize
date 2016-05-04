# encoding: utf-8

class Prodam::Idealize::AdministracaoController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::GravatarHelper

  before authorize: true do
    @page = controllers[:administracao_controller]
  end

  before '/usuarios/:id/?:action?' do |id, action|
    @usuario = Prodam::Idealize::Usuario[id.to_i]
  end

  get '/?' do
    @usuarios = Prodam::Idealize::Usuario.order(:nome).all.group_by do |usuario|
      usuario.nome[0].upcase
    end
    view 'administracao/index'
  end

  get '/usuarios/:id' do |id|
    view 'administracao/usuarios/form'
  end

  put '/usuarios/:id' do |id|
    @usuario.update(params[:usuario])
    redirect to(path_to('/usuarios/' + id))
  end

  put '/usuarios/:id/senha' do |id|
    if @usuario.save_password(*params[:usuario].values)
      message.update(level: :success, text: 'Senha do usuário foi atualizada.')
    else
      message.update(level: :error, text: 'A senha informada não foi confirmada corretamente.')
    end
    redirect to(path_to('/usuarios/' + id))
  end
end
