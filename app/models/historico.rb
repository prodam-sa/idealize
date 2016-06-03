# encoding: utf-8

module Prodam::Idealize

class Historico < Model[:historico]
  include Model

  plugin :validation_helpers

  many_to_one :ideia
  many_to_one :situacao
  many_to_one :responsavel, {
    class: Usuario,
    key: :responsavel_id
  }

  def validate
    super
    validates_presence :descricao, message: 'deve ser preenchido.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end

end # module
