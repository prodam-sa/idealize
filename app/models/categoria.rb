# encoding: utf-8

class Prodam::Idealize::Categoria < Prodam::Idealize::Model[:categoria]
  plugin :validation_helpers

  def validate
    super
    validates_presence :nome, message: 'não foi atribuído.'
    validates_unique :nome, message: 'já registrado.'
  end
end
