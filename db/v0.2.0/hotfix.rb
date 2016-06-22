require 'prodam/idealize'

include Prodam::Idealize

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
