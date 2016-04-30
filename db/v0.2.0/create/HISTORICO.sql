prompt ** HISTORICO

define indx = &1
define data = &2

create sequence s_historico minvalue 1 start with 1 increment by 1;

create table historico (
  id number(15,0)
     constraint historico_pk primary key using index tablespace &indx
, ideia_id number(15,0)
           constraint historico_ideia_fk references ideia(id)
, situacao_id number(15,0)
              constraint historico_situacao_fk references situacao(id)
, responsavel_id number(15,0)
                 constraint historico_responsavel_fk references usuario(id)
, data_registro date
                default sysdate
, descricao varchar2(512)
            constraint historico_descricao_nn not null
) tablespace &data;

create or replace trigger historico_insert
  before insert
  on historico for each row
when (new.id is null)
begin
  :new.id := s_historico.nextval;
end;
/

comment on table  historico               is 'Histórico das eventos que envolvem uma ideia.';
comment on column historico.data_registro is 'Data do registro.';
comment on column historico.descricao     is 'Descrição do registro.';
