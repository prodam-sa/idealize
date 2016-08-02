require 'mail'

# Mail.defaults do
#   delivery_method :smtp, address: "localhost", port: 1025
# end

module Prodam::Idealize

module MailHelper
  def enviar_mensagem(options)
    options[:de] ||= 'nao-responda@prodam.am.gov.br'
    mail = Mail.new do
      from     options[:de]
      to       options[:para]
      subject  options[:assunto]
      body     options[:texto]
      options[:arquivos].each do |arquivo|
        add_file filename: arquivo[:nome],
                 content:  arquivo[:conteudo]
      end if options[:arquivos]
    end
    # mail.delivery_method :sendmail
    mail.delivery_method :smtp, Prodam::Idealize.application_config[:email]
    mail.deliver!
  end
end

end # Prodam::Idealize
