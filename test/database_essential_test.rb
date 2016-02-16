describe 'Database essential' do
  before do
    @file = fixtures('database.yml')
  end

  it 'load configuration from YAML file' do
    yaml = YAML.load_file(@file)
    Prodam::Idealize::Database.load_config(@file, :test)
    assert_equal yaml[:test][:uri], Prodam::Idealize::Database.uri
  end
end
