prompt ** SITUACAO

alter table situacao rename column restrito to restrita;

alter table situacao add (
  rotulo varchar2(64)
, bloqueia char(1) default 'N'
, processo_id number(15,0)
    constraint situacao_processo_fk references situacao(id)
, oposta_id number(15,0)
    constraint situacao_oposta_fk references situacao(id)
, seguinte_id number(15,0)
    constraint situacao_seguinte_fk references situacao(id)
);

comment on column situacao.rotulo   is 'Rótulo de apresentação da situação.';
comment on column situacao.bloqueia is 'Determina se o processo é bloqueante.';
