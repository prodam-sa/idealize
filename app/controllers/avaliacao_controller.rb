# encoding: utf-8

module Prodam::Idealize

class AvaliacaoController < ApplicationController
  helpers IdeiasHelper, AvaliacaoHelper, DateHelper, MailHelper

  before authenticate: true, authorize_only: :avaliador do
    @page = controllers[:avaliacao]
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Ideia.find_by_id(ideia_id)
      @processo = Processo.find_by_chave('avaliacao')
      @formulario = @processo.formulario
      @criterios = @formulario.criterios
      @situacao = @ideia.situacao
    end
  end

  get '/' do
    pagina  = (params[:pagina].to_i > 0 && params[:pagina] || 1).to_i
    dataset = Ideia.find_by_situacao('publicacao').exclude(autor_id: @usuario.id)
    campo = params[:campo] && !params[:campo].empty? && params[:campo] || :data_criacao
    ordem = params[:ordem] && !params[:ordem].empty? && params[:ordem] || :crescente
    dataset = (ordem == 'decrescente') ? dataset.reverse(campo.to_sym) : dataset.order(campo.to_sym)
    dataset = dataset.eager(:autor).page(pagina)
    @pagination = dataset.paging
    @ideias = dataset.all
    @relatorio = Relatorio.new(ideias: @ideias)
    @ideias = @relatorio.ideias

    view 'ideias/avaliacao/index'
  end

  get '/:id' do |id|
    @categorias = Categoria.all
    @apoiadores = @relatorio.lista_apoiadores_ideia @ideia
    @historico = Historico.find_by_ideia(@ideia).all.group_by do |modificacao|
      formated_date modificacao.data_registro
    end
    view 'ideias/avaliacao/page'
  end

  get '/:id/avaliar' do |id|
    if (permitido_avaliar? @ideia) or (usuario_avaliador? @ideia)
      @formulario = @processo.formulario
      @criterios = @formulario.criterios_dataset.eager(:subcriterios).order(:titulo).all
      unless @processo.id == @ideia.modificacao.situacao_id
        @ideia.situacao = @processo
        @ideia.bloquear!
        @historico = historico(@ideia, @processo, 'Avaliação iniciada.').save
      else
        @historico = @ideia.modificacao
      end
      view 'ideias/avaliacao/edit'
    else
      if @ideia.avaliacao
        mensagem = 'Ideia já foi avaliada.'
      elsif @ideia.coautores.include? @usuario
        mensagem = 'Você é coautor(a) dessa ideia.'
      else
        mensagem = 'Ideia em avaliação por outro usuário.'
      end
      message.update(level: :warning, text: mensagem)
      redirect to(id)
    end
  end

  post '/:id' do |id|
    @respostas = params[:criterios] && Criterio.where(id: params[:criterios].values).eager(:criterio).all || []
    @pontos = @respostas && @respostas.map do |resposta|
      resposta.peso
    end.reduce do |total, peso|
      total + peso
    end || 0
    if ideia_avaliada?
      @classificacao = classificacao(@pontos)
      @avaliacao = Avaliacao.new(ideia: @ideia, classificacao: @classificacao, pontos: @pontos)
      @ideia.situacao = @situacao.seguinte
      @ideia.save
      @avaliacao.save
      message.update(level: :information, text: 'Ideia foi avaliada e classificada. O autor foi notificado por e-mail.')
      historico(@ideia, @ideia.situacao, "Ideia avaliada com pontuacao #{@pontos} e classificada como #{@classificacao.titulo}.").save
      enviar_notificacao(para: @ideia.autor.email, assunto: 'Sua ideia foi avaliada', mensagem_html: view("ideias/avaliacao/email-#{@ideia.situacao.chave}", layout: false))
      redirect to('/')
    else
      @formulario = @processo.formulario
      @criterios = @formulario.criterios_dataset.eager(:subcriterios).order(:titulo).all
      message.update(level: :error, text: "Avaliação com #{@pontos} pontos e #{@respostas.size} respostas. Pontuação mínima é de #{@pontos_minimos} pontos para #{@criterios.size} critérios.")
      view 'ideias/avaliacao/edit'
    end
  end

  # apenas para desbloqueio
  put '/:id' do |id|
    if params[:desbloquear]
      @ideia.situacao = situacao(:publicacao)
      @ideia.desbloquear!
      historico(@ideia, @ideia.situacao, 'Avaliação cancelada').save
      message.update(level: :information, text: 'Avaliação cancelada e ideia em situação de publicação.')
    end
    redirect to('/')
  end

private

  def ideia_avaliada?
    @pontos_minimos = @criterios.map do |criterio|
      criterio.peso
    end.reduce do |total, peso|
      total + peso
    end
    params[:criterios] && (params[:criterios].size == @criterios.size) && (@pontos >= @pontos_minimos)
  end
end

end # module
