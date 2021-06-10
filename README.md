# moodle_snapshot
Script para crear un snapshot exacto de moodle en un punto en el tiempo y luego poder deployear esta copia de seguridad como un sitio distinto en otro servidor

Este repositorio posee dos scripts

## snapshot.sh
`snapshot.sh` crea un snapshot de moodle y lo almacena en un archivo zip

Acepta los siguientes argumentos:
- `--moodledir=$moodledir`: la ruta donde se encuentra moodle
- `--datadir=$datadir`: la ruta donde se encuentra moodledata
- `--mysqluser=$mysqluser`: el usuario de mysql
- `--mysqlpassword=$mysqlpassword`: la contraseña del usuario mysql
- `--exportdir=$exportdir`: la ruta donde exportar el archivo, debe terminar en un archivo .zip y se debe tener permiso de escritura sobre la carpeta

Ejemplo: `./snapshot.sh --moodledir=/var/www/html/ --datadir=/var/moodledata/ --mysqluser=admin --mysqlpassword=password --exportdir=/home/user/file.zip`

El snapshot se crea a traves de exactamente los siguientes pasos
1. Se crea la carpeta `/tmp/moodle_snapshot`
2. Se crea un soft link de `moodledir` a `/tmp/moodle_snapshot/moodledir/`
3. Se crea un soft link `datadir` a `/tmp/moodle_snapshot/datadir/`
4. Se dumpea la base de datos a `/tmp/moodle_snapshot/db.sql`
5. Se zipea moodle_snapshot a `exportdir`

## deploy.sh
`deploy.sh` crea un nuevo virtualhost web de apache en base a un moodle_snapshot \
`deploy.sh` es enormemente mas complicado que `snapshot.sh`, recomiendo crear una copia de seguridad antes de probarlo

Acepta los siguientes argumentos:
- `--importdir=$importdir`: la ruta del snapshot a deployear
- `--name=$name`: la URL y nombre del nuevo sitio
- `--mysqluser=$mysqluser`: el usuario de mysql
- `--mysqlpassword=$mysqlpassword`: la contraseña del usuario mysql

Ejemplo: `./deploy.sh --importdir=/home/user/file.zip --name=snapshot-2021-1 --mysqluser=admin --password=password`

El deploy se hace exactamente a traves de los siguientes pasos:
1. Se descomprime `importdir` a `/tmp/moodle_snapshot`
2. Se mueve `/tmp/moodle_snapshot/moodledir/` a `/var/www/$name/`
3. Se mueve `/tmp/moodle_snapshot/datadir/` a `/var/moodledata-$name/`
4. Se restaura `/tmp/moodle_snapshot/db.sql` a mysql con el usuario `$mysqluser`, contraseña `$mysqlpassword`, en el schema `$name`
5. Se edita `/var/www/moodle-$name/config.php` y se actualiza:
    - El nombre del schema a `$name`
    - El usuario a `$mysqluser`
    - La contraseña a `$mysqlpassword`
    - El URL a `$name`
    - moodledata a `/var/www/moodledata-$name/`
6. Se crea el archivo `/tmp/moodle_snapshot/$name.conf` con la configuracion del virtualhost de apache con ServerName `$name` y DocumentRoot `/var/www/$name`.

Tras terminar el proceso debe mover el archivo `$name.conf` a la carpeta de sitios de apache y reiniciarlo para que se active, tambien debe configurar el DNS para apuntar apuntar la nueva URL al nuevo sitio
