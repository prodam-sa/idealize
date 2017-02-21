# encoding: utf-8

module Prodam::Idealize

class RelatoriosController < ApplicationController
  helpers IdeiasHelper, DateHelper, MailHelper

  before authorize_only: :administrador do
    @hoje = Date.today
    @page = controllers[:relatorios]
    @filtros = {
      'Ontem' => "#{@hoje-1}~#{@hoje}",
      'Última semana' => "#{@hoje-7}~#{@hoje}",
      'Últimos 30 dias' => "#{@hoje-30}~#{@hoje}",
      'Últimos 60 dias' => "#{@hoje-60}~#{@hoje}",
      'Tudo' => "#{@hoje-(@hoje-timestamp).to_i}~#{@hoje}",
    }
  end

  get '/' do
    redirect path_to(:relatorios, :periodo)
  end

  get '/periodo/?:periodo?' do |periodo|
    if periodo # periodo=yyyy-mm-dd~yyyy-mm-dd
      data_inicial, data_final = *periodo.split('~')
    else
      data_final = Date.today
      data_inicial = data_final - 30
      params[:periodo] = "#{data_inicial}~#{data_final}"
    end

    @relatorio = Relatorio.new data_inicial: data_inicial, data_final: data_final

    @autores = Autor.where(id: @relatorio.total_ideias_por_autor.keys).all.map do |row|
      autor = row.to_hash
      autor[:total_ideias] = @relatorio.total_ideias_por_autor[row.id]
      autor
    end.sort do |a, b|
      a[:total_ideias] <=> b[:total_ideias]
    end.reverse

    @situacoes = Situacao.all
    @categorias = Categoria.all

    @ideias_por_apoiadores = Ideia.where(id: @relatorio.total_ideias_por_apoiadores.keys).limit(10).all.map do |row|
      ideia = row.to_hash
      ideia[:total_apoiadores] = @relatorio.total_ideias_por_apoiadores[row.id]
      ideia
    end.sort do |a, b|
      a[:total_apoiadores] <=> b[:total_apoiadores]
    end.reverse
    @ideias_por_autor = @relatorio.ideias_por_autor
    @ideias_por_pontuacao = Avaliacao.find_by_situacao_data(:avaliacao, data_inicial, data_final).map do |avaliacao|
      avaliacao.ideia
    end.sort do |a, b|
      a.avaliacao.pontos <=> b.avaliacao.pontos
    end.reverse

    view 'relatorios/index'
  end

  get '/data/:nome/:data' do |nome, data|
    @ideias = Ideia.find_by_data(nome, data).reverse.all
    @relatorio = Relatorio.new ideias: @ideias

    view 'relatorios/ideias'
  end
end

end # module
