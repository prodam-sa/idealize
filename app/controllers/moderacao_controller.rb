# encoding: utf-8

module Prodam::Idealize

class ModeracaoController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before authenticate: true, authorize_only: :moderador do
    @page = controllers[:moderacao]
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Ideia.find_by_id(ideia_id)
      @processo = Processo.find chave: 'moderacao'
      @situacao = @ideia.situacao
    end
  end

  get '/' do
    pagina  = (params[:pagina].to_i > 0 && params[:pagina] || 1).to_i
    dataset = Ideia.find_by_situacao('postagem', 'moderacao').exclude(autor_id: @usuario.id)
    campo = params[:campo] && !params[:campo].empty? && params[:campo] || :data_criacao
    ordem = params[:ordem] && !params[:ordem].empty? && params[:ordem] || :crescente
    dataset = (ordem == :decrescente) ? dataset.reverse(campo.to_sym) : dataset.order(campo.to_sym)
    dataset = dataset.eager(:autor).page(pagina)
    @ideias = dataset.all
    @pagination = dataset.paging
    @relatorio = Relatorio.new(ideias: @ideias)
    @ideias = @relatorio.ideias

    view 'ideias/moderacao/index'
  end

  get '/:id' do |id|
    @categorias = Categoria.all
    @apoiadores = @relatorio.lista_apoiadores_ideia @ideia
    @historico = Historico.find_by_ideia(@ideia).find.group_by do |modificacao|
      formated_date modificacao.data_registro
    end
    view 'ideias/moderacao/page'
  end

  put '/:id/categorias' do |id|
    if (permitido_moderar? @ideia) or (usuario_moderador? @ideia)
      @ideia.remove_all_categorias
      params[:categorias] && params[:categorias].each do |categoria_id|
        @ideia.add_categoria categoria_id
      end
      message.update(level: :information, text: 'As categorias foram atualizadas.')
    else
      message.update(level: :warning, text: 'A ideia está bloqueada para alteração de categorias.')
    end
    redirect to(id)
  end

  get '/:id/moderar' do |id|
    if (permitido_moderar? @ideia) or (usuario_moderador? @ideia)
      @formulario = @processo.formulario
      @criterios = @formulario.criterios
      unless @ideia.modificacao.situacao_id == @processo.id
        @historico = historico(@ideia, @processo, 'Moderação iniciada.').save
      else
        @historico = @ideia.modificacao
      end
      view 'ideias/moderacao/edit'
    else
      if @ideia.publicada?
        mensagem = 'Ideia já foi publicada.'
      elsif @ideia.coautores.include? @usuario
        mensagem = 'Você é coautor(a) dessa ideia.'
      else
        mensagem = 'Ideia em moderação por outro usuário.'
      end
      message.update(level: :warning, text: mensagem)
      redirect to(id)
    end
  end

  post '/:id' do |id|
    @situacao = ideia_moderada? && @situacao.seguinte || @situacao.oposta
    @historico = historico(@ideia, @situacao, params[:historico][:descricao])

    if @historico.valid?
      @ideia.situacao = @situacao
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
      @formulario = @processo.formulario
      @criterios = @formulario.criterios.map do |criterio|
        parametro = params[:criterios].select do |resposta|
          resposta[:id] == criterio.id.to_s
        end.first
        criterio.resposta = parametro ? parametro[:resposta] : 'N'
        criterio
      end
      message.update(level: :error, text: 'Oops! Observe os campos em vermelho.')
      view 'ideias/moderacao/edit'
    end
  end

  # apenas para desbloqueio
  put '/:id' do |id|
    if params[:desbloquear]
      @situacao = situacao(:postagem)
      @ideia.situacao = @situacao
      @ideia.save
      historico(@ideia, @situacao, 'Moderação cancelada').save
      message.update(level: :information, text: 'Moderação cancelada e ideia em situação de postagem.')
    end
    redirect to(id)
  end

private

  def ideia_moderada?
    total = params[:criterios].size
    check = params[:criterios].select do |criterio|
      criterio['resposta'] =~ /S/i
    end

    check.size == params[:criterios].size
  end
end

end # module
