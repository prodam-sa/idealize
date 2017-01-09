prompt ** MENSAGEM

define indx = &1
define data = &2

create sequence s_mensagem minvalue 1 start with 1 increment by 1;

create table mensagem (
  id number(15,0)
     constraint mensagem_pk primary key using index tablespace &indx
, remetente_id number(15,0)
               constraint mensagem_remetente_nn not null
, destinatario_id number(15,0)
                  constraint mensagem_destinatario_nn not null
                  constraint mensagem_destinatario_fk references usuario(id)
, ideia_id number(15,0)
           constraint mensagem_ideia_fk references ideia(id)
, texto varchar2(256)
        constraint mensagem_texto_nn not null
, data_criacao date
               default sysdate
, data_envio date
, data_leitura date
) tablespace &data;

create or replace trigger mensagem_insert
  before insert
  on mensagem for each row
when (new.id is null)
begin
  :new.id := s_mensagem.nextval;
end;
/

comment on table mensagem is 'Mensagens entre os usuários do sistema.';
comment on column mensagem.texto is 'Texto da mensagem.';
