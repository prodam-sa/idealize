# encoding: utf-8

class Prodam::Idealize::Categoria < Prodam::Idealize::Model[:categoria]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  def validate
    super
    validates_presence :titulo, message: 'não foi atribuído.'
    validates_unique :titulo, message: 'já registrado.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end
