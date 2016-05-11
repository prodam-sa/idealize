# encoding: utf-8

module Prodam::Idealize

class ModeracaoController < ApplicationController
  helpers IdeiasHelper
  helpers DateHelper

  before do
    @page = controllers[:moderacao_controller]
  end

  before authorize_only: :moderator do
    @page = controllers[:moderacao_controller]
  end

  before '/:ideia_id' do |ideia_id|
    @ideia = Ideia[ideia_id.to_i]
  end

  get '/' do
    ideias_list
    view 'moderacao/index'
  end

  get '/:ideia_id' do |ideia_id|
    @formulario = Formulario.first # Há somente um formulário, por enquanto.
    view 'moderacao/form'
  end

  post '/:ideia_id' do |ideia_id|
    validar_ideia params[:criterios], params[:historico][:mensagem]
    ideias_list
    view 'moderacao/index'
  end

private

  def validar_ideia(criterios, mensagem)
    total = criterios.size
    check = criterios.select do |criterio|
      criterio['resposta'] =~ /S/i
    end
    situacao = check.size == criterios.size ? :postagem : :revisao
    registrar_historico(situacao, mensagem).save
  end

  def ideias_list
    @ideias = Ideia.all_by_situacao('postagem').reject do |ideia|
      ideia.autor_id == usuario_id
    end
  end
end

end # module
