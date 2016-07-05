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
    view 'ideias/index'
  end
  
  get '/nova', authenticate: true do
    view 'ideias/form'
  end

  get '/pesquisa' do
    @termo = params[:termo]
    @relatorio = Relatorio.new ideias: Ideia.search(@termo).where(situacao: @situacoes).all
    view 'ideias/search'
  end

  post '/', authenticate: true do
    @situacao = situacao(:rascunho)
    @ideia = Ideia.new(params[:ideia])
    @ideia.autor_id = usuario_id

    if @ideia.valid?
      @ideia.save

      if params[:postar]
        @situacao = situacao(:postagem)
        historico(@ideia, @situacao, mensagem('Ideia postada pelo autor para moderação.')).save
        message.update(level: :information, text: 'Sua ideia foi postada com sucesso!')
      else
        historico(@ideia, @situacao, mensagem('Ideia criada em rascunho para edição.')).save
        message.update(level: :information, text: 'Sua ideia foi registrada em rascunho. Não esqueça de postar depois de finalizar.')
      end

      @ideia.situacao = @situacao.chave
      @ideia.save
      redirect to("/#{@ideia.to_url_param}")
    else
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      view 'ideias/form'
    end
  end

  get '/:id' do |id|
    @categorias = Categoria.all if permitido_moderar? @ideia
    @apoiadores = Relatorio.new.lista_apoiadores_ideia @ideia
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderador)
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
      @ideia.remove_coautor usuario_id if (@ideia.coautores.include? usuario_id)
      message.update(level: :information, text: 'Os coautores de sua ideia foram atualizados.')
    else
      message.update(level: :warning, text: 'Sua ideia está bloqueada para inclusão de coautores.')
    end
    redirect to(id)
  end

  put '/:id/categorias', authenticate: true do |id|
    if @ideia.desbloqueada? && (permitido_moderar? @ideia)
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

  def ideias_list
    @relatorio = {
      publicacoes: Relatorio.new(ideias: Ideia.find_by_situacoes(@situacoes).order(:data_criacao, :data_publicacao).all),
      moderacao: Relatorio.new(ideias: Ideia.find_by_situacao(['postagem', 'moderacao']).exclude(autor_id: usuario_id).order(:data_criacao, :data_publicacao).all),
      rascunhos: Relatorio.new(ideias: Ideia.find_by_autor(usuario_id).order(:data_criacao).all),
    }
  end
end

end # module
