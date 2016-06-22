# encoding: utf-8

module Prodam::Idealize

class HomeController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:home_controller]
  end

  get '/' do
    if authenticated?
      @ideias = Ideia.find_by_situacao('publicacao').all
      view 'index'
    else
      @total_ideias = Ideia.count
      view 'wellcome', layout: :landpage
    end
  end

  get '/faq' do
    @page = pages[:faq]
    @faq = data @page[:data]
    view 'paginas/faq'
  end

  get '/ajuda' do
    message.update level: :warning, text: 'Página de "ajuda" está em desenvolvimento.'
    redirect path_to('/pesquisas'), 303
  end
end

end # module
