prompt ** USUARIO

alter table usuario add (
  mi char(1)
     default 'N'
);

comment on column usuario.mi is 'Moderador de ideias? (S)im ou (N)ão.';
