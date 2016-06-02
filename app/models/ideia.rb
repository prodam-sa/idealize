# encoding: utf-8

class Prodam::Idealize::Ideia < Prodam::Idealize::Model[:ideia]
  include Prodam::Idealize::Model

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
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
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
    def latest(limit = 10, *fields)
      select(*fields).limit(limit).exclude(data_publicacao: nil).reverse(:data_criacao)
    end

    def all_by_autor(autor_id, limit = 10)
      where(autor_id: autor_id).limit(limit).reverse(:data_criacao)
    end

    def all_by_situacao(chave, limit = 10)
      where(situacao: chave).limit(limit).reverse(:data_atualizacao)
    end

    def all_by_situacao_categoria(chave, categoria_id, limit = 10)
      join(:categoria, id: categoria_id).where(situacao: chave).limit(limit).reverse(:data_atualizacao)
    end

    def search(termo, limit = 10)
      regexp_like(titulo: termo, texto_oportunidade: termo, texto_solucao: termo).limit(limit).reverse(:data_atualizacao)
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
