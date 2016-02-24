prompt ** CATEGORIA

define indx = &1
define data = &2

create sequence s_categoria minvalue 1 start with 1 increment by 1;

create table categoria (
  id number(15,0)
     constraint categoria_pk primary key using index tablespace &indx
, titulo varchar2(64)
         constraint categoria_titulo_nn not null
         constraint categoria_titulo_uk unique
, icone varchar2(32)
        default 'folder_special'
) tablespace &data;

create or replace trigger categoria_insert
  before insert
  on categoria for each row
when (new.id is null)
begin
  :new.id := s_categoria.nextval;
end;
/

comment on table  categoria        is 'Categoria das ideias.';
comment on column categoria.titulo is 'Título da categoria.';
comment on column categoria.icone  is 'Ícone para representação da categoria.';
