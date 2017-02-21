prompt ** IDEIA

define indx = &1
define data = &2

alter table ideia rename column situacao to chave_situacao;

alter table ideia add (
  situacao_id number(15,0)
    constraint ideia_situacao_fk references situacao(id)
);

update (
  select ideia.chave_situacao as ideia_chave_situacao
       , ideia.situacao_id    as ideia_situacao_id
       , situacao.id          as situacao_id
    from ideia
    inner join situacao on (situacao.chave = ideia.chave_situacao)
  )
  set ideia_situacao_id = situacao_id
;

commit;
