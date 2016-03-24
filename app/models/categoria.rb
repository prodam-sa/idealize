# encoding: utf-8

class Prodam::Idealize::Categoria < Prodam::Idealize::Model[:categoria]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  many_to_many :ideias, join_table: :ideia_categoria

  def validate
    super
    validates_presence :titulo, message: 'não foi atribuído.'
    validates_presence :descricao, message: 'deve ser preenchido.'
    validates_unique :titulo, message: 'já registrado.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end
