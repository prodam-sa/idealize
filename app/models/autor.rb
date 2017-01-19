# encoding: utf-8

module Prodam::Idealize

class Autor < Usuario
  one_to_many :ideias

  def self.find_by_id(id)
    eager(ideias: :avaliacao).where(id: id).all.first
  end
end

end # module
