require 'prodam/idealize'

include Prodam::Idealize

Ideia.all.each do |ideia|
  ideia.situacao = ideia.modificacao.situacao.chave

  if ideia.situacao == 'publicacao'
    ideia.data_publicacao = ideia.modificacao.data_registro
    ideia.bloquear!
  end

  ideia.bloquear! if ideia.publicada?

  ideia.save_changes
end
