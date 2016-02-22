describe 'Usuário' do
  before do
    Prodam::Idealize::Usuario.where(nome_usuario: 'p001051').delete
  end

  it 'cria uma nova conta' do
    usuario = Prodam::Idealize::Usuario.new nome_usuario: 'p001051', nome: 'Hallison Batista', email: 'hallison@localhost.local'
    assert usuario.valid?
    assert_equal 0, usuario.errors.size

    usuario.save senha: 's3kr3t4'

    usuario = Prodam::Idealize::Usuario.find nome_usuario: 'p001051'
    assert usuario
  end

  it 'consulta conta uma existente' do
    usuario = Prodam::Idealize::Usuario.find nome_usuario: 'idealize'
    assert usuario
  end
end
