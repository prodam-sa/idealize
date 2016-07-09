prompt ** AVALIACAO

define indx = &1
define data = &2

create sequence s_avaliacao minvalue 1 start with 1 increment by 1;

create table avaliacao (
  id number(15,0)
     constraint avaliacao_pk primary key using index tablespace &indx
, ideia_id number(15,0)
           constraint avaliacao_ideia_fk references ideia(id)
, classificacao_id number(15,0)
              constraint avaliacao_classificacao_fk references classificacao(id)
, pontos number(3,0)
         constraint avaliacao_pontos_nn not null
) tablespace &data;

create or replace trigger avaliacao_insert
  before insert
  on avaliacao for each row
when (new.id is null)
begin
  :new.id := s_avaliacao.nextval;
end;
/

comment on table  avaliacao        is 'Avaliação das ideias.';
comment on column avaliacao.pontos is 'Valor dos pontos da ideia.';
