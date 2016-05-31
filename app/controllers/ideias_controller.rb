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
    else
      @ideia = Ideia.new
    end
  end

  get '/' do
    ideias_list
    @ideia = Ideia.new
    view 'ideias/index'
  end
  
  get '/nova', authenticate: true do
    @categorias = Categoria.all
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
    @ideia.save_changes
    @ideia.save
    registrar_historico(:rascunho, mensagem('Ideia criada em rascunho para edição.')).save_changes
    view 'ideias/page'
  end

  get '/:id' do |id|
    view 'ideias/page'
  end

  get '/:id/editar' do |id|
    @categorias = Categoria.all
    view 'ideias/form'
  end

  put '/:id' do |id|
    registrar_historico(:revisao, mensagem('Ideia revisada pelo autor')).update(params[:ideia])
    @ideia.remove_all_categorias
    params[:categorias].each do |categoria|
      @ideia.add_categoria categoria
    end if params[:categorias]
    view 'ideias/page'
  end

  put '/:id/postar' do |id|
    registrar_historico(:postagem, mensagem('Ideia postada pelo autor para moderação.')).save
    redirect to("/#{@ideia.to_url_param}")
  end

  delete '/:id', authenticate: true  do |id|
    registrar_historico(:arquivo, mensagem('Ideia excluída pelo autor.')).save
    @ideia.remove_all_coautores
    @ideia.remove_all_categorias
    @ideia.remove_all_modificacoes
    @ideia.delete
    ideias_list
    view 'ideias/index'
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
