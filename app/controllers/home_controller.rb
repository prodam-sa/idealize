# encoding: utf-8

class Prodam::Idealize::HomeController < Prodam::Idealize::ApplicationController
  helpers Prodam::Idealize::IdeiasHelper

  before do
    @page = controllers[:home_controller]
  end

  get '/' do
    @categorias = Prodam::Idealize::Categoria.all
    @ideias = Prodam::Idealize::Ideia.latest 10
    view 'index'
  end

  get '/ajuda' do
    message.update level: :warning, text: 'Página de "ajuda" está em desenvolvimento.'
    redirect path_to('/pesquisas'), 303
  end
end
