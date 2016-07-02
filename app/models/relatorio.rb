# encoding: utf-8

module Prodam::Idealize

class Relatorio
  SQL = {
    total_coautores_por_ideia: 'SELECT ideia_id, COUNT(coautor_id) AS total FROM ideia_coautor GROUP BY ideia_id',
    total_apoiadores_por_ideia: 'SELECT ideia_id, COUNT(apoiador_id) AS total FROM ideia_apoiador GROUP BY ideia_id'
  }.freeze

  attr_accessor :ideia
  attr_accessor :ideias

  def initialize(atributos = {})
    atributos.each do |atributo, valor|
      send("#{atributo}=", valor)
    end
  end

  # Coautores
  def total_coautores_por_ideia
    @total_coautores_por_ideia || total_coautores_por_ideia!
  end

  def total_coautores_por_ideia!
    @total_coautores_por_ideia = {}
    Database[SQL[:total_coautores_por_ideia]].all.map do |row|
      @total_coautores_por_ideia[row[:ideia_id]] = row[:total].to_i
    end
    @total_coautores_por_ideia
  end

  def lista_coautores_ideia(ideia = nil)
    ideia && (@ideia = ideia) && lista_coautores_ideia!
    @lista_coautores_ideia || lista_coautores_ideia!
  end

  def lista_coautores_ideia!
    @lista_coautores_ideia = @ideia && Database[:ideia_coautor].
      select(:coautor_id).
      where(ideia_id: @ideia.id).
      all.map do |row|
        row[:coautor_id]
      end
  end

  def lista_ideias_coautores(ideias = nil)
    ideias && (@ideias = ideias) && lista_ideias_coautores!
    @lista_ideias_coautores || lista_ideias_coautores!
  end

  def lista_ideias_coautores!
    @lista_ideias_coautores = {}
    @ideias && Database[:ideia_coautor].where(ideia_id: @ideias.map(&:id)).each do |row|
      @lista_ideias_coautores[row[:ideia_id]] ||= []
      @lista_ideias_coautores[row[:ideia_id]] << row[:coautor_id]
    end
    @lista_ideias_coautores
  end

  # Apoiadores
  def total_apoiadores_por_ideia
    @total_apoiadores_por_ideia || total_apoiadores_por_ideia!
  end

  def total_apoiadores_por_ideia!
    @total_apoiadores_por_ideia = {}
    Database[SQL[:total_apoiadores_por_ideia]].all.map do |row|
      @total_apoiadores_por_ideia[row[:ideia_id]] = row[:total].to_i
    end
    @total_apoiadores_por_ideia
  end

  def lista_apoiadores_ideia(ideia = nil)
    ideia && (@ideia = ideia) && lista_apoiadores_ideia!
    @lista_apoiadores_ideia || lista_apoiadores_ideia!
  end

  def lista_apoiadores_ideia!
    @lista_apoiadores_ideia = @ideia && Database[:ideia_apoiador].
      select(:apoiador_id).
      where(ideia_id: @ideia.id).
      all.map do |row|
        row[:apoiador_id]
      end
  end

  def lista_ideias_apoiadores(ideias = nil)
    ideias && (@ideias = ideias) && lista_ideias_apoiadores!
    @lista_ideias_apoiadores || lista_ideias_apoiadores!
  end

  def lista_ideias_apoiadores!
    @lista_ideias_apoiadores = {}
    @ideias && Database[:ideia_apoiador].where(ideia_id: @ideias.map(&:id)).each do |row|
      @lista_ideias_apoiadores[row[:ideia_id]] ||= []
      @lista_ideias_apoiadores[row[:ideia_id]] << row[:apoiador_id]
    end
    @lista_ideias_apoiadores
  end
end

end # Prodam::Idealize
