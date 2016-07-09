# encoding: utf-8

module Prodam::Idealize

module AvaliacaoHelper
  def classificacao(pontos)
    Classificacao.pontuacao(pontos).first
  end
end

end # Prodam::Idealize
