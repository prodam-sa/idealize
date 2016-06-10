prompt ** SITUACAO

insert into situacao (
    chave
  , titulo
  , descricao
  , restrito
  ) values (
    'moderacao'
  , 'Ideia em moderação'
  , 'Ideia está em moderação pelos responsáveis de triagem.'
  , 'S'
  )
;

commit;

/* update situacao */
/*   set bloqueado = 'S' */
/*   where chave in ('rascunho', 'revisao', 'publicacao', ) */
