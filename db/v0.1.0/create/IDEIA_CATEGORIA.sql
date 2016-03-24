prompt ** IDEIA_CATEGORIA

define indx = &1
define data = &2

create table ideia_categoria (
  ideia_id number(15,0)
           constraint ideia_categoria_ideia_fk references ideia(id)
, categoria_id number(15,0)
               constraint ideia_categoria_categoria_fk references categoria(id)
) tablespace &data;

comment on table ideia_categoria is 'Relacionamento de ideias e suas categorias.';
