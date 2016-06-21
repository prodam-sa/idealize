# encoding: utf-8

module Prodam::Idealize

class Ideia < Model[:ideia]
  include Model

  plugin :validation_helpers

  many_to_one :autor
  many_to_many :categorias, {
    join_table: :ideia_categoria
  }
  many_to_many :coautores, {
    join_table: :ideia_coautor,
    right_key: :coautor_id
  }
  one_to_many :modificacoes

  def validate
    super
    validates_presence :titulo, message: 'deve ser atribuído.'
    validates_unique :titulo, message: 'já existe.'
    validates_max_length 128, :titulo, message: lambda{ |n| "deve ser de até #{n} caracteres." }

    validates_presence :texto_oportunidade, message: 'deve conter algum conteúdo.'
    validates_presence :texto_solucao, message: 'deve conter algum conteúdo.'
  end

  def param_name
    spliter = /[ "'\<\>\/\\]/
    "#{id}-#{titulo.downcase.split(spliter).join('-').squeeze}"
  end

  def situacoes?(*nomes)
    self[:situacao] && (nomes.include? self[:situacao].to_sym)
  end

  def historico
    modificacoes_dataset.order(:data_registro).reverse.all
  end

  def modificacao
    historico.first
  end

  def bloqueada?
    !(self[:bloqueada] =~ /S/i).nil?
  end

  def desbloqueada?
    !bloqueada?
  end

  def bloquear!
    self[:bloqueada] = 'S'
    save
  end

  def desbloquear!
    self[:bloqueada] = 'N'
    save
  end

  def publicar!
    self[:data_publicacao] = Time.now
    save
  end

  def before_save
    self[:data_atualizacao] = Time.now
  end

  def remove_all_modificacoes
    modificacoes_dataset.delete
  end

  class << self
    def latest(*fields)
      select(*fields).exclude(data_publicacao: nil).reverse(:data_criacao)
    end

    def find_by_autor(autor_id)
      where(autor_id: autor_id).reverse(:data_criacao)
    end

    def find_by_situacao(chave)
      where(situacao: chave).reverse(:data_atualizacao)
    end
    alias find_by_situacoes find_by_situacao

    def find_by_situacao_categoria(chave, categoria_id)
      join(:categoria, id: categoria_id).where(situacao: chave).reverse(:data_atualizacao)
    end

    def search(term)
      regexp_like(titulo: term, texto_oportunidade: term, texto_solucao: term).reverse(:data_atualizacao)
    end

  private

    def regexp_like(hash)
      expressao = hash.map do |field, pattern|
        format("regexp_like(#{field}, '%s', 'i')", pattern.to_s)
      end.join(' or ')
      where(expressao)
    end
  end
end

end # module
