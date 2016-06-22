prompt ** IDEIA

alter table ideia add (
  bloqueada char(1)
            default 'N'
);

comment on column ideia.bloqueada is 'Ideia bloqueada (S) sim ou (N) não.';
