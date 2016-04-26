# encoding: utf-8

class Prodam::Idealize::AdministracaoController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::GravatarHelper

  before authorize: true do
    @page = controllers[:administracao_controller]
  end

  get '/?' do
    @usuarios = Prodam::Idealize::Usuario.order(:nome).all.group_by do |usuario|
      usuario.nome[0].upcase
    end
    view 'administracao/index'
  end
end
