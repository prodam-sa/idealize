# encoding: utf-8

module Prodam::Idealize

class HomeController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:home_controller]
  end

  get '/' do
    if authenticated?
      @total = {
        coautores_ideia: Relatorio.total_coautores_ideia,
      }
      @ideias = Ideia.find_by_situacao('publicacao').order(:data_publicacao).all
      view 'index'
    else
      @total = { ideias: Ideia.find_by_situacao('publicacao').count }
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

  get '/ajuda' do
    message.update level: :warning, text: 'Página de "ajuda" está em desenvolvimento.'
    redirect path_to('/pesquisas'), 303
  end
end

end # module
