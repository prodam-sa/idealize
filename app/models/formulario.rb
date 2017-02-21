# encoding: utf-8

module Prodam::Idealize

class Formulario < Model[:formulario]
  plugin :validation_helpers

  one_to_many :criterios
  many_to_one :processo

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
