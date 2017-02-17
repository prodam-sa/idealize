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
