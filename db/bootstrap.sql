prompt ** USUARIO

insert into usuario (
    nome_usuario
  , nome
  , email
  , senha_salt
  , senha_encriptada
  , ad
  ) values (
    'idealize'
  , 'Administrador Prodam Idealize'
  , 'idealize@prodam.am.gov.br'
  , '70bda423a16885f993bc9fb873b56ab7'
  , '2c62f1ac5edb7274d6839334ca7f0d3b'
  , 'S'
  )
;

commit;

prompt ** CATEGORIAS

insert into categoria
  select s_categoria.nextval
       , v_categoria.*
    from (
      select 'Moderação' as titulo
           , 'Categoria que agrupa as ideias que serão moderadas pelos administradores.' as descricao
           , 'folder_special' as icone
           , sysdate as data_criacao
        from dual union
      select 'Educação' as titulo
           , 'Ideias voltadas para a área da educação.' as descricao
           , 'local_library' as icone
           , sysdate as data_criacao
        from dual union
      select 'Negócio' as titulo
           , 'Propostas de melhoria ou oportunidades para melhorias no modelo de negócio.' as descricao
           , 'business' as icone
           , sysdate as data_criacao
        from dual union
      select 'Segurança' as titulo
           , 'Ideias para melhorias na seguraça pública.' as descricao
           , 'security' as icone
           , sysdate as data_criacao
        from dual union
      select 'Trânsito' as titulo
           , 'Ideias para melhorias no trânsito.' as descricao
           , 'directions_car' as icone
           , sysdate as data_criacao
        from dual
    ) v_categoria
;
