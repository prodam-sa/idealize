describe 'Configuration' do
  before do
    @file = fixtures('application.yml')
  end

  it 'load from YAML file' do
    yaml   = YAML.load_file(@file)
    config = Prodam::Idealize::Configuration.load_file(@file)
    yaml.each do |key, value|
      assert_equal value, config[key]
    end
  end
end
