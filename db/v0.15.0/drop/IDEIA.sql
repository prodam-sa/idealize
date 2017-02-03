update (
  select ideia.chave_situacao as ideia_chave_situacao
       , situacao.chave       as situacao_chave
    from ideia
    inner join situacao on (situacao.id = ideia.situacao_id)
  )
  set ideia_chave_situacao = situacao_chave
;

commit;

alter table ideia drop (
  situacao_id
);

alter table ideia rename column chave_situacao to situacao;
