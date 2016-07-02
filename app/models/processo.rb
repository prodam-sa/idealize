# encoding: utf-8

module Prodam::Idealize

class Processo < Situacao
  one_to_one :formulario
end

end # module

