require 'prodam/idealize'

include Prodam::Idealize

@yaml = YAML.load_file('db/v0.15.0/bootstrap.yml')
@admin = Usuario[1]

chaves = @yaml[:processos].map do |data|
  data[:chave]
end.flatten.uniq

@processos = Processo.find_by_chaves(*chaves).all.each_with_object Hash.new do |processo, processos|
  processos[processo.chave] = processo
end

@yaml[:situacoes][:insercao].each do |data|
  Situacao.find_or_create data
end

chaves = @yaml[:situacoes][:atualizacao].map do |data|
  [data[:chave], data[:oposta], data[:seguinte]].compact
end.flatten.uniq

@situacoes = Situacao.find_by_chaves(*chaves).all.each_with_object Hash.new do |situacao, situacoes|
  situacoes[situacao.chave] = situacao
end

@yaml[:processos].each do |data|
  @processos[data[:chave]] && @processos[data[:chave]].set_all(data).save
end

@yaml[:situacoes][:atualizacao].each do |data|
  situacao = @situacoes[data[:chave]]
  (processo = @processos[data[:processo]]) && (situacao.processo = processo)
  (oposta = @situacoes[data[:oposta]]) && (situacao.oposta = oposta)
  (seguinte = @situacoes[data[:seguinte]]) && (situacao.seguinte = seguinte)
  situacao.update(rotulo: data[:rotulo], bloqueia: data[:bloqueia])
end

Ideia.find_by_situacao('avaliacao').eager(:avaliacao).each do |ideia|
  if ideia.avaliacao && ideia.situacao.chave == 'avaliacao'
    ideia.add_modificacao(Modificacao.new(responsavel: @admin, descricao: "Atualização da situação de '#{ideia.situacao.titulo}' para '#{ideia.situacao.seguinte.titulo}' por atualização do sistema v0.15.0."))
    ideia.update(situacao: ideia.situacao.seguinte, bloqueada: ideia.situacao.seguinte.bloqueia)
  end
  ideia.update(bloqueada: ideia.situacao.bloqueia)
end

@yaml[:premiacoes].each do |data|
  pontuacoes = data.delete(:pontuacoes)
  premiacao = Premiacao.new(data)
  premiacao.save
  Classificacao.where(ponto_maximo: pontuacoes).all.each do |classificacao|
    premiacao.add_classificacao(classificacao)
  end
end
