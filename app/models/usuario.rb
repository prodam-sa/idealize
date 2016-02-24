# encoding: utf-8

require 'digest'

class Prodam::Idealize::Usuario < Prodam::Idealize::Model[:usuario]
  include Prodam::Idealize::Model

  plugin :validation_helpers
  set_allowed_columns :nome_usuario, :nome, :email, :ad

  def validate
    super
    validates_presence [:nome_usuario, :nome, :email], message: 'não foi atribuído.'
    validates_unique :nome_usuario, message: 'já existe.'
    validates_unique :email, message: 'já registrado.'
  end

  def before_save
    self[:senha_salt] = encript(self[:nome].downcase.tr(' ', ''), self[:email])
  end

  alias original_save save

  def save(options = {})
    before_save
    self[:senha_encriptada] = encript(options[:senha], self[:senha_salt])
    original_save
  end

  def authenticate?(password)
    senha_encriptada == encript(password, senha_salt)
  end

  def administrador?
    self[:ad] == 'S'
  end

  def self.authenticate(options)
    usuario = find nome_usuario: options[:nome_usuario]
    usuario && usuario.authenticate?(options[:senha]) && usuario
  end

  def param_name
    "#{id}-#{nome_usuario.downcase}"
  end

private

  def encript(text, salt = nil)
    Digest::MD5.hexdigest(salt ? "#{salt}:#{text}" : text)
  end
end
