# encoding: utf-8

module Prodam::Idealize::IdeiasHelper
  def usuario_id
    session[:user][:id]
  end

  def usuario_autor?(ideia)
    return nil unless authenticated?
    usuario_id == ideia.autor_id
  end
end
