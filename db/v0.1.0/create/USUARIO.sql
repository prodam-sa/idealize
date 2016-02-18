prompt ** USUARIO

define indx = &1
define data = &2

create sequence s_usuario minvalue 1 start with 1 increment by 1;

create table usuario (
  id number(15,0)
     constraint usuario_pk primary key using index tablespace &indx
, nome_usuario varchar2(32)
               constraint usuario_nome_usuario_nn not null
               constraint usuario_nome_usuario_uk unique
, nome varchar2(64)
       constraint usuario_nome_nn not null
, email varchar2(256)
        constraint usuario_email_nn not null
        constraint usuario_email_uk unique
, senha_salt varchar2(32)
             constraint usuario_senha_salt_nn not null
, senha_encriptada varchar2(32)
                   constraint usuario_senha_nn not null
, ad char(1)
     default 'N'
, data_criacao date
               default sysdate
) tablespace &data;

create or replace trigger usuario_insert
  before insert
  on usuario for each row
when (new.id is null)
begin
  :new.id := s_usuario.nextval;
end;
/

comment on table  usuario                  is 'Usuário do sistema.';
comment on column usuario.nome_usuario     is 'Nome de usuário (username) para acesso.';
comment on column usuario.nome             is 'Nome completo do usuário.';
comment on column usuario.email            is 'E-mail do usuário.';
comment on column usuario.senha_salt       is 'SALT para encriptação da senha.';
comment on column usuario.senha_encriptada is 'Senha encriptada em MD5.';
comment on column usuario.ad               is 'Administrador de Dados? (S)im ou (N)ão.';
comment on column usuario.data_criacao     is 'Data de criação da conta de usuário.';
