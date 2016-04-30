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

  def registrar_historico(chave, opcoes = {})
    opcoes.update de: @ideia.autor_id, para: @ideia.autor_id
    modificacao = Modificacao.create situacao_id: Situacao.chave(chave).id,
                                     responsavel_id: opcoes[:de],
                                     descricao: opcoes[:mensagem]
    @ideia.situacao = chave.to_s
    @ideia.add_modificacao modificacao
    @ideia
  end
end

end # module
