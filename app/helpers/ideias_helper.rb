# encoding: utf-8

module Prodam::Idealize

module IdeiasHelper
  def usuario_id
    session[:user] && session[:user][:id]
  end

  def usuario_autor?(ideia)
    return nil unless authenticated?
    usuario_id == ideia.autor_id
  end

  def registrar_historico(chave, mensagem)
    modificacao = Modificacao.create situacao_id: Situacao.chave(chave).id,
                                     responsavel_id: usuario_id,
                                     descricao: mensagem
    @ideia.situacao = chave.to_s
    @ideia.add_modificacao modificacao
    @ideia
  end

  def mensagem(texto)
    mensagem = params[:historico] && params[:historico][:mensagem] || ''
    if mensagem.empty?
      texto
    else
      mensagem
    end
  end
end

end # module
