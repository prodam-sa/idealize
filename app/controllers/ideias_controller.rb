# encoding: utf-8

class Prodam::Idealize::IdeiasController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::IdeiasHelper

  before do
    @page = controllers[:ideias_controller]
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Prodam::Idealize::Ideia[ideia_id]
    else
      @ideia = Prodam::Idealize::Ideia.new
    end
  end

  get '/' do
    ideias_list
    @ideia = Prodam::Idealize::Ideia.new
    view 'ideias/index'
  end
  
  get '/nova', authenticate: true do
    @categorias = Prodam::Idealize::Categoria.all
    view 'ideias/form'
  end

  post '/', authenticate: true do
    @ideia = Prodam::Idealize::Ideia.new(params[:ideia])
    @ideia.autor_id = usuario_id
    @ideia.save
    view 'ideias/page'
  end

  get '/:id' do |id|
    view 'ideias/page'
  end

  get '/:id/editar' do |id|
    @categorias = Prodam::Idealize::Categoria.all
    view 'ideias/form'
  end

  put '/:id' do |id|
    @ideia.update(params[:ideia])
    @ideia.remove_all_categorias
    params[:categorias].each do |categoria|
      @ideia.add_categoria categoria
    end
    view 'ideias/page'
  end

  put '/:id/publicar' do |id|
    @ideia.publicar!
    redirect to("/#{@ideia.to_url_param}")
  end

  delete '/:id' do |id|
    @ideia.delete
    ideias_list
    view 'ideias/index'
  end

  get '/autor/:autor_id' do |autor_id|
    @ideias = Prodam::Idealize::Ideia.all_by_autor(autor_id.to_i)
    @ideias.to_s
  end

private

  def ideias_list
    @ideias = {
      latest: Prodam::Idealize::Ideia.latest(5),
      all_by_autor: nil
    }
    if usuario_id && autor = Prodam::Idealize::Autor[usuario_id]
      @ideias[:all_by_autor] = Prodam::Idealize::Ideia.all_by_autor(autor.id)
    end
  end
end
