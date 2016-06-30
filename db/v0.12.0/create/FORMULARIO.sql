prompt ** FORMULARIO

alter table formulario add (
  processo_id number(15,0)
              constraint formulario_processo_fk references situacao(id)
);
