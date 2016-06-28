#!/bin/bash
#? PRODAM - 2015
#? Table - Gerador de SQL para tabelas
#?
#? Uso:
#?   sqlrun [OPTIONS] <TABLENAME>
#?
#? Opções:
#?   -c   SQL para criação da tabela.
#?   -u   SQL para atualização da tabela.
#?   -v   Ajusta a versão.
#?   -h   Exibe esta mensagem.
#?

usage() {
  grep '^#?' < "$0" | cut -c4-
  exit 0
}

test "$#" = "0" && usage

while getopts cuhv: option; do
  case $option in
    c  ) create_ddl_file=ddl_create ;;
    u  ) create_ddl_file=ddl_update ;;
    v  ) APP_VERSION=$OPTARG ;;
    h|?) usage ;;
  esac
done

shift $((OPTIND - 1))

: ${1:?sql file is required}

APP_ENV=${APP_ENV:-development}
APP_HOME=$(CDPATH='' cd $(dirname $0)/.. && pwd -P)
APP_VERSION=${APP_VERSION:-0.1.0}
APP_DBDIR=${APP_HOME}/db

export NLS_LANG="${NLS_LANG:-AMERICAN_AMERICA.UTF8}"

# EXIT trap somente pelo bash
log=/tmp/app-table$$.$RANDOM.log
trap "rm -rf $log" EXIT SIGHUP SIGINT SIGQUIT SIGTERM

: ${1:?table name is required}

table_name=$(echo $1 | tr [a-z] [A-Z])
table_alias=$(echo $1 | tr [A-Z] [a-z])
table_path=$APP_DBDIR/v$APP_VERSION
table_file=$table_name.sql

mkdir -p $table_path/{create,drop}

test -f $table_path/create/$table_file && {
  echo SQL DDL table $table_name already exists
  exit 1
}

echo "** $table_path/create/$table_file"

ddl_create() {
cat <<-end > $table_path/create/$table_file
prompt ** ${table_name}

define indx = &1
define data = &2

create sequence s_${table_alias} minvalue 1 start with 1 increment by 1;

create table ${table_alias} (
  id number(15,0)
     constraint ${table_alias}_pk primary key using index tablespace &indx
--, %referencia%_id number(15,0)
--                constraint ${table_alias}_fk references %referencia%(id)
) tablespace &data;

create or replace trigger ${table_alias}_insert
  before insert
  on ${table_alias} for each row
when (new.id is null)
begin
  :new.id := s_${table_alias}.nextval;
end;
/

comment on table  ${table_alias}      is 'Descrição de ${table_name}.';
-- comment on column ${table_alias}.atributo is 'Descrição do atributo.';
end

echo "** $table_path/drop/$table_file"

cat <<-end > $table_path/drop/$table_file
prompt ** ${table_name}

drop table ${table_alias} cascade constraints;

drop sequence s_${table_alias};
end
}

ddl_update() {
cat <<-end > $table_path/create/$table_file
prompt ** ${table_name}

alter table ${table_alias} add {
-- alter table ${table_alias} modify (
--  %column% %type%()
--    constraint ${table_alias}_fk references %column%(id)
--    constraint ${table_alias}_uk unique
--    constraint ${table_alias}_nn not null
);

-- comment on column ${table_alias}.%column% is 'Descrição da coluna.';
end

echo "** $table_path/drop/$table_file"

cat <<-end > $table_path/drop/$table_file
prompt ** ${table_name}

alter table ${table_alias} drop (
-- alter table ${table_alias} modify {
--  %column%
);
end
}

${create_ddl_file}

exit $?
