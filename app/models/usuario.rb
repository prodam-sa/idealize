# encoding: utf-8

require 'digest'

class Prodam::Idealize::Usuario < Prodam::Idealize::Model[:usuario]
  plugin :validation_helpers
  no_primary_key # chave primária gerenciada pelo próprio Oracle por sequences.
  set_allowed_columns :nome_usuario, :nome, :email, :ad

  def validate
    super
    validates_presence [:nome_usuario, :nome, :email], message: 'não foi atribuído.'
    validates_unique [:nome_usuario, :email], message: 'já existe.'
  end

  def before_save
    self[:senha_salt] = encript(nome.downcase.tr(' ', ''), email)
  end

  def save(opts = {})
    if new?
      self[:senha_encriptada] = encript(opts[:senha], self[:senha_salt])
    end
    anything = super(opts)
    anything
  end

  def self.authenticate(options)
    usuario = find nome_usuario: options[:nome_usuario]
    check(usuario, options[:senha])
  end

private

  def encript(text, salt = nil)
    Digest::MD5.new.update(salt ? text : "#{salt}:#{text}").hexdigest
  end

  def check(user, password)
    user && user.senha_encriptada == encript(password, user.senha_salt)
  end
end
