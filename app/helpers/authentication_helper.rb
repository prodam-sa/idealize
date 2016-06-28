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

  def authenticate(user_id, *profiles)
    session[:user] = {
      id: user_id,
      profiles: profiles
    }
  end

  def disconect!
    session[:user] = nil
  end
end

end # Prodam::Idealize
