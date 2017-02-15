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
      @processo = Processo.find_by_chave 'avaliacao'
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
