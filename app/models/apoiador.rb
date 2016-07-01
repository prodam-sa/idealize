# encoding: utf-8

module Prodam::Idealize

class Apoiador < Usuario
  many_to_many :ideias
end

end # module
