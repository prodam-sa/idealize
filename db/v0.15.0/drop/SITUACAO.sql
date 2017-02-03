prompt ** SITUACAO

alter table situacao drop (
  rotulo
, processo_id
, oposta_id
, seguinte_id
);

alter table situacao rename column restrita to restrito;
