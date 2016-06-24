# encoding: utf-8

module Prodam::Idealize

class IdeiasController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:ideias_controller]
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
    ideias_list
    @ideia = Ideia.new
    view 'ideias/index'
  end
  
  get '/nova', authenticate: true do
    view 'ideias/form'
  end

  get '/pesquisa' do
    @termo = params[:termo]
    @ideias = Ideia.search(@termo).where(situacao: @situacoes).all
    view 'ideias/list'
  end

  post '/', authenticate: true do
    @ideia = Ideia.new(params[:ideia])
    @ideia.autor_id = usuario_id
    if @ideia.valid?
      @ideia.save
      historico(@ideia, situacao(:rascunho), mensagem('Ideia criada em rascunho para edição.')).save
      message.update(level: :information, text: 'Sua ideia foi registrada em rascunho. Não esqueça de postar depois de finalizar.')
      redirect to("/#{@ideia.to_url_param}")
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      @situacao = Situacao.chave :rascunho
      view 'ideias/form'
    end
  end

  get '/:id' do |id|
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderator)
      view 'ideias/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  get '/:id/editar' do |id|
    unless @ideia.bloqueada?
      view 'ideias/form'
    else
      if @ideia.publicada?
        mensagem = 'Sua ideia já foi publicada.'
      else
        mensagem = 'Sua ideia está em moderação. Por enquanto, ela não poderá ser alterada.'
      end
      message.update(level: :warning, text: mensagem)
      redirect to(id)
    end
  end

  put '/:id' do |id|
    unless @ideia.bloqueada?
      @ideia.set_all(params[:ideia])
      if @ideia.valid?
        @ideia.save
        historico(@ideia, situacao(:revisao), mensagem('Ideia revisada pelo autor')).save
        message.update(level: :information, text: 'Sua ideia foi atualizada com sucesso!')
        redirect to(id)
      else
        message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
        @categorias = Categoria.all
        view 'ideias/form'
      end
    else
      message.update(level: :warning, text: 'Sua ideia ainda está em moderação.')
      redirect to(id)
    end
  end

  put '/:id/postar' do |id|
    @ideia.situacao = :postagem
    @ideia.save
    historico(@ideia, situacao(:postagem), mensagem('Ideia postada pelo autor para moderação.')).save
    message.update(level: :information, text: 'Sua ideia foi postada com sucesso!')
    redirect to("/#{@ideia.to_url_param}")
  end

  delete '/:id', authenticate: true  do |id|
    unless @ideia.bloqueada?
      @ideia.remove_all_coautores
      @ideia.remove_all_categorias
      @ideia.remove_all_modificacoes
      @ideia.delete
      ideias_list
      message.update(level: :information, text: 'Sua ideia foi excluída.')
      redirect to('/')
    else
      message.update(level: :warning, text: 'Sua ideia está em moderação e não poderá ser excluída.')
      redirect to(id)
    end
  end

  put '/:id/coautores', authenticate: true do |id|
    if @ideia.desbloqueada? && (usuario_autor? @ideia)
      @ideia.remove_all_coautores
      params[:coautores] && params[:coautores].each do |coautor_id|
        @ideia.add_coautor coautor_id
      end
      message.update(level: :information, text: 'Os coautores de sua ideia foram atualizados.')
    else
      message.update(level: :warning, text: 'Sua ideia está bloqueada para inclusão de coautores.')
    end
    redirect to(id)
  end

  get '/:id/moderar', authorize_only: :moderator do |id|
    unless @ideia.bloqueada? && (usuario_moderador? @ideia)
      @formulario = Formulario.first # Há somente um formulário, por enquanto.
      @criterios = @formulario.criterios
      @situacao = situacao(:moderacao)
      unless @ideia.modificacao.situacao_id == @situacao.id
        @historico = historico(@ideia, @situacao, 'Ideia em moderação.').save
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

  post '/:id/moderacao', authorize_only: :moderator do |id|
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
      @formulario = Formulario.first
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
  put '/:id/moderacao', authorize_only: :moderator do |id|
    if params[:desbloquear]
      @ideia.desbloquear!
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

  def ideias_list
    @ideias = {
      latest: Ideia.find_by_situacoes(@situacoes).all,
      moderacao: Ideia.find_by_situacao(['postagem', 'moderacao']).reject do |ideia|
        ideia.autor_id == usuario_id
      end,
      all_by_autor: nil
    }
    if authorized?
      @ideias[:all_by_situacao] = Ideia.all.group_by do |ideia|
        ideia.situacao.to_sym
      end
    end
    @ideias[:all_by_autor] = Ideia.find_by_autor(usuario_id).all
  end
end

end # module
