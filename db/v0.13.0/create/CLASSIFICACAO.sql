prompt ** CLASSIFICACAO

define indx = &1
define data = &2

create sequence s_classificacao minvalue 1 start with 1 increment by 1;

create table classificacao (
  id number(15,0)
     constraint classificacao_pk primary key using index tablespace &indx
, titulo varchar2(64)
         constraint classificacao_titulo_uk unique
         constraint classificacao_titulo_nn not null
, descricao varchar2(256)
            constraint classificacao_descricao_nn not null
, ponto_minimo number(2,0)
               constraint classificacao_pnt_minimo not null
, ponto_maximo number(2,0)
               constraint classificacao_pnt_maximo not null
, pontuacao number(3,0)
            constraint classificacao_pontuacao not null
) tablespace &data;

create or replace trigger classificacao_insert
  before insert
  on classificacao for each row
when (new.id is null)
begin
  :new.id := s_classificacao.nextval;
end;
/

comment on table  classificacao      is 'Descrição de CLASSIFICACAO.';
-- comment on column classificacao.atributo is 'Descrição do atributo.';
