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
    @categorias = Categoria.all
    @coautores = Coautor.select(:id, :nome).order(:nome).all.group_by do |coautor|
      sanitize_letter(coautor.nome[0].upcase)
    end
    @coautores = letters.merge(@coautores)
    view 'ideias/form'
  end

  get '/pesquisa' do
    @termo = params[:termo]
    if authenticated?
      @ideias = Ideia.search(@termo).where(autor_id: usuario_id).all
    else
      @ideias = Ideia.search(@termo).where(situacao: @situacoes).all
    end
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
      @categorias = Categoria.all
      @situacao = Situacao.chave :rascunho
      view 'ideias/form'
    end
  end

  get '/:id' do |id|
    if (usuario_autor? @ideia) or authorized?
      view 'ideias/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  get '/:id/editar' do |id|
    unless @ideia.bloqueada?
      @categorias = Categoria.all
      @coautores = Coautor.select(:id, :nome).order(:nome).all.group_by do |coautor|
        sanitize_letter(coautor.nome[0].upcase)
      end
      @coautores = letters.merge(@coautores)
      view 'ideias/form'
    else
      message.update(level: :warning, text: 'Sua ideia está em moderação. Por enquanto, ela não poderá ser alterada.')
      redirect to(id)
    end
  end

  put '/:id' do |id|
    unless @ideia.bloqueada?
      @ideia.set_all(params[:ideia])
      if @ideia.valid?
        if params[:categorias]
          @ideia.remove_all_categorias
          params[:categorias].each do |categoria|
            @ideia.add_categoria categoria
          end
        end
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

  get '/autor/:autor_id' do |autor_id|
    @ideias = Ideia.all_by_autor(autor_id.to_i).all
    @ideias.to_s
  end

private

  def ideias_list
    @ideias = {
      latest: Ideia.all_by_situacao(@situacoes, 5).all,
      all_by_autor: nil
    }
    if usuario_id && autor = Autor[usuario_id]
      @ideias[:all_by_autor] = Ideia.all_by_autor(autor.id).all
    end
  end
end

end # module
