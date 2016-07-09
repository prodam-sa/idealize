prompt ** PONTUACAO

define indx = &1
define data = &2

create sequence s_pontuacao minvalue 1 start with 1 increment by 1;

create table pontuacao (
  id number(15,0)
     constraint pontuacao_pk primary key using index tablespace &indx
, ideia_id number(15,0)
           constraint pontuacao_ideia_fk references ideia(id)
, classificacao_id number(15,0)
              constraint pontuacao_classificacao_fk references classificacao(id)
, valor number(3,0)
        constraint pontuacao_valor_nn not null
) tablespace &data;

create or replace trigger pontuacao_insert
  before insert
  on pontuacao for each row
when (new.id is null)
begin
  :new.id := s_pontuacao.nextval;
end;
/

comment on table  pontuacao       is 'Pontuações das ideias.';
comment on column pontuacao.valor is 'Valor da pontuação.';
