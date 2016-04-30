prompt ** FORMULARIO

define indx = &1
define data = &2

create sequence s_formulario minvalue 1 start with 1 increment by 1;

create table formulario (
  id number(15,0)
     constraint formulario_pk primary key using index tablespace &indx
, titulo varchar2(64)
         constraint formulario_titulo_nn not null
, descricao varchar2(256)
) tablespace &data;

create or replace trigger formulario_insert
  before insert
  on formulario for each row
when (new.id is null)
begin
  :new.id := s_formulario.nextval;
end;
/

comment on table  formulario           is 'Formulário de avaliação das ideias postadas.';
comment on column formulario.titulo    is 'Título do formulário de avaliação.';
comment on column formulario.descricao is 'Descrição do formulário de avaliação.';
