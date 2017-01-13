# encoding: utf-8

module Prodam::Idealize

module AuthenticationHelper
  def protected!
    if authenticated? and !authorized?
      return
    end
  end

  def authenticated?
    !session[:user].nil?
  end

  def authorized?
    authenticated? && (session[:user][:profiles].include? 'administrador')
  end

  def authorized_by?(*profiles)
    session[:user] && (session[:user][:profiles] & profiles.map(&:to_s)).any?
  end
  alias authenticated_as? authorized_by?

  def authenticate(user_id, user_email, *profiles)
    session[:user] = {
      id: user_id,
      email: user_email,
      profiles: profiles,
    }
  end

  def session_user
    @session_user ||= session[:user] && session[:user] || {}
  end

  def disconect!
    session[:user] = nil
  end
end

end # Prodam::Idealize
