# encoding: utf-8

require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

module Prodam::Idealize

class ApplicationController < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    dont_reload 'lib/prodam/ideialize/version'
  end

  helpers Sinatra::ContentFor

  helpers AuthenticationHelper
  helpers ViewHelper
  helpers UrlHelper
  helpers GravatarHelper

  set :public_folder, 'public'
  set :views, 'app/views'
  set :authenticate do |required|
    condition do
      if required && !authenticated?
        message.update level: :warning, text: "Você precisa estar autenticado."
        redirect path_to(:conta, :acessar), 303
      end
    end
  end
  set :authorize do |action|
    condition do
      unless authorized?
        message.update level: :warning, text: "Você não possui permissão para #{action}."
        redirect path_to(:home), 303
      end
    end
  end
  set :authorize_only do |role|
    condition do
      unless authorized_by? role
        message.update level: :warning, text: "Você não possui permissão para acessar esta página."
        redirect path_to(:home), 303
      end
    end
  end

  enable :method_override
  enable :sessions

  before do
    @page = {}
    @fab = { url: path_to(:ideias, :nova), icon: :add, tooltip: 'Nova ideia!' }
    @relatorio = Relatorio.new
    @situacoes = Situacao.all.each_with_object Hash.new do |situacao, situacoes|
      situacoes[situacao.chave.to_sym] = situacao
    end

    if authenticated?
      @usuario ||= Autor.find_by_id session_user[:id]
      @relatorio.autor = @usuario
      @info ||= {}
      @info[:classificacao] ||= @relatorio.ranking_autor[:classificacao]
      @info[:total_pontos] ||= @relatorio.ranking_autor[:total_pontos]
      @info[:total_mensagens] ||= Mensagem.find_nao_lidas_para(@usuario.id).count
      @info[:total_ideias] ||= @usuario.ideias.size
      @info[:total_contribuicoes] ||= @usuario.contribuicoes.size
      [:premiacao, :avaliacao, :publicacao, :postagem, :rascunho, :revisao, :moderacao].each do |chave|
        key = "total_ideias_#{chave}"
        @info[key.to_sym] ||= @usuario.ideias.select do |ideia|
          ideia.situacao? chave
        end.compact.size
      end
    end
  end
end

end # Prodam::Idealize
