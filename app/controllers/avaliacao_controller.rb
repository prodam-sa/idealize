# encoding: utf-8

module Prodam::Idealize

class AvaliacaoController < ApplicationController
  helpers IdeiasHelper, AvaliacaoHelper, DateHelper, MailHelper

  before authorize_only: :avaliador do
    @page = controllers[:avaliacao]
    @processo = processo('avaliacao')
    @situacoes = Situacao.all_by_sem_restricao(:chave).map(&:chave)
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Ideia[ideia_id]
      @situacao = @ideia.modificacao.situacao
    else
      @ideia = Ideia.new
      @situacao = Situacao.chave :rascunho
    end
  end

  get '/' do
    @relatorio = Relatorio.new(ideias: Ideia.find_by_situacao('publicacao').exclude(autor_id: usuario_id).order(:data_criacao, :data_publicacao).all)
    @ideias_avaliadas = Ideia.
      find_by_situacao('avaliacao').
      exclude(autor_id: usuario_id).
      order(:data_criacao, :data_publicacao).
      eager(:avaliacao).
      all
    @ideias = @relatorio.ideias
    view 'ideias/avaliacao/index'
  end

  get '/:id' do |id|
    @apoiadores = Relatorio.new.lista_apoiadores_ideia @ideia
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderador)
      view 'ideias/avaliacao/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  post '/' do
    @pontuacoes = params[:pontuacoes]
    @pontuacoes && @pontuacoes.each do |pontuacao|
      pontos = pontuacao[:pontos] && pontuacao[:pontos].to_i
      if pontos > 0
        @classificacao = classificacao(pontos)
        @avaliacao = Avaliacao.new(ideia_id: pontuacao[:ideia_id].to_i, classificacao: @classificacao, pontos: pontos)
        @ideia = @avaliacao.ideia
        @situacao = situacao(:avaliacao)
        @ideia.situacao = @situacao.chave
        @ideia.save
        @avaliacao.save
        historico(@avaliacao.ideia, @situacao, "Ideia avaliada com pontuacao #{pontos} e classificada como #{@classificacao.titulo}").save
      end
    end
    redirect to('/')
  end

  post '/notificacao' do
    rodape = "<hr/><p><small>#{version_info}</small></p>"
    assunto  = (params[:assunto] || 'Ideia avaliada')
    mensagem = params[:mensagem]
    @notificacoes = Ideia.eager(:autor, :avaliacao).where(id: params[:ideias]).all.map do |ideia|
      avaliacao = ideia.avaliacao
      classificacao = avaliacao.classificacao
      cabecalho = "<p><b>Ideia</b>: #{ideia.titulo}</p><p><b>Pontuação</b>: #{avaliacao.pontos}</p><p><b>Classificação</b>: #{classificacao.titulo}</p><hr/>"
      mensagem  = cabecalho + markdown(mensagem) + rodape
      enviar_notificacao para:    ideia.autor.email,
                         assunto: assunto,
                         mensagem_html:   mensagem
    end
    message.update(level: :information, text: 'Mensagem enviada para os autores das ideias avaliadas.')
    redirect to('/')
  end
end

end # module
