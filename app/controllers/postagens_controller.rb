# encoding: utf-8

module Prodam::Idealize

class PostagensController < IdeiasController

  before do
    @page = controllers[:postagens]
    @situacoes = Situacao.all_by_sem_restricao(:chave).map(&:chave)
    @fab = {
      url: path_to(:postagens, :nova),
      tooltip: 'Nova ideia!'
    } if authenticated?
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

  get '/', authenticate: true do
    @relatorio = Relatorio.new(ideias: Ideia.find_by_autor(usuario_id).order(:titulo).all)
    @ideias = @relatorio.ideias
    view 'ideias/postagens/index'
  end

  get '/nova', authenticate: true do
    view 'ideias/postagens/form'
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

  get '/:id', authenticate: true do |id|
    @categorias = Categoria.all if permitido_moderar? @ideia
    @apoiadores = Relatorio.new.lista_apoiadores_ideia @ideia
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderador)
      view 'ideias/postagens/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  get '/:id/editar', authenticate: true do |id|
    unless @ideia.bloqueada?
      view 'ideias/postagens/form'
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

  put '/:id', authenticate: true do |id|
    unless @ideia.bloqueada?
      @ideia.set_all(params[:ideia])
      @situacao = if params[:postar] && (params[:postar] == 'S')
                    situacao(:postagem)
                  else
                    situacao(:revisao)
                  end
      if @ideia.valid?
        @ideia.situacao = @situacao.chave
        @ideia.save
        historico(@ideia, @situacao, mensagem('Ideia revisada pelo autor')).save
        message.update(level: :information, text: 'Sua ideia foi atualizada com sucesso!')
        redirect to(id)
      else
        message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
        @categorias = Categoria.all
        view 'ideias/postagens/form'
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
      params[:ideia_coautores] && params[:ideia_coautores].each do |coautor_id|
        @ideia.add_coautor coautor_id
      end
      @ideia.remove_coautor usuario_id if (@ideia.coautores.include? usuario_id)
      message.update(level: :information, text: 'Os coautores de sua ideia foram atualizados.')
    else
      message.update(level: :warning, text: 'Sua ideia está bloqueada para inclusão de coautores.')
    end
    redirect to(id)
  end
end

end # module
