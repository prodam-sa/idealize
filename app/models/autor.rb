# encoding: utf-8

module Prodam::Idealize

class Autor < Usuario
  one_to_many :ideias

  def pontuacao_ranking
    if ideias && ideias.any? && @pontuacao_ranking.nil?
      @pontuacao_ranking = 0
      ideias.map do |ideia|
        ideia.avaliacao && @pontuacao_ranking += ideia.avaliacao.pontos
      end
    end
    @pontuacao_ranking
  end

  def self.find_by_id(id)
    eager(ideias: [:situacao, :avaliacao]).where(id: id).all.first
  end
end

end # module
