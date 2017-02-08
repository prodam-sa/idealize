# encoding: utf-8

module Prodam::Idealize

class Processo < Situacao
  one_to_one :formulario
  one_to_many :situacoes

  def bloqueia?
    self[:bloqueia] =~ /S/i && true || false
  end
end

end # module
