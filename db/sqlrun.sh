#!/bin/sh -x
#? PRODAM - 2015
#? SQLRun - Excecução de Arquivos SQL
#?
#? Uso:
#?   sqlrun [OPCAO] [ARQUIVO] [SQLARGS]
#?   sqlrun [ARQUIVO] [SQLARGS]
#?
#? Opções:
#?   -e   Ajusta o ambiente da aplicação.
#?   -h   Exibe esta mensagem.
#?

sqlplus=$(command -v sqlplus || command -v sqlplus64)

usage() {
  grep '^#?' < "$0" | cut -c4-
  exit 0
}

test "$#" = "0" && usage

while getopts he: option; do
  case $option in
    e  ) APP_ENV=$OPTARG ;;
    h|?) usage ;;
  esac
done

shift $((OPTIND - 1))

: ${1:?sql file is required}

sqlfile="${1}"

APP_ENV=${APP_ENV:-development}
APP_HOME=$(CDPATH='' cd $(dirname $0)/.. && pwd -P)
APP_CONF=${APP_HOME}/db/${APP_ENV}.ora

export NLS_LANG="${NLS_LANG:-AMERICAN_AMERICA.UTF8}"

# EXIT trap somente pelo bash
log=/tmp/app-sqlrun.$$.$RANDOM.log
trap "rm -rf $log" EXIT SIGHUP SIGINT SIGQUIT SIGTERM

shift 1

$sqlplus -S -L /nolog 2> $log <<sql
  set timing on;
  set heading off;
  set serveroutput on;
  spool $log
  connect $(cat "$APP_CONF")
  whenever oserror exit -1 rollback;
  whenever sqlerror exit sql.sqlcode rollback;
  show user;
  prompt Source $sqlfile
  @@$sqlfile $@
  show errors;
  quit;
sql

err=$?

test $err -gt 0 && {
  echo "[$USER@$HOSTNAME:$APP_ENV]: fail: $sqlfile" "$(cat $log)"
  exit $err
} || {
  exit 0
}

