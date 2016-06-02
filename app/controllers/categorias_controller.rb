# encoding: utf-8

module Prodam::Idealize

class CategoriasController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:categorias_controller]
    @fab = {
      url: path_to(:categorias, :nova),
      tooltip: 'Nova categoria!'
    }
  end

  before '/:id/?:action?' do |id, action|
    @categoria = Categoria[id.to_i]
  end

  get '/' do
    @categorias = Categoria.all
    @categoria = Categoria.new
    view 'categorias/index'
  end

  get '/:id' do |id|
    @categoria.ideias.count # cache para ideias da categoria
    view 'categorias/page'
  end

  get '/:id/editar', authorize: 'editar categoria' do |id|
    'TODO: Formulário para editar uma categoria'
  end

  post '/', authorize: 'criar categoria' do
    @categoria = params[:categoria]
  end
end

end # module
