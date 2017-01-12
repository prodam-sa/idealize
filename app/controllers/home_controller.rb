# encoding: utf-8

module Prodam::Idealize

class HomeController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:home]
  end

  get '/' do
    redirect path_to :ideias
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
      redirect path_to(:postagens)
    else
      @page = pages[:painel]
      view 'painel/index'
    end
  end
end

end # module
