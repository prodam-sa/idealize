# encoding: utf-8

module Prodam::Idealize

class Situacao < Model[:situacao]
  one_to_many :ideias
  many_to_one :processo, class: self
  many_to_one :oposta, class: self
  many_to_one :seguinte, class: self

  plugin :validation_helpers

  def validate
    super
    validates_presence :titulo, message: 'não foi atribuído.'
    validates_presence :descricao, message: 'deve ser preenchido.'
    validates_unique :titulo, message: 'já registrado.'
  end

  def param_name
    "#{id}-#{chave}"
  end

  def restrita?
    self[:restrita] == 'S'
  end

  class << self
    def chave(nome)
      where(chave: nome.to_s).eager(:processo, :oposta, :seguinte).all.first
    end

    def find_by_chaves(*chaves)
      where(chave: chaves.map(&:to_s)).eager(:processo, :oposta, :seguinte)
    end
    alias find_by_chave find_by_chaves

    def all_by_sem_restricao(*fields)
      where(restrita: 'N').select(*fields).all
    end
  end
end

end # module
