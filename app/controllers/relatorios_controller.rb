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
    if params[:periodo] # periodo=yyyy-mm-dd~yyyy-mm-dd
      data_inicial, data_final = *params[:periodo].split('~')
    else
      data_final = Date.today
      data_inicial = data_final - 30
      params[:periodo] = "#{data_inicial}~#{data_final}"
    end

    @relatorio = Relatorio.new data_inicial: data_inicial, data_final: data_final

    @ideias = Ideia.where(id: @relatorio.total_ideias_por_apoiadores.keys).limit(10).all.map do |row|
      ideia = row.to_hash
      ideia[:total_apoiadores] = @relatorio.total_ideias_por_apoiadores[row.id]
      ideia
    end.sort do |a, b|
      a[:total_apoiadores] <=> b[:total_apoiadores]
    end.reverse

    @autores = Autor.where(id: @relatorio.total_ideias_por_autor.keys).all.map do |row|
      autor = row.to_hash
      autor[:total_ideias] = @relatorio.total_ideias_por_autor[row.id]
      autor
    end.sort do |a, b|
      a[:total_ideias] <=> b[:total_ideias]
    end.reverse

    @situacoes = Situacao.all
    @categorias = Categoria.all

    @ideias_por_autor = @relatorio.ideias_por_autor

    view 'relatorios/index'
  end
end

end # module
