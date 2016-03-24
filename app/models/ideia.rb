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

  def rascunho?
    self[:data_publicacao].nil?
  end

  def publicar!
    self[:data_publicacao] = Time.now
    save
  end

  def before_save
    self[:data_atualizacao] = Time.now
  end

  class << self
    def latest(limit = 10)
      exclude(data_publicacao: nil).reverse(:data_criacao).limit(limit).all
    end

    def all_by_autor(autor_id, limit = 10)
      where(autor_id: autor_id).reverse(:data_criacao).limit(limit).all
    end
  end
end
