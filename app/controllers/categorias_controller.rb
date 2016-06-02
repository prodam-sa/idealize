# encoding: utf-8

module Prodam::Idealize

class CategoriasController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:categorias_controller]
    @situacoes = Situacao.all_by_sem_restricao(:chave).map(&:chave)
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

  get '/nova', authorize: 'criar nova categoria' do
    @categoria = Categoria.new
    @icones = data(:icons)
    view 'categorias/form'
  end

  get '/:id' do |id|
    view 'categorias/page'
  end

  post '/', authorize: 'criar categoria' do
    @categoria = Categoria.new(params[:categoria])
    if @categoria.valid?
      @categoria.save
      message.update(level: :information, text: 'Ideia registrada!')
      redirect to("/#{@categoria.to_url_param}")
    else
      @icones = data(:icons)
      message.update(level: :error, text: 'Oops! Tem alguma coisa errada. Observe os campos em vermelho.')
      view 'categorias/form'
    end
  end

  post '/', authorize: 'criar categoria' do
    @categoria = params[:categoria]
  end
end

end # module
