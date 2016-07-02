prompt ** IDEIA_APOIADOR

define indx = &1
define data = &2

create table ideia_apoiador (
  ideia_id number(15,0)
           constraint ideia_apoiador_ideia_fk references ideia(id)
, apoiador_id number(15,0)
              constraint ideia_apoiador_apoiador_fk references usuario(id)
) tablespace &data;

comment on table ideia_apoiador is 'Relacionamento de ideias e seus usuários apoiadores.';
