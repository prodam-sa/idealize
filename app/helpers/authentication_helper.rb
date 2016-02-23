# encoding: utf-8

module Prodam::Idealize::AuthenticationHelper
  def protected!
    return if authenticated?
    headers['WWW-Authenticate'] = 'Basic realm="Somente administradores"'
    halt 401, "Você não possui autorização\n"
  end

  def authenticated?
    !session[:user_id].nil? && !session[:user_admin].nil?
  end

  def authorized?
    authenticated? && session[:user_admin] == 'S'
  end

  def authenticate(user_id, user_admin = 'N')
    session[:user_id] = user_id
    session[:user_admin] = user_admin
  end

  def disconect!
    session[:user_id] = nil
    session[:user_admin] = nil
  end
end
