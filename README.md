# Idealize - Caixa de Ideias da Prodam

## Funcionalidades básicas

- Perfil do usuário
  - Dados de acesso
- Ideias/Propostas
- Categorias das ideias

## Tabelas

- Usuário/Autor/Coautor
  - Nome de usuário
  - Nome (Pessoa)
  - Email
  - Senha (criptografada)
  - Data de criação

- Ideias
  - Autor (Co-autores)
  - Oportunidade/Desafio
  - Proposta/Solução
  - Categorias

- Categorias
  - Nome
  - Ideias

# Clientes

- Prodam

# Requisitos

- Oracle 12c
- Ruby v2.x
  - Sinatra (~> 1.4)
  - Sequel (~> 4.30)
  - Json (~> 1.8)
- Google Material Design Lite (~> 1.1.0)

## Ambiente de Desenvolvimento

- Bibliotecas
  - Puma (servidor de aplicação).
  - Pry (console).
  - Warbler, para platforma jRuby.
    - jRuby v9.0.4.0
    - JDK v1.7

# Documentação

Consulte a [Wiki][1] deste projeto no repositório.

# Contribuições

Este projeto obedece as orientações do [Guia de Desenvolvimento de
Software][2] proposto pela Divisão de Qualidade de Desenvolvimento - DQDES.

Se você gostaria de contribuir com novos recursos, melhorias ou correções ,
por favor leia nossas [Guia de Contribuição][3] para obter instruções
detalhadas.

# Licença

Copyright (C) 2016 Processamento de Dados do Amazonas S/A. Todos os direitos reservados.

[1]: http://git.prodam.am.gov.br/dinov/idealize/wikis/home
[2]: http://git.prodam.am.gov.br/dqdes/guia-de-desenvolvimento-de-software
[3]: http://git.prodam.am.gov.br/dqdes/guia-de-contribuicao
