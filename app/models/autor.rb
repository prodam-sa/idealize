# encoding: utf-8

module Prodam::Idealize

class Autor < Usuario
  one_to_many :ideias
end

end # module
