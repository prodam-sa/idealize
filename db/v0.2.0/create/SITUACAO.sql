prompt ** SITUACAO

define indx = &1
define data = &2

create sequence s_situacao minvalue 1 start with 1 increment by 1;

create table situacao (
  id number(15,0)
     constraint situacao_pk primary key using index tablespace &indx
, chave varchar2(32)
        constraint situacao_chave_uk unique
, titulo varchar2(64)
         constraint situacao_titulo_nn not null
, descricao varchar2(256)
, restrito char(1)
           default 'S'
) tablespace &data;

create or replace trigger situacao_insert
  before insert
  on situacao for each row
when (new.id is null)
begin
  :new.id := s_situacao.nextval;
end;
/

comment on table  situacao           is 'Situação da ideia postada.';
comment on column situacao.chave     is 'Chave para localização da situação.';
comment on column situacao.titulo    is 'Título da situação.';
comment on column situacao.descricao is 'Descrição da situação.';
comment on column situacao.restrito  is 'A ideia é restrita (S) sim ou (N) não. Esse campo é responsável por permitir a exibição da pública da ideia.';
