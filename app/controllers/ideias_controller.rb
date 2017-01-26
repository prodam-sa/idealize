# encoding: utf-8

module Prodam::Idealize

class IdeiasController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:ideias]
    @situacoes = Situacao.all_by_sem_restricao(:chave).map(&:chave)
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Ideia[ideia_id]
      @coautores = @ideia.coautores_dataset.order(:nome).all
      @situacao = @ideia.modificacao.situacao
    else
      @ideia = Ideia.new
      @situacao = Situacao.chave :rascunho
    end
  end

  get '/' do
    limit = (params[:limite].to_i > 0 && params[:limite] || 7).to_i
    page  = (params[:pagina].to_i > 0 && params[:pagina] || 1).to_i
    dataset = params[:autor] && params[:autor] =~ /usuario/i && @usuario && @usuario.ideias_dataset || Ideia.find_by_situacao(['publicacao', 'avaliacao'])
    dataset = params[:situacao] && !params[:situacao].empty? && dataset.where(situacao: params[:situacao]) || dataset
    dataset = case params[:ordem]
                when 'a~z' then dataset.order(:titulo)
                when 'z~a' then dataset.reverse(:titulo)
                when 'jan~dez' then dataset.order(:data_publicacao)
                when 'dez~jan' then dataset.reverse(:data_publicacao)
                else dataset.reverse(:data_publicacao)
              end

    @pagination = { limit: limit, offset: 0, order: params[:ordem] }
    @pagination[:total] = (dataset.count.to_i / @pagination[:limit].to_f).ceil
    @pagination[:current] = page > @pagination[:total] ? @pagination[:total] : page
    @pagination[:offset] = ((@pagination[:current] - 1) * @pagination[:limit])
    @pagination[:next] = @pagination[:current] < @pagination[:total] ? @pagination[:current] + 1 : @pagination[:total]
    @pagination[:previous] = @pagination[:current] <= @pagination[:next] ? @pagination[:current] - 1 : 1

    @ideias = dataset.eager(:autor, avaliacao: :classificacao).limit(@pagination[:limit]).offset(@pagination[:offset]).all

    view 'ideias/index'
  end

  get '/pesquisa' do
    @termo = params[:termo]
    @relatorio.ideias = Ideia.search(@termo).all
    view 'ideias/search'
  end

  get '/:id' do |id|
    @apoiadores = Relatorio.new.lista_apoiadores_ideia @ideia
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderador)
      view 'ideias/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  put '/:id/apoiar' do |id|
    if (permitido_apoiar? @ideia) && !(authenticated_as? :administrador, :moderador, :avaliador)
      unless usuario_apoiador? @ideia
        @ideia.add_apoiador usuario_id
        texto = 'Ideia apoiada pelo usuário.'
      else
        @ideia.remove_apoiador usuario_id
        texto = 'Apoio do usuário foi removido.'
      end
      historico(@ideia, @ideia.modificacao.situacao, mensagem(texto)).save
      message.update(level: :information, text: 'Seu apoio foi registrado.')
    else
      message.update(level: :error, text: 'Infelizmente, você não poderá apoiar essa ideia.')
    end
    redirect to(id)
  end

  # Moderação

  get '/:id/moderar', authorize_only: :moderador do |id|
    if (permitido_moderar? @ideia) or (usuario_moderador? @ideia)
      @processo = processo(:moderacao)
      @formulario = @processo.formulario
      @criterios = @formulario.criterios
      unless @ideia.modificacao.situacao_id == @processo.id
        @historico = historico(@ideia, @processo, 'Moderação iniciada.').save
      else
        @historico = @ideia.modificacao
      end
      @ideia.bloquear!
      view 'ideias/moderacao/form'
    else
      if @ideia.publicada?
        mensagem = 'Ideia já foi publicada.'
      else
        mensagem = 'Ideia em moderação por outro usuário.'
      end
      message.update(level: :warning, text: mensagem)
      redirect to(id)
    end
  end

  post '/:id/moderacao', authorize_only: :moderador do |id|
    @situacao = if ideia_moderada?
                  situacao(:publicacao)
                else
                  situacao(:revisao)
                end
    @historico = historico(@ideia, @situacao, params[:historico][:descricao])

    if @historico.valid?
      @ideia.situacao = @situacao.chave
      if ideia_moderada?
        @ideia.publicar!
        message.update(level: :information, text: 'Ideia foi publicada.')
        @ideia.bloquear!
      else
        message.update(level: :information, text: 'Ideia foi enviada para revisão.')
        @ideia.desbloquear!
      end
      @historico.save
      redirect to('/')
    else
      @formulario = processo(:moderacao).formulario
      @criterios = @formulario.criterios.map do |criterio|
        parametro = params[:criterios].select do |(id, resposta)|
          id == criterio.id
        end.first
        criterio.resposta = parametro ? parametro[:resposta] : 'N'
        criterio
      end
      message.update(level: :error, text: 'Oops! Observe os campos em vermelho.')
      view 'ideias/moderacao/form'
    end
  end

  # apenas para desbloqueio
  put '/:id/moderacao', authorize_only: :moderador do |id|
    if params[:desbloquear]
      @situacao = situacao(:postagem)
      @ideia.situacao = @situacao.chave
      @ideia.desbloquear!
      historico(@ideia, @situacao, 'Moderação cancelada').save
      message.update(level: :information, text: 'Moderação cancelada e ideia em situação de postagem.')
    end

    redirect to(id)
  end

  get '/autor/:autor_id' do |autor_id|
    @ideias = Ideia.find_by_autor(autor_id.to_i).all
    @ideias.to_s
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
