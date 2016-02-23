# encoding: utf-8

require 'digest'

class Prodam::Idealize::Usuario < Prodam::Idealize::Model[:usuario]
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

  def after_save
    self[:id] = self.class.select(:id).where(nome_usuario: self[:nome_usuario]).first[:id]
  end

  def save(options = {})
    before_save
    self.class.no_primary_key if new?
    self[:senha_encriptada] = encript(options[:senha], self[:senha_salt])
    super(options)
    self.class.set_primary_key :id
    self
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

private

  def encript(text, salt = nil)
    Digest::MD5.hexdigest(salt ? "#{salt}:#{text}" : text)
  end
end
