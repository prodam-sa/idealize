prompt ** CRITERIO

alter table criterio add (
  criterio_multiplo_id number(15,0)
                       constraint criterio_multiplo_fk references criterio(id) on delete cascade
, peso number(2,0) default 1
);

comment on column criterio.peso is 'Peso padrão do critério para cálculo de pontuação (1 a 99).';
