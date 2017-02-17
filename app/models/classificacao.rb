# encoding: utf-8

module Prodam::Idealize

class Classificacao < Model[:classificacao]
  plugin :validation_helpers

  one_to_many :avaliacoes
  many_to_many :premiacoes, join_table: :classificacao_premiacao

  def validate
    super
    validates_presence :titulo, message: 'deve ser atribuído'
    validates_max_length 64, :titulo, message: lambda{ |n| "deve ser de até #{n} caracteres" }

    validates_presence :descricao, message: 'deve ser preenchido'
    validates_max_length 256, :descricao, message: lambda{ |n| "deve ser de até #{n} caracteres" }

    validates_presence :ponto_minimo, message: 'deve ser atribuído'
    validates_presence :ponto_maximo, message: 'deve ser atribuído'
    validates_presence :pontuacao, message: 'deve ser atribuído'
  end

  def param_name
    "#{id}-#{titulo.downcase.tr(' ', '-')}"
  end

  class << self
    def pontuacao(valor)
      where(':valor >= ponto_minimo AND :valor <= ponto_maximo', valor: valor)
    end
  end
end

end # Prodam::Idealize
