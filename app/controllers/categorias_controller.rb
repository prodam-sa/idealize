# encoding: utf-8

class Prodam::Idealize::CategoriasController < Prodam::Idealize::ApplicationController
  before do
    @page = controllers[:categorias_controller]
  end

  before '/:id/?:action?' do |id, action|
    @categoria = Prodam::Idealize::Categoria[id.to_i]
  end

  get '/' do
    @categorias = Prodam::Idealize::Categoria.all
    @categoria = Prodam::Idealize::Categoria.new
    view 'categorias/index'
  end

  get '/:id' do |id|
    view 'categorias/detail'
  end

  get '/:id/editar', authorize: 'editar categoria' do |id|
    'TODO: Formulário para editar uma categoria'
  end

  post '/', authorize: 'criar categoria' do
    @categoria = params[:categoria]
  end
end
