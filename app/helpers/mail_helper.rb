require 'mail'

# Mail.defaults do
#   delivery_method :smtp, address: "localhost", port: 1025
# end

module Prodam::Idealize

module MailHelper
  def notificacao(options)
    options[:de] ||= 'Idealize <nao-responda@prodam.am.gov.br>'
    mail = Mail.new do
      from     options[:de]
      to       options[:para]
      subject  options[:assunto]

      text_part do
        body options[:mensagem_texto]
      end if options[:mensagem_texto]

      html_part do
        content_type 'text/html; charset=UTF-8'
        body options[:mensagem_html]
      end if options[:mensagem_html]

      options[:arquivos].each do |arquivo|
        add_file filename: arquivo[:nome],
                 content:  arquivo[:conteudo]
      end if options[:arquivos]
    end
    # mail.delivery_method :sendmail
    mail.delivery_method :smtp, Prodam::Idealize.application_config[:email]
    mail
  end

  def enviar_notificacao(options)
    notificacao(options).deliver!
  end
end

end # Prodam::Idealize
