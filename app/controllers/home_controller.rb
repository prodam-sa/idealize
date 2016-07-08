# encoding: utf-8

module Prodam::Idealize

class HomeController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:home]
  end

  get '/' do
    @relatorio = Relatorio.new
    if authenticated?
      @ideias = Ideia.find_by_situacao('publicacao').order(:data_publicacao).all
      @relatorio.ideias = @ideias
      view 'index'
    else
      view 'wellcome', layout: :landpage
    end
  end

  get '/faq' do
    @page = pages[:faq]
    @faq = data @page[:data]
    view 'paginas/faq'
  end

  get '/versao' do
    @page = pages[:versao]
    @changelog = data @page[:data]
    view 'paginas/changelog'
  end

  get '/painel', authenticate: true do
    unless authorized?
      redirect path_to(:postagem)
    else
      @page = pages[:painel]
      view 'painel/index'
    end
  end
end

end # module
