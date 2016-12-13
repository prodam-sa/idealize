# encoding: utf-8

module Prodam::Idealize

class Relatorio
  SQL = {
    total_ideias_por_data_postagem: 'SELECT TRUNC(data_criacao) AS data_criacao, COUNT(*) AS total FROM ideia GROUP BY TRUNC(data_criacao)',
    total_coautores_por_ideia: 'SELECT ideia_id, COUNT(coautor_id) AS total FROM ideia_coautor GROUP BY ideia_id',
    total_apoiadores_por_ideia: 'SELECT ideia_id, COUNT(apoiador_id) AS total FROM ideia_apoiador GROUP BY ideia_id',
    total_ideias_por_categoria: 'SELECT categoria_id, COUNT(ideia_id) AS total FROM  ideia_categoria GROUP BY categoria_id',
    total_ideias_sem_categoria: 'SELECT COUNT(id) AS total FROM ideia WHERE id NOT IN (SELECT DISTINCT ideia_id FROM ideia_categoria)',
    total_ideias_por_situacao: 'SELECT s.id AS situacao_id, COUNT(i.id) AS total FROM ideia i INNER JOIN situacao s ON (s.chave = i.situacao) GROUP BY s.id',
    total_ideias_por_autor: 'SELECT a.id AS autor_id, i.id AS ideia_id, COUNT(i.id) AS total FROM usuario a INNER JOIN ideia i ON (i.autor_id = a.id) GROUP BY a.id ORDER BY COUNT(i.id)',
    total_ideias_por_autor_situacao: 'SELECT a.id AS autor_id, s.id AS situacao_id, COUNT(i.id) AS total FROM usuario a INNER JOIN ideia i ON (i.autor_id - a.id) GROUP BY a.id',
    ideias_por_autor: '
      SELECT usuario.id AS autor_id
           , usuario.nome AS autor_nome
           , ideia.id AS ideia_id
           , ideia.titulo AS ideia_titulo
           , classificacao.titulo AS classificacao_titulo
           , avaliacao.pontos AS avaliacao_pontos
           , classificacao.descricao AS classificacao_descricao
        FROM usuario
        INNER JOIN ideia ON (ideia.autor_id = usuario.id)
        INNER JOIN avaliacao ON (avaliacao.ideia_id = ideia.id)
        INNER JOIN classificacao ON (classificacao.id = avaliacao.classificacao_id)'
  }.freeze

  attr_accessor :autor
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

  # Categorias
  def total_ideias_por_categoria
    @total_ideias_por_categoria || total_ideias_por_categoria!
  end

  def total_ideias_por_categoria!
    @total_ideias_por_categoria = {}
    Database[SQL[:total_ideias_por_categoria]].all.map do |row|
      @total_ideias_por_categoria[row[:categoria_id]] = row[:total].to_i
    end
    @total_ideias_por_categoria
  end

  def total_ideias_sem_categoria
    @total_ideias_sem_categoria || total_ideias_sem_categoria!
  end

  def total_ideias_sem_categoria!
    @total_ideias_sem_categoria = Database[SQL[:total_ideias_sem_categoria]].first[:total].to_i
  end

  # Situações
  def total_ideias_por_situacao
    @total_ideias_por_situacao || total_ideias_por_situacao!
  end

  def total_ideias_por_situacao!
    @total_ideias_por_situacao = {}
    Database[SQL[:total_ideias_por_situacao]].all.map do |row|
      @total_ideias_por_situacao[row[:situacao_id]] = row[:total].to_i
    end
    @total_ideias_por_situacao
  end

  # Ideias por autor
  def total_ideias_por_autor
    @total_ideias_por_situacao || total_ideias_por_situacao!
  end

  def total_ideias_por_autor!
    @total_ideias_por_autor = {}
    Database[SQL[:total_ideias_por_autor]].all.map do |row|
      @total_ideias_por_autor[row[:autor_id]] = row[:total].to_i
    end
    @total_ideias_por_autor
  end

  # Ideias por data de criação/postagem
  def total_ideias_por_data_postagem
    @total_ideias_por_data_postagem || total_ideias_por_data_postagem!
  end

  def total_ideias_por_data_postagem!
    @total_ideias_por_data_postagem = {}
    Database[SQL[:total_ideias_por_data_postagem]].all.map do |row|
      @total_ideias_por_data_postagem[row[:data_criacao]] = row[:total].to_i
    end
    @total_ideias_por_data_postagem
  end

  def ideias_por_autor
    @ideias_por_autor || ideias_por_autor!
  end

  def ideias_por_autor!
    @ideias_por_autor = Database[SQL[:ideias_por_autor]].all.group_by do |row|
      [ row[:autor_id], row[:autor_nome] ]
    end
  end
end

end # Prodam::Idealize
