# encoding: utf-8

class Prodam::Idealize::ModeracaoController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::IdeiasHelper

  before do
    @page = controllers[:moderacao_controller]
  end

  before authorize_only: :moderator do
    @page = controllers[:moderacao_controller]
  end

  get '/' do
    @ideias = Prodam::Idealize::Ideia.latest
    view 'moderacao/index'
  end

  get '/:ideia_id' do |ideia_id|
    @formulario = Prodam::Idealize::Formulario.first # Há somente um formulário, por enquanto.
    @ideia = Prodam::Idealize::Ideia[ideia_id.to_i]
    view 'moderacao/form'
  end
end
