# encoding: utf-8

module Prodam::Idealize

class IdeiasController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:ideias]
    @situacoes = Situacao.all_by_sem_restricao(:chave).map(&:chave)
  end

  before '/:id/?:action?' do |id, action|
    if (ideia_id = id.to_i) > 0
      @ideia = Ideia[ideia_id]
      @coautores = @ideia.coautores_dataset.order(:nome).all
      @situacao = @ideia.modificacao.situacao
    else
      @ideia = Ideia.new
      @situacao = Situacao.chave :rascunho
    end
  end

  get '/' do
    limit = (params[:limite].to_i > 0 && params[:limite] || 7).to_i
    page  = (params[:pagina].to_i > 0 && params[:pagina] || 1).to_i
    dataset = params[:autor] && params[:autor] =~ /usuario/i && @usuario && @usuario.ideias_dataset || Ideia.find_by_situacao(['publicacao', 'avaliacao'])
    dataset = params[:situacao] && !params[:situacao].empty? && dataset.where(situacao: params[:situacao]) || dataset
    dataset = case params[:ordem]
                when 'a~z' then dataset.order(:titulo)
                when 'z~a' then dataset.reverse(:titulo)
                when 'jan~dez' then dataset.order(:data_publicacao, :data_criacao)
                when 'dez~jan' then dataset.reverse(:data_publicacao, :data_criacao)
                else dataset.reverse(:data_publicacao)
              end

    @pagination = { limit: limit, offset: 0, order: params[:ordem] }
    @pagination[:total] = ((dataset.count.to_i + 1) / @pagination[:limit].to_f).ceil
    @pagination[:current] = page > @pagination[:total] ? @pagination[:total] : page
    @pagination[:offset] = ((@pagination[:current] - 1) * @pagination[:limit])
    @pagination[:next] = @pagination[:current] < @pagination[:total] ? @pagination[:current] + 1 : @pagination[:total]
    @pagination[:previous] = @pagination[:current] <= @pagination[:next] ? @pagination[:current] - 1 : 1

    @ideias = dataset.eager(:autor, avaliacao: :classificacao).limit(@pagination[:limit]).offset(@pagination[:offset]).all

    view 'ideias/index'
  end

  get '/pesquisa' do
    @termo = params[:termo]
    @relatorio.ideias = Ideia.search(@termo).all
    view 'ideias/search'
  end

  get '/:id' do |id|
    @apoiadores = Relatorio.new.lista_apoiadores_ideia @ideia
    if (@ideia.publicada?) or (usuario_autor? @ideia) or (authorized_by? :moderador)
      view 'ideias/page'
    else
      message.update(level: :error, text: 'Você só poderá ler essa ideia depois de sua publicação.')
      redirect to('/')
    end
  end

  put '/:id/apoiar' do |id|
    if (permitido_apoiar? @ideia) && !(authenticated_as? :administrador, :moderador, :avaliador)
      unless usuario_apoiador? @ideia
        @ideia.add_apoiador usuario_id
        texto = 'Ideia apoiada pelo usuário.'
      else
        @ideia.remove_apoiador usuario_id
        texto = 'Apoio do usuário foi removido.'
      end
      historico(@ideia, @ideia.modificacao.situacao, mensagem(texto)).save
      message.update(level: :information, text: 'Seu apoio foi registrado.')
    else
      message.update(level: :error, text: 'Infelizmente, você não poderá apoiar essa ideia.')
    end
    redirect to(id)
  end

private
end

end # module
