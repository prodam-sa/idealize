# encoding: utf-8

module Prodam::Idealize::AuthenticationHelper
  def protected!
    if authenticated? and !authorized?
      return
    end
  end

  def authenticated?
    !session[:user].nil?
  end

  def authorized?
    authenticated? && session[:user][:administrator]
  end

  def authorized_by?(role)
    authenticated? && session[:user][role]
  end

  def authenticate(user_id, user_administrator = false, user_moderator = false)
    session[:user] = {
      id: user_id,
      administrator: user_administrator,
      moderator: user_moderator,
    }
  end

  def disconect!
    session[:user] = nil
  end
end