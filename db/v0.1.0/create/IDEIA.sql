prompt ** IDEIA

define indx = &1
define data = &2

create sequence s_ideia minvalue 1 start with 1 increment by 1;

create table ideia (
  id number(15,0)
     constraint ideia_pk primary key using index tablespace &indx
, autor_id number(15,0)
           constraint ideia_autor_nn not null
           constraint ideia_autor_fk references usuario(id)
, titulo varchar2(128)
         constraint ideia_titulo_nn not null
         constraint ideia_titulo_uk unique
, texto_oportunidade varchar2(4000)
, texto_solucao varchar2(4000)
, data_criacao date
               default sysdate
, data_publicacao date
, data_atualizacao date
) tablespace &data;

create or replace trigger ideia_insert
  before insert
  on ideia for each row
when (new.id is null)
begin
  :new.id := s_ideia.nextval;
end;
/

comment on table  ideia                    is 'Ideias para oportunidades e soluções.';
comment on column ideia.titulo             is 'Título da ideia.';
comment on column ideia.texto_oportunidade is 'Texto da oportunidade ou desafio.';
comment on column ideia.texto_solucao      is 'Texto descritivo da proposta ou solução.';
comment on column ideia.data_publicacao    is 'Data de publicação da ideia. Enquando o campo estiver nulo, a ideia será um rascunho.';
comment on column ideia.data_atualizacao   is 'Data de atualização da ideia.';
