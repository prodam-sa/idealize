prompt ** PROCESSO

define indx = &1
define data = &2

create sequence s_processo minvalue 1 start with 1 increment by 1;

create table processo (
  id number(15,0)
    constraint processo_pk primary key using index tablespace &indx
, chave varchar2(32)
    constraint processo_chave_uk unique
, titulo varchar2(64)
    constraint processo_titulo_nn not null
, descricao varchar2(64)
    constraint processo_descricao_nn not null
, bloqueia char(1) default 'N'
, perfil varchar2(32)
    constraint processo_perfil_nn not null
) tablespace &data;

create or replace trigger processo_insert
  before insert
  on processo for each row
when (new.id is null)
begin
  :new.id := s_processo.nextval;
end;
/

comment on table  processo           is 'Processamento das ideias (moderação, avaliação, implantação etc).';
comment on column processo.chave     is 'Chave de pesquisa do processo.';
comment on column processo.descricao is 'Descrição do processo.';
comment on column processo.bloqueia  is 'Determina se o processo é bloqueante.';
comment on column processo.perfil    is 'Perfil para execução do processo.';
