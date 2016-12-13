# encoding: utf-8

module Prodam::Idealize

class RelatoriosController < ApplicationController
  helpers IdeiasHelper, DateHelper, MailHelper

  before authorize_only: :administrador do
    @page = controllers[:relatorios]
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
    # @ideias = Ideia.all
    @relatorio = Relatorio.new
    @total_ideias_por_data_postagem = @relatorio.total_ideias_por_data_postagem
    @total_ideias_por_categoria = @relatorio.total_ideias_por_categoria
    @total_ideias_por_autor = @relatorio.total_ideias_por_autor
    @total_ideias_por_situacao = @relatorio.total_ideias_por_situacao
    @total_ideias_por_categoria[0] = @relatorio.total_ideias_sem_categoria

    @autores = Autor.where(id: @total_ideias_por_autor.keys).all.map do |row|
      autor = row.to_hash
      autor[:total_ideias] = @total_ideias_por_autor[row.id]
      autor
    end.sort do |a, b|
      a[:total_ideias] <=> b[:total_ideias]
    end.reverse

    @situacoes = Situacao.all
    @categorias = Categoria.all

    view 'relatorios/index'
  end
end

end # module
