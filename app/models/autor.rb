# encoding: utf-8

module Prodam::Idealize

class Autor < Usuario
  one_to_many :ideias
  many_to_many :contribuicoes,
    class: Ideia,
    join_table: :ideia_coautor,
    left_key: :coautor_id,
    right_key: :ideia_id

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
