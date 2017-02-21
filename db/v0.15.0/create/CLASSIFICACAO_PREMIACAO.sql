prompt ** CLASSIFICACAO_PREMIACAO

define indx = &1
define data = &2

create table classificacao_premiacao (
  classificacao_id number(15,0)
    constraint classifica_premia_classf_fk references classificacao(id)
, premiacao_id number(15,0)
    constraint classifica_premia_premio_fk references premiacao(id)
) tablespace &data;

comment on table  classificacao_premiacao is 'Relacionamento de classificação e suas premiações.';
