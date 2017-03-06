# encoding: utf-8

module Prodam::Idealize

class Historico < Model[:historico]
  plugin :validation_helpers

  many_to_one :ideia
  many_to_one :situacao
  many_to_one :responsavel, {
    class: Usuario,
    key: :responsavel_id
  }

  def validate
    super
    validates_presence :ideia_id, message: 'deve ser associado'
    validates_presence :situacao_id, message: 'deve ser associado'
    validates_presence :responsavel_id, message: 'deve ser associado'
    validates_presence :descricao, message: 'deve ser preenchida'
    validates_max_length 1024, :descricao, message: lambda{ |n| "deve ser de até #{n} caracteres" }
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end

  def self.find_by_ideia(ideia)
    where(ideia_id: ideia.id).eager(:situacao, :responsavel).reverse(:data_registro)
  end
end

end # module
