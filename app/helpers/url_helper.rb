# encoding: utf-8

module Prodam::Idealize

module UrlHelper
  def controllers
    Prodam::Idealize.controllers
  end

  def pages
    Prodam::Idealize.pages
  end

  def sections(navigation = nil)
    navigation && Prodam::Idealize.sections.select do |id, section|
      section[:navigation].include? navigation.to_s
    end || Prodam::Idealize.sections
  end

  # Helper descrito como solução para sub URI nas aplicações em jRuby.
  # Detalhes: https://github.com/jruby/warbler/issues/110
  def context_path
    @context_path ||= check_for_context
  end

  def path_to(path, *args)
    if args.last.kind_of? Hash
      slashes = args[0..-2]
      params = args[-1]
    else
      slashes = args
    end
    (slashes.size > 0) && (subpath = slashes.join('/'))
    params && (subpath = (subpath + "?" + params.map{|k,v|"#{k}=#{v}"}.join("&")))
    url_path = sections[path] && sections[path][:url_path] || path.to_s
    subpath && (url_path = format("%s/%s", url_path, subpath))
    url_path = url_path.squeeze '/'
    "#{context_path}#{url_path}"
  end

private

  def check_for_context
    if $servlet_context
      return $servlet_context.getContextPath
    else
      return ""
    end
  end
end

end # Prodam::Idealize
