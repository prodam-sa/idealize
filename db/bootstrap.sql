prompt ** USUARIO

insert into usuario (
    nome_usuario
  , nome
  , email
  , senha_salt
  , senha_encriptada
  , ad
  ) values (
    'admin'
  , 'Administrador Prodam'
  , 'idealize@prodam.am.gov.br'
  , '3a93774d444d2450e3fecc14a17ed72c'
  , '3b7dc0d8f6a8e9f850c995f3d1808854'
  , 'S'
  )
;

commit;
