#!/bin/bash

#extremely obtuse and confusing way to read data
for i in "$@"
do
case $i in
    --moodledir=*)
    MOODLEDIR="${i#*=}"
    shift
    ;;
    --datadir=*)
    DATADIR="${i#*=}"
    shift
    ;;
    --mysqluser=*)
    MYSQLUSER="${i#*=}"
    shift
    ;;
    --mysqlpassword=*)
    MYSQLPASSWORD="${i#*=}"
    shift
    ;;
    --exportdir=*)
    EXPORTDIR="${i#*=}"
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

#check all variables exist
if [[ $MOODLEDIR && $DATADIR && $MYSQLUSER && $MYSQLPASSWORD && $EXPORTDIR ]]
then
    echo "set"
else
    echo "
Error: faltan argumentos

Acepta los siguientes argumentos:
--moodledir=[moodledir]: la ruta donde se encuentra moodle
--datadir=[datadir]: la ruta donde se encuentra moodledata
--mysqluser=[mysqluser]: el usuario de mysql
--mysqlpassword=[mysqlpassword]: la contraseña del usuario mysql
--exportdir=[exportdir]: la ruta donde exportar el archivo, debe terminar en un archivo .zip y se debe tener permiso de escritura sobre la carpeta
"
    exit
fi


#create tmp, delete before if exists
rm -rf /tmp/moodle_snapshot
mkdir /tmp/moodle_snapshot

ln -s $MOODLEDIR /tmp/moodle_snapshot/moodledir
ln -s $DATADIR /tmp/moodle_snapshot/datadir

mysqldump -u $MYSQLUSER -p$MYSQLPASSWORD moodle > /tmp/moodle_snapshot/db.sql

zip $EXPORTDIR /tmp/moodle_snapshot -r

echo "Terminado"