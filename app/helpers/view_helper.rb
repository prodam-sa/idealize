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

  def pages
    Prodam::Idealize.pages
  end

  def sections
    controllers.merge(pages)
  end

  def data(filename)
    Prodam::Idealize.load_data(filename)
  end

  def remove_html_tags(text)
    text.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')
  end

  def letters
    Hash[('A'..'Z').to_a.map{|i| [i, []]}]
  end

  def sanitize_letter(letter)
    case letter
    when /ÁÀÄÔÃáàäôã/ then 'A'
    when /ÉÈËÊéèëê/   then 'E'
    when /ÍÌÏÎíìïî/   then 'I'
    when /ÓÒÖÔÕóòöôõ/ then 'O'
    when /ÚÙÜÛŨúùüûũ/ then 'U'
    else letter
    end
  end
end
