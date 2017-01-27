# encoding: utf-8

module Prodam::Idealize

class HomeController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @relatorio = Relatorio.new
    @page = controllers[:home]
  end

  get '/' do
    if authenticated?
      redirect path_to :ideias
    else
      @premiacao = Situacao.chave(:avaliacao)
      @moderacao = Situacao.chave(:publicacao)
      view 'home/wellcome', layout: :landpage
    end
  end

  get '/ranking' do
    view 'home/ranking'
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
end

end # module
