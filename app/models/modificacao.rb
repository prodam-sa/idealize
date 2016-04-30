# encoding: utf-8

class Prodam::Idealize::Modificacao < Prodam::Idealize::Historico
  many_to_one :ideia
end
