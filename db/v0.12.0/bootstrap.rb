require 'prodam/idealize'

include Prodam::Idealize

yaml = YAML.load_file('db/v0.12.0/bootstrap.yml')

@moderacao = Formulario.first

@moderacao.processo = Processo.chave(:moderacao)
@moderacao.save

yaml[:formularios].each do |formulario|
  @processo   = Processo.chave(formulario[:processo])
  @formulario = Formulario.new(titulo: formulario[:titulo], descricao: formulario[:descricao], processo: @processo)

  if @formulario.valid?
    @formulario.save

    formulario[:criterios_multiplos].each do |criterio_multiplo|
      @criterio_multiplo = CriterioMultiplo.new(titulo: criterio_multiplo[:titulo], descricao: criterio_multiplo[:descricao])
      @criterio_multiplo.formulario = @formulario
      @criterio_multiplo.save

      criterio_multiplo[:criterios].each do |criterio|
        @criterio = Criterio.new(titulo: criterio[:titulo], descricao: criterio[:descricao], peso: criterio[:peso])
        @criterio.criterio_multiplo = @criterio_multiplo
        @criterio.save
      end
    end
  else
    printf("- %-32s %s", @formulario.titulo, :error)
    puts @formulario.errors
  end
end
