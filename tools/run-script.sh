#!/bin/bash
#? PRODAM - 2015, 2016
#? Run Script - Execução de Arquivos Shell/Script
#?
#? Uso:
#?   run-script.sh [OPCAO] [ARQUIVO] [ARGS]
#?   run-script.sh [ARQUIVO] [ARGS]
#?
#? Opções:
#?   -r   Runner: ruby|sql (default: .EXTNAME)
#?   -e   Ajusta o ambiente da aplicação.
#?   -h   Exibe esta mensagem.
#?

usage() {
  grep '^#?' < "$0" | cut -c4-
  exit 0
}

test "$#" = "0" && usage

while getopts r:e:h option; do
  case $option in
    r  ) APP_RUN=$OPTARG ;;
    e  ) APP_ENV=$OPTARG ;;
    h|?) usage ;;
  esac
done

shift $((OPTIND - 1))

: ${1:?Source (SQL|Ruby) file is required}

script="${1}"

test -r $script && {
  extname=$(echo ${script##*.})
} || {
  echo "File $script not found. Skipped."
  exit 0
}

runner=${runner:-$extname}
environment=${environment:-development}
workdir=$(CDPATH='' cd $(dirname $0)/.. && pwd -P)
config=${workdir}/db/${environment}.ora

export NLS_LANG="${NLS_LANG:-AMERICAN_AMERICA.UTF8}"

# EXIT trap somente pelo bash
log=/tmp/app-run.$$.$RANDOM.log
trap "rm -rf $log" EXIT SIGHUP SIGINT SIGQUIT SIGTERM

shift 1

run_sql() {
  local sqlplus=$(command -v sqlplus || command -v sqlplus64)

  $sqlplus -S -L /nolog 2> $log <<__end
    set timing on;
    set heading off;
    set serveroutput on;
    spool $log
    connect $(cat "$config")
    whenever oserror exit -1 rollback;
    whenever sqlerror exit sql.sqlcode rollback;
    show user;
    prompt Source $script
    @@$script $@
    show errors;
    quit;
__end
}

run_ruby() {
  local ruby="$(command -v ruby)"

  $ruby -Ilib:app -rbundler 2> $log <<__end
  load "$script"
__end
}

case $runner in
  sql ) run_sql  ;;
  rb  ) run_ruby ;;
  **  ) usage    ;;
esac

err=$?

test $err -gt 0 && {
  echo "[$USER@$HOSTNAME:$environment]: fail: $script" "$(cat $log)"
  exit $err
} || {
  exit 0
}

