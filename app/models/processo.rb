# encoding: utf-8

module Prodam::Idealize

class Processo < Model[:processo]
  one_to_one :formulario
  one_to_many :situacoes

  def bloqueia?
    self[:bloqueia] =~ /s/i && true || false
  end
end

end # module

