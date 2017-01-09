# encoding: utf-8

module Prodam::Idealize

class Mensagem < Model[:mensagem]
  include Model

  plugin :validation_helpers

  many_to_one :remetente, class: Usuario
  many_to_one :destinatario, class: Usuario
  many_to_one :ideia

  def validate
    super
    validates_presence :remetente_id, message: 'deve ser atribuído.'
    validates_presence :destinatario_id, message: 'deve ser atribuído.'

    validates_presence :texto, message: 'deve ser atribuído.'
    validates_max_length 256, :texto, message: lambda{ |n| "deve ter até #{n} caracteres." }
  end

  def self.find_nao_lidas_para(destinatario_id)
    where('destinatario_id = ? AND data_leitura IS NULL', destinatario_id)
  end
end

end # module
