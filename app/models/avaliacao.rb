# encoding: utf-8

module Prodam::Idealize

class Avaliacao < Model[:avaliacao]
  include Model

  plugin :validation_helpers

  def validate
    super
    validates_presence :pontos, message: 'deve ser atribuído'
  end

  many_to_one :ideia
  many_to_one :classificacao
end

end # Prodam::Idealize
