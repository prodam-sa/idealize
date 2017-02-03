# encoding: utf-8

module Prodam::Idealize

class Processo < Model[:processo]
  one_to_one :formulario
  one_to_many :situacoes
end

end # module

