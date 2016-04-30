# encoding: utf-8

class Prodam::Idealize::AdministracaoController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::GravatarHelper

  before authorize: true do
    @page = controllers[:administracao_controller]
  end

  before '/usuarios/:id/?' do |id|
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
end
