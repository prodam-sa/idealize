# encoding: utf-8

module Prodam::Idealize

class Relatorio
  class << self
    def total_coautores_ideia
      @total = {}
      Database[%q{SELECT ideia_id, COUNT(coautor_id) AS total FROM ideia_coautor GROUP BY ideia_id}].all.map do |row|
        @total[row[:ideia_id]] = row[:total].to_i
      end
      @total
    end
  end
end

end # Prodam::Idealize
