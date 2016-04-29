# encoding: utf-8

class Prodam::Idealize::Criterio < Prodam::Idealize::Model[:criterio]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  one_to_one :formulario

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
