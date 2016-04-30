require 'prodam/idealize'

include Prodam::Idealize

yaml = YAML.load_file('db/v0.2.0/bootstrap.yml')

yaml[:formularios].each do |data|
  formulario = Formulario.new(titulo: data[:titulo], descricao: data[:descricao])
  formulario.save
  if formulario.errors.empty?
    data[:criterios].each do |item|
      criterio = Criterio.new(titulo: item[:titulo], descricao: item[:descricao])
      criterio.formulario_id = formulario.id
      criterio.save
    end
  else
    printf("- %-32s %s", formulario.titulo, :error)
  end
end

yaml[:situacoes].each do |data|
  situacao = Situacao.new(data)
  situacao.save
  if !situacao.errors.empty?
    printf("- %-32s %s", situacao.titulo, :error)
  end
end

Ideia.all.each do |ideia|
  modificacao = Modificacao.new responsavel_id: ideia.autor_id
  if ideia.data_publicacao
    situacao = Situacao.chave :postagem
    modificacao.data_registro = ideia.data_publicacao
    modificacao.descricao = 'Ideia postada pelo autor.'
    ideia.data_publicacao = nil
    ideia.situacao = 'postagem'
  else
    situacao = Situacao.chave :rascunho
    modificacao.data_registro = ideia.data_criacao
    modificacao.descricao = 'Ideia criada pelo autor.'
    ideia.situacao = 'rascunho'
  end
  modificacao.situacao = situacao
  modificacao.save
  ideia.add_modificacao modificacao
  ideia.save
end
