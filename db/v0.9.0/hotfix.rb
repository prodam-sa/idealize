require 'prodam/idealize'

include Prodam::Idealize

Ideia.all.each do |ideia|
  ideia.situacao = ideia.modificacao.situacao.chave
  ideia.save_changes
end
