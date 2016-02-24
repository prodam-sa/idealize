prompt ** IDEIA_COAUTOR

define indx = &1
define data = &2

create table ideia_coautor (
  ideia_id number(15,0)
           constraint ideia_coautor_ideia_fk references ideia(id)
, autor_id number(15,0)
           constraint ideia_coautor_autor_fk references usuario(id)
) tablespace &data;

comment on table ideia_coautor is 'Relacionamento de ideias e seus coautores.';
