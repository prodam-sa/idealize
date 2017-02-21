# encoding: utf-8

module Prodam::Idealize

class Premiacao < Model[:premiacao]
  many_to_many :classificacoes, join_table: :classificacao_premiacao
end

end # module
