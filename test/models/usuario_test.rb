describe 'Usuário' do
  it 'cria uma nova conta' do
    usuario = Prodam::Idealize::Usuario.new nome_usuario: 'p001051', nome: 'Hallison Batista', email: 'hallison@localhost.local'
    assert usuario.valid?
    assert_equal 0, usuario.errors.size
  end

  it 'consulta conta uma existente' do
    usuario = Prodam::Idealize::Usuario.find nome_usuario: 'admin'
    refute_nil usuario
  end
end
