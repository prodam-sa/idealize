require 'prodam/idealize'

include Prodam::Idealize

yaml = YAML.load_file('db/v0.13.0/bootstrap.yml')

yaml[:classificacoes].each do |classificacao|
  @classificacao = Classificacao.new(classificacao)

  if @classificacao.valid?
    @classificacao.save
  else
    printf("- %-32s %s", @classificacao.titulo, :error)
    puts @classificacao.errors
  end
end
