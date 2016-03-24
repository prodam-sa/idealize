# encoding: utf-8

class Prodam::Idealize::Autor < Prodam::Idealize::Usuario
  one_to_many :ideias
end
