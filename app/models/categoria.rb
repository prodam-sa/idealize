# encoding: utf-8

class Prodam::Idealize::Categoria < Prodam::Idealize::Model[:categoria]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  many_to_many :ideias, join_table: :ideia_categoria

  def validate
    super
    validates_presence :titulo, message: 'não foi atribuído.'
    validates_unique :titulo, message: 'já registrado.'
    validates_max_length 64, :titulo, message: lambda{ |n| "deve ser de até #{n} caracteres." }
    validates_presence :descricao, message: 'deve ser preenchido.'
    validates_max_length 256, :descricao, message: lambda{ |n| "deve ser de até #{n} caracteres." }
  end

  def ideias_publicadas
    ideias_dataset.where.exclude(data_publicacao: nil)
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end
