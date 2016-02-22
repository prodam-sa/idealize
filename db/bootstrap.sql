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
