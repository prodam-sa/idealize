# encoding: utf-8

module Prodam::Idealize

class Avaliacao < Model[:avaliacao]
  plugin :validation_helpers

  def validate
    super
    validates_presence :pontos, message: 'deve ser atribuído'
  end

  many_to_one :ideia
  many_to_one :classificacao

  def self.find_by_situacao_data(situacao, data_inicial, data_final = data_inicial)
    eager(:ideia, :classificacao).
    join(:ideia, id: :avaliacao__ideia_id).
    join(:classificacao, id: :avaliacao__classificacao_id).
    where("ideia.situacao = ?", situacao.to_s).
    where("TRUNC(ideia.data_publicacao) >= DATE'#{data_inicial}'").
    where("TRUNC(ideia.data_publicacao) <= DATE'#{data_final}'")
  end
end

end # Prodam::Idealize
