prompt ** IDEIA

define indx = &1

alter table ideia add (
  situacao varchar2(32)
           default 'rascunho'
);

create index ideia_situacao_in on ideia(situacao) tablespace &indx;

comment on column ideia.situacao is 'Chave de registro da situação da ideia.';
