# encoding: utf-8

module Prodam::Idealize

class Formulario < Model[:formulario]
  include Model

  plugin :validation_helpers

  one_to_many :criterios

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

end # module
