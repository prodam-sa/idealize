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
      select 'Nenhum'    as titulo, 'folder_special' as icone from dual union
      select 'Educação'  as titulo, 'local_library'  as icone from dual union
      select 'Negócio'   as titulo, 'business'       as icone from dual union
      select 'Segurança' as titulo, 'security'       as icone from dual union
      select 'Trânsito'  as titulo, 'directions_car' as icone from dual
    ) v_categoria
;
