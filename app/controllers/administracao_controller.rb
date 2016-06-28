# encoding: utf-8

module Prodam::Idealize

class AdministracaoController < ApplicationController
  helpers GravatarHelper

  before do
    @page = controllers[:administracao_controller]
  end

  before authorize: 'administração' do
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
    message.update(level: :information, text: 'Dados do usuário foram atualizados com sucesso.')
    redirect to('/usuarios/' + id)
  end

  put '/usuarios/:id/senha' do |id|
    if @usuario.set_password(*params[:usuario].values).save
      message.update(level: :information, text: 'Senha do usuário foi atualizada.')
    else
      message.update(level: :error, text: 'A senha informada não foi confirmada corretamente.')
    end
    redirect to('/usuarios/' + id)
  end
end

end # Prodam::Idealize
