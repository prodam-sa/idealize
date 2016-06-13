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
    unless @ideia.bloqueada? && @ideia.modificacao.responsavel_id != usuario_id
      @formulario = Formulario.first # Há somente um formulário, por enquanto.
      @criterios = @formulario.criterios
      @situacao = situacao(:moderacao)
      unless @ideia.modificacao.situacao_id == @situacao.id
        @historico = historico(@ideia, @situacao, 'Ideia em moderação.').save
      else
        @historico = @ideia.modificacao
      end
      @ideia.bloquear!
      view 'moderacao/form'
    else
      message.update(level: :warning, text: 'Ideia em moderação e bloqueada por outro usuário.')
      redirect to('/')
    end
  end

  post '/:ideia_id' do |ideia_id|
    @situacao = if ideia_moderada?
                  situacao(:publicacao)
                else
                  situacao(:revisao)
                end
    @historico = historico(@ideia, @situacao, params[:historico][:descricao])

    if @historico.valid?
      if ideia_moderada?
        @ideia.publicar!
        message.update(level: :information, text: 'Ideia foi publicada.')
      else
        message.update(level: :information, text: 'Ideia foi enviada para revisão.')
        @ideia.desbloquear!
      end
      @historico.save
      redirect to('/')
    else
      @formulario = Formulario.first
      @criterios = @formulario.criterios.map do |criterio|
        parametro = params[:criterios].select do |(id, resposta)|
          puts resposta
          id == criterio.id
        end.first
        criterio.resposta = parametro ? parametro[:resposta] : 'N'
        criterio
      end
      message.update(level: :error, text: 'Oops! Observe os campos em vermelho.')
      ideias_list
      view 'moderacao/form'
    end
  end

private

  def ideia_moderada?
    total = params[:criterios].size
    check = params[:criterios].select do |criterio|
      criterio['resposta'] =~ /S/i
    end

    check.size == params[:criterios].size
  end

  def ideias_list
    @ideias = Ideia.all_by_situacao('postagem').reject do |ideia|
      ideia.autor_id == usuario_id
    end
  end
end

end # module
