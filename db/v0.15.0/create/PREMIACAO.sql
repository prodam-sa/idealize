prompt ** PREMIACAO

define indx = &1
define data = &2

create sequence s_premiacao minvalue 1 start with 1 increment by 1;

create table premiacao (
  id number(15,0)
    constraint premiacao_pk primary key using index tablespace &indx
, titulo varchar2(64)
    constraint premiacao_titulo_nn not null
, descricao varchar2(256)
) tablespace &data;

create or replace trigger premiacao_insert
  before insert
  on premiacao for each row
when (new.id is null)
begin
  :new.id := s_premiacao.nextval;
end;
/

comment on table  premiacao           is 'Premiação das ideias.';
comment on column premiacao.titulo    is 'Título da premiação.';
comment on column premiacao.descricao is 'Descrição da premiação.';
