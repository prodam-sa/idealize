# encoding: utf-8

class Prodam::Idealize::Historico < Prodam::Idealize::Model[:historico]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  many_to_one :ideia
  many_to_one :situacao

  def validate
    super
    validates_presence :descricao, message: 'deve ser preenchido.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end
end
