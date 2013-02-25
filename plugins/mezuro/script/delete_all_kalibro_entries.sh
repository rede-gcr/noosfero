#!/bin/bash

DATABASE="kalibro_tests"
USER="kalibro"
PASSWORD="kalibro"
MYSQL_PARAMS="$DATABASE -u $USER -p$PASSWORD"
TABLES=($(mysql $MYSQL_PARAMS -e "show tables"))
LENGTH=${#TABLES}

i=1
while [ $i -le $LENGTH ]
  do  if [ ${#TABLES[$i]} -ne 0 ]
        then  mysql --force $MYSQL_PARAMS -e "delete from $DATABASE.${TABLES[$i]}"
      fi
      i=$(($i+1))
done
