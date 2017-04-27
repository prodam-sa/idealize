# encoding: utf-8

module Prodam::Idealize

class Relatorio
  SQL = {
    total_ideias_por_data_criacao: "
      SELECT TRUNC(data_criacao) AS data_criacao
           , COUNT(*) AS total
        FROM ideia
        %s
        GROUP BY TRUNC(data_criacao)
        ORDER BY TRUNC(data_criacao) DESC",
    total_ideias_por_data_publicacao: "
      SELECT TRUNC(data_publicacao) AS data_publicacao
           , COUNT(*) AS total
        FROM ideia
        %s
        GROUP BY TRUNC(data_publicacao)
        ORDER BY TRUNC(data_publicacao) DESC",
    total_coautores_por_ideia: "
      SELECT ideia_id
           , COUNT(coautor_id) AS total
        FROM ideia
        INNER JOIN ideia_coautor ON (ideia_coautor.ideia_id = ideia.id)
        %s
        GROUP BY ideia_id
        ORDER BY COUNT(coautor_id) DESC",
    total_apoiadores_por_ideia: "
      SELECT ideia_id
           , COUNT(apoiador_id) AS total
        FROM ideia
        INNER JOIN ideia_apoiador ON (ideia_apoiador.ideia_id = ideia.id)
        %s
        GROUP BY ideia_id
        ORDER BY COUNT(apoiador_id) DESC",
    total_ideias_por_categoria: "
      SELECT categoria_id
           , COUNT(ideia_id) AS total
        FROM ideia
        INNER JOIN ideia_categoria ON (ideia_categoria.ideia_id = ideia.id)
        %s
        GROUP BY categoria_id",
    total_ideias_sem_categoria: "
      SELECT COUNT(id) AS total
        FROM ideia
        FULL OUTER JOIN ideia_categoria ON (ideia_categoria.ideia_id = ideia.id)
        %s",
    total_ideias_por_situacao: "
      SELECT situacao.chave
           , COUNT(ideia.id) AS total
        FROM situacao
        FULL JOIN ideia ON (ideia.situacao_id = situacao.id)
        %s
        GROUP BY situacao.chave",
    total_ideias_por_autor: "
      SELECT ideia.autor_id
           , COUNT(*) AS total
        FROM ideia
        %s
        GROUP BY ideia.autor_id
        ORDER BY COUNT(*) DESC",
    total_ideias_por_autor_situacao: "
      SELECT usuario.id AS autor_id
           , situacao.id AS situacao_id
           , COUNT(ideia.id) AS total
        FROM ideia
        INNER JOIN usuario ON (usuario.id = ideia.autor_id)
        %s
        GROUP BY usuario.id",
    ideias_por_autor: "
      SELECT usuario.id AS autor_id
           , usuario.nome AS autor_nome
           , ideia.id AS ideia_id
           , ideia.titulo AS ideia_titulo
           , classificacao.titulo AS classificacao_titulo
           , avaliacao.pontos AS avaliacao_pontos
           , classificacao.descricao AS classificacao_descricao
        FROM ideia
        INNER JOIN usuario ON (usuario.id = ideia.autor_id)
        INNER JOIN avaliacao ON (avaliacao.ideia_id = ideia.id)
        INNER JOIN classificacao ON (classificacao.id = avaliacao.classificacao_id)
        %s",
    ranking: "
      SELECT autor_id
           , autor_nome
           , SUM(total_premiacoes) AS total_premiacoes
           , SUM(total_contribuicoes) AS total_contribuicoes
           , SUM(total_pontos) AS total_pontos
        FROM (
          SELECT usuario.id AS autor_id
               , usuario.nome AS autor_nome
               , COUNT(ideia.id) AS total_premiacoes
               , 0 AS total_contribuicoes
               , SUM(avaliacao.pontos) AS total_pontos
            FROM ideia
            INNER JOIN usuario ON (usuario.id = ideia.autor_id)
            INNER JOIN avaliacao ON (avaliacao.ideia_id = ideia.id)
            GROUP BY usuario.id
                   , usuario.nome
          UNION
          SELECT ideia_coautor.coautor_id AS autor_id
               , usuario.nome AS autor_nome
               , 0 AS total_premiacoes
               , COUNT(ideia_coautor.ideia_id) AS total_contribuicoes
               , SUM(avaliacao.pontos) AS total_pontos
            FROM ideia
            INNER JOIN ideia_coautor ON (ideia_coautor.ideia_id = ideia.id)
            INNER JOIN usuario ON (usuario.id = ideia_coautor.coautor_id)
            INNER JOIN avaliacao ON (avaliacao.ideia_id = ideia.id)
            GROUP BY ideia_coautor.coautor_id
                   , usuario.nome
        )
        %s
        GROUP BY autor_id
               , autor_nome
        ORDER BY total_pontos DESC",
  }.freeze

  attr_accessor :autor
  attr_accessor :ideia
  attr_accessor :ideias
  attr_accessor :data_inicial, :data_final

  def initialize(atributos = {})
    atributos.each do |atributo, valor|
      send("#{atributo}=", valor)
    end
  end

  def total_ideias
    Ideia.count.to_i
  end

  # Coautores
  def total_coautores_por_ideia
    @total_coautores_por_ideia || total_coautores_por_ideia!
  end

  def total_coautores_por_ideia!
    @total_coautores_por_ideia = {}
    Database[sql :total_coautores_por_ideia, filtro_por_data].all.map do |row|
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
  alias total_ideias_por_apoiadores total_apoiadores_por_ideia

  def total_apoiadores_por_ideia!
    @total_apoiadores_por_ideia = {}
    Database[sql :total_apoiadores_por_ideia, filtro_por_data].all.map do |row|
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
    Database[sql :total_ideias_por_categoria, filtro_por_data].all.map do |row|
      @total_ideias_por_categoria[row[:categoria_id]] = row[:total].to_i
    end
    @total_ideias_por_categoria
  end

  def total_ideias_sem_categoria
    @total_ideias_sem_categoria || total_ideias_sem_categoria!
  end

  def total_ideias_sem_categoria!
    @total_ideias_sem_categoria = Database[sql :total_ideias_sem_categoria, filtro_por_data].first[:total].to_i
  end

  # Situações
  def total_ideias_por_situacao
    @total_ideias_por_situacao || total_ideias_por_situacao!
  end

  def total_ideias_por_situacao!
    @total_ideias_por_situacao = {}
    Database[sql :total_ideias_por_situacao, filtro_por_data(:criacao)].all.map do |row|
      @total_ideias_por_situacao[row[:chave].to_sym] = row[:total].to_i
    end
    @total_ideias_por_situacao
  end

  # Ideias por autor
  def total_ideias_por_autor
    @total_ideias_por_autor || total_ideias_por_autor!
  end

  def total_ideias_por_autor!
    @total_ideias_por_autor = {}
    Database[sql :total_ideias_por_autor, filtro_por_data].all.map do |row|
      @total_ideias_por_autor[row[:autor_id]] = row[:total].to_i
    end
    @total_ideias_por_autor
  end

  # Ideias por data de criação/postagem
  def total_ideias_por_data_criacao
    @total_ideias_por_data_criacao || total_ideias_por_data_criacao!
  end

  def total_ideias_por_data_criacao!
    @total_ideias_por_data_criacao = {}
    Database[sql :total_ideias_por_data_criacao, filtro_por_data(:criacao)].all.map do |row|
      @total_ideias_por_data_criacao[row[:data_criacao].to_date] = row[:total].to_i
    end
    @total_ideias_por_data_criacao
  end

  def total_ideias_por_data_publicacao
    @total_ideias_por_data_publicacao || total_ideias_por_data_publicacao!
  end

  def total_ideias_por_data_publicacao!
    @total_ideias_por_data_publicacao = {}
    Database[sql :total_ideias_por_data_publicacao, filtro_por_data].all.map do |row|
      @total_ideias_por_data_publicacao[row[:data_publicacao].to_date] = row[:total].to_i if row[:data_publicacao]
    end
    @total_ideias_por_data_publicacao
  end

  def ideias_por_autor
    @ideias_por_autor || ideias_por_autor!
  end

  def ideias_por_autor!
    @ideias_por_autor = Database[sql :ideias_por_autor, filtro_por_data].all.group_by do |row|
      [ row[:autor_id], row[:autor_nome] ]
    end
  end

  def ranking
    @ranking || ranking!
  end

  def ranking!
    @ranking = Database[sql :ranking].all.each_with_index do |row, i|
      row[:classificacao] = i + 1
      row[:to_url_param] = ("#{row[:autor_id]}-#{row[:autor_nome]}").gsub(/\W/, '-').sub(/-$/,'').squeeze('-').downcase
      row[:total_premiacoes] = row[:total_premiacoes].to_i
      row[:total_contribuicoes] = row[:total_contribuicoes].to_i
      row[:total_pontos] = row[:total_pontos].to_i
    end
  end

  def ranking_autor(autor = @autor)
    autor && @ranking_autor ||= ranking.select do |info|
      info[:autor_id] == autor.id
    end.first || {
      colocacao: nil,
      autor_id: nil,
      autor_nome: nil,
      to_url_param: nil,
      total_premiacoes: 0,
      total_contribuicoes: 0,
      total_pontos: 0
    }
    @ranking_autor
  end

private

  def filtro_por_data(nome = :publicacao)
    "WHERE (TRUNC(ideia.data_#{nome}) >= DATE'#{data_inicial}') AND (TRUNC(ideia.data_#{nome}) <= DATE'#{data_final}')" if data_inicial
  end

  def sql(key, filter = nil)
    format(SQL[key], (filter || ''))
  end
end

end # Prodam::Idealize
