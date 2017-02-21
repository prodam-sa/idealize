# encoding: utf-8

module Prodam::Idealize

class Processo < Situacao
  one_to_one :formulario
  one_to_many :situacoes

  def bloqueia?
    self[:bloqueia] =~ /S/i && true || false
  end

  def self.find_by_chave(chave)
    where(chave: chave).eager(:situacoes).all.first
  end
end

end # module
