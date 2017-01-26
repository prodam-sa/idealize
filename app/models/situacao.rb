# encoding: utf-8

module Prodam::Idealize

class Situacao < Model[:situacao]
  include Model

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

  def restrito?
    self[:restrito] == 'S'
  end
  alias restrita? restrito?

  class << self
    def chave(nome)
      where(chave: nome.to_s).first
    end

    def all_by_sem_restricao(*fields)
      where(restrito: 'N').select(*fields).all
    end
  end
end

end # module
