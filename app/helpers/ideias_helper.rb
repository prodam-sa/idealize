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

  def situacao(chave)
    Situacao.chave(chave)
  end

  def historico(ideia, situacao, mensagem)
    Modificacao.create ideia: ideia,
                       situacao: situacao,
                       responsavel_id: usuario_id,
                       descricao: mensagem
  end

  def mensagem(texto)
    mensagem = params[:historico] && params[:historico][:mensagem] || ''
    if mensagem.empty?
      texto
    else
      mensagem
    end
  end

  def perfil_responavel_historico(ideia, responsavel)
    return 'Autor' if responsavel.id == ideia.autor_id
    return 'Administrador' if responsavel.administrador?
    return 'Moderador' if responsavel.moderador?
    'Usuário'
  end
end

end # module
