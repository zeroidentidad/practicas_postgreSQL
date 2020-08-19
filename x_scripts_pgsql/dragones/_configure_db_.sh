#!/bin/bash

export PGPASSWORD='usuario_password'

echo "Configurando nombredb"

dropdb -U usuariodb nombredb
createdb -U usuariodb nombredb

psql -U usuariodb nombredb < ./bin/sql/cuenta.sql
psql -U usuariodb nombredb < ./bin/sql/generacion.sql
psql -U usuariodb nombredb < ./bin/sql/dragon.sql
psql -U usuariodb nombredb < ./bin/sql/rasgos.sql
psql -U usuariodb nombredb < ./bin/sql/rasgoDragon.sql
psql -U usuariodb nombredb < ./bin/sql/cuentaDragon.sql

echo "nombredb configurada"