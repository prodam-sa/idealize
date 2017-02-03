prompt ** SITUACAO

alter table situacao rename column restrito to restrita;

alter table situacao add (
  processo_id number(15,0)
    constraint situacao_processo_fk references processo(id)
, oposta_id number(15,0)
    constraint situacao_oposta_fk references situacao(id)
, seguinte_id number(15,0)
    constraint situacao_seguinte_fk references situacao(id)
);
