# encoding: utf-8

module Prodam::Idealize::UrlHelper
  # Helper descrito como solução para sub URI nas aplicações em jRuby.
  # Detalhes: https://github.com/jruby/warbler/issues/110
  def context_path
    @context_path ||= check_for_context
  end

  def path_to(path)
    if path.is_a? Symbol
      controller = '/' + (path.to_s.match(/^(home|root)/i) ? '' : path).to_s
    else
      controller = path
    end
    "#{context_path}#{controller}"
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
