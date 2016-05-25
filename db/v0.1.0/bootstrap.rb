require 'prodam/idealize'

include Prodam::Idealize

yaml = YAML.load_file('db/v0.1.0/bootstrap.yml')

yaml[:usuarios].each do |data|
  senha = '_' + data[:nome_usuario]
  usuario = Usuario.new(data)
  usuario.save_password(senha, senha)
  no_errors = usuario.errors.empty?
  printf("- %-32s %s\n", usuario.nome, no_errors ? :ok : :error)
end
