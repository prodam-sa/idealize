# encoding: utf-8

module Prodam::Idealize

class CriterioMultiplo < Criterio
  many_to_one :formulario
  one_to_many :criterios
end

end # Prodam::Idealize
