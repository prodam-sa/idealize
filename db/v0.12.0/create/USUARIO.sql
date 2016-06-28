prompt ** USUARIO

alter table usuario rename column ad to administrador;

alter table usuario rename column mi to moderador;

alter table usuario add (
  avaliador char(1)
            default 'N'
);

comment on column usuario.avaliador is 'Perfil de avaliador de ideias? (S)im ou (N)ão.';
