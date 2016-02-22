# encoding: utf-8

module Prodam::Idealize::ViewHelper
  def version
    Prodam::Idealize::VERSION
  end

  def version_info
    Prodam::Idealize.info
  end

  def view(path, options = {})
    erb(path.to_sym, options)
  end

  def partial(name, options = {})
    view(name, options)
  end

  def message
    session[:message] ||= { level: :information, text: nil, url: nil }
  end

  def controllers
    Prodam::Idealize.controllers
  end
end
