prompt ** CRITERIO

define indx = &1
define data = &2

create sequence s_criterio minvalue 1 start with 1 increment by 1;

create table criterio (
  id number(15,0)
     constraint criterio_pk primary key using index tablespace &indx
, formulario_id number(15,0)
                constraint criterio_formulario_fk references formulario(id)
, titulo varchar2(64)
         constraint criterio_titulo_nn not null
, descricao varchar2(256)
) tablespace &data;

create or replace trigger criterio_insert
  before insert
  on criterio for each row
when (new.id is null)
begin
  :new.id := s_criterio.nextval;
end;
/

comment on table  criterio           is 'Critérios para formulário de avaliação de uma ideia.';
comment on column criterio.titulo    is 'Título do critério.';
comment on column criterio.descricao is 'Descrição do critério.';
