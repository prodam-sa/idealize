# encoding: utf-8

module Prodam::Idealize::AuthenticationHelper
  def protected!
    if authenticated? and !authorized?
      return
    end
  end

  def authenticated?
    !session[:user_id].nil? && !session[:user_admin].nil?
  end

  def authorized?
    authenticated? && session[:user_admin]
  end

  def authenticate(user_id, user_admin = false)
    session[:user_id] = user_id
    session[:user_admin] = user_admin
  end

  def disconect!
    session[:user_id] = nil
    session[:user_admin] = nil
  end
end
