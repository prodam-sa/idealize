prompt ** MODERACAO

define indx = &1
define data = &2

create sequence s_moderacao minvalue 1 start with 1 increment by 1;

create table moderacao (
  id number(15,0)
     constraint moderacao_pk primary key using index tablespace &indx
, titulo varchar2(64)
         constraint moderacao_titulo_nn not null
, descricao varchar2(256)
) tablespace &data;

create or replace trigger moderacao_insert
  before insert
  on moderacao for each row
when (new.id is null)
begin
  :new.id := s_moderacao.nextval;
end;
/

comment on table  moderacao           is 'Formulário de moderação das ideias publicadas.';
comment on column moderacao.titulo    is 'Título do formulário de moderação.';
comment on column moderacao.descricao is 'Descrição do formulário de moderação.';

insert into moderacao (
    titulo
  , descricao
  ) values (
    'Triagem'
  , 'Formulário de moderação de ideia para avaliação de viabilidade.'
  )
;
