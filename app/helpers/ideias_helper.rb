# encoding: utf-8

module Prodam::Idealize

module IdeiasHelper
  def usuario_id
    session[:user] && session[:user][:id]
  end
  alias usuario_autenticado? usuario_id

  def usuario_autor?(ideia)
    return false unless authenticated?
    ideia && (usuario_id == ideia.autor_id)
  end

  def usuario_coautor?(ideia)
    return false unless authenticated?
    (ideia.coautores.include? usuario_id)
  end

  def usuario_colaborador?(ideia)
    (usuario_autor? ideia) || (usuario_coautor? ideia)
  end

  def usuario_moderador?(ideia)
    (authenticated_as? :moderador) && !(usuario_colaborador? ideia) && (ideia.modificacao.responsavel_id == usuario_id)
  end

  def permitido_moderar?(ideia)
    ideia && !ideia.publicada? && ideia.desbloqueada? && !(usuario_colaborador? ideia)
  end

  def permitido_alterar?(ideia)
    (usuario_autor? ideia) && (ideia.desbloqueada?)
  end

  def permitido_postar?(ideia)
    (permitido_alterar? ideia) && (ideia.situacoes? :rascunho, :revisao)
  end

  def permitido_excluir?(ideia)
    (permitido_alterar? ideia) && (ideia.situacoes? :rascunho, :revisao)
  end

  def permitido_arquivar?(ideia)
    (permitido_exluir? ideia)
  end

  def situacao(chave)
    Situacao.chave(chave)
  end

  def historico(ideia, situacao, mensagem)
    Modificacao.new ideia: ideia,
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
    return 'Moderador' if responsavel.has_profile? :moderador
    return 'Administrador' if responsavel.has_profile? :administrador
    'Usuário'
  end
end

end # module
