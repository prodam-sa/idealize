# encoding: utf-8

class Prodam::Idealize::Ideia < Prodam::Idealize::Model[:ideia]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  many_to_one :author
  many_to_many :categorias, join_table: :ideia_categoria

  def validate
    super
    validates_presence :titulo, message: 'deve ser atribuído.'
    validates_unique :titulo, message: 'já existe.'

    validates_presence :texto_oportunidade, message: 'deve conter algum conteúdo.'
    validates_presence :texto_solucao, message: 'deve conter algum conteúdo.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end

  class << self
    def latest(limit = 10)
      reverse(:data_criacao).limit(limit).all
    end

    def all_by_autor(autor_id, limit = 10)
      where(autor_id: autor_id).reverse(:data_criacao).limit(limit).all
    end
  end
end
