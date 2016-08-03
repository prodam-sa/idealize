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
  many_to_many :apoiadores, {
    join_table: :ideia_apoiador
  }
  one_to_one :avaliacao

  def validate
    super
    validates_presence :titulo, message: 'deve ser atribuído.'
    validates_unique :titulo, message: 'já existe.'
    validates_max_length 128, :titulo, message: lambda{ |n| "deve ser de até #{n} caracteres." }

    validates_presence :texto_oportunidade, message: 'deve conter algum conteúdo.'
    validates_max_length 4000, :texto_oportunidade, message: lambda { |n|
      "deve ser de até #{n} caracteres. " +
      "O texto possui #{texto_oportunidade.size} caracteres e " +
      "#{texto_oportunidade.split(/ /).size} palavras."
    }

    validates_presence :texto_solucao, message: 'deve conter algum conteúdo.'
    validates_max_length 4000, :texto_solucao, message: lambda { |n|
      "deve ser de até #{n} caracteres. " +
      "O texto possui #{texto_solucao.size} caracteres e " +
      "#{texto_solucao.split(/ /).size} palavras."
    }
  end

  def param_name
    spliter = /[ "'\<\>\/\\]/
    "#{id}-#{titulo.downcase.split(spliter).join('-').squeeze}"
  end

  def situacoes?(*nomes)
    self[:situacao] && (nomes.include? self[:situacao].to_sym)
  end

  def historico
    @historico || (@historico = modificacoes_dataset.reverse(:data_registro).all)
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

  def publicada?
    !self[:data_publicacao].nil?
  end

  def before_validation
    [:texto_oportunidade, :texto_solucao].each do |texto|
      self[texto] = self[texto].squeeze(' ').gsub(/[\n\r]/, '')
    end
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
      regexp_like(term, :titulo, :texto_oportunidade, :texto_solucao).reverse(:data_atualizacao)
    end

  private

    def regexp_like(pattern, *fields)
      expressao = fields.map do |field|
        format("REGEXP_LIKE(#{field}, '%s', 'i')", pattern.to_s)
      end.join(' OR ')
      where(expressao)
    end
  end
end

end # module
