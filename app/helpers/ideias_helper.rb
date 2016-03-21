# encoding: utf-8

module Prodam::Idealize::IdeiasHelper
  def usuario_autor?(ideia)
    return nil unless authenticated?
    session[:user_id] == ideia.autor_id
  end
end
