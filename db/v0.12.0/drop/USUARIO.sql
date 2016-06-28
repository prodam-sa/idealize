prompt ** USUARIO

alter table usuario drop (
  avaliador
);

alter table usuario rename column moderador to mi;

alter table usuario rename column administrador to ad;

