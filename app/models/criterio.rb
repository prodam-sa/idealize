# encoding: utf-8

module Prodam::Idealize

class Criterio < Model[:criterio]
  plugin :validation_helpers

  many_to_one :formulario
  one_to_many :subcriterios, class: self, key: :criterio_multiplo_id
  many_to_one :criterio, class: self, key: :criterio_multiplo_id

  attr_accessor :resposta

  def validate
    super
    validates_presence :titulo, message: 'deve ser atribuído'
    validates_unique [:titulo, :criterio_multiplo_id], message: 'já registrado'
    validates_max_length 64, :titulo, message: lambda{ |n| "deve ser de até #{n} caracteres" }

    validates_presence :descricao, message: 'deve ser preenchido'
    validates_max_length 256, :descricao, message: lambda{ |n| "deve ser de até #{n} caracteres" }
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end

end # module
