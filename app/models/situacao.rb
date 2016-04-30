# encoding: utf-8

class Prodam::Idealize::Situacao < Prodam::Idealize::Model[:situacao]
  include Prodam::Idealize::Model

  plugin :validation_helpers

  def validate
    super
    validates_presence :titulo, message: 'não foi atribuído.'
    validates_presence :descricao, message: 'deve ser preenchido.'
    validates_unique :titulo, message: 'já registrado.'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end

  class << self
    def chave(nome)
      where(chave: nome.to_s).first
    end
  end
end
