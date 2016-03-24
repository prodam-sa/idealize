include Rack::Test::Methods

alias response last_response

describe 'Acesso controller' do
  def app
    Prodam::Idealize::AcessoController
  end

  it 'redireciona para o formulário de login' do
    get '/' do
      assert_equal 200, response.status
      assert_match 'form', response.body
    end
  end

  it 'cria seção do usuário' do
    post '/acessar', usuario: { nome_usuario: 'idealize', senha: 'prodam' } do
      assert_equal 303, response.status
    end
  end
end
