# encoding: utf-8

module Prodam::Idealize::GravatarHelper
  def usuario_email
    session[:user] && session[:user][:email]
  end

  def gravatar(email, options = {})
    hash = Digest::MD5.hexdigest(email || 'noemail@gravatar.com')
    params = options.map{|k,v| "#{k}=#{v}"}.join('&')
    "http://www.gravatar.com/avatar/#{hash}?#{params}"
  end
end
