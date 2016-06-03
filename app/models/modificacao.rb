# encoding: utf-8

module Prodam::Idealize

class Modificacao < Historico
  many_to_one :ideia
end

end # module
