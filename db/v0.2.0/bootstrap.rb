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

Ideia.latest.each do |ideia|
  situacao = Situacao.chave :rascunho
  modificacao = Modificacao.new ideia_id: ideia.id,
                                situacao_id: situacao.id,
                                responsavel_id: ideia.autor_id,
                                destinatario_id: ideia.autor_id,
                                data_registro: ideia.data_publicacao,
                                descricao: 'Ideia postada pelo autor.'
  modificacao.save
  ideia.data_publicacao = nil
  ideia.data_atualizacao = Time.now
  ideia.add_modificacao modificacao
  ideia.save
end
