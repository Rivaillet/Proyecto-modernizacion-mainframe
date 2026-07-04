#!/bin/bash

echo "=== [Pasarela] Esperando a que DB2 responda en el puerto 50000... ==="
while ! nc -z localhost 50000; do
  sleep 2
done



echo "=== [Pasarela] Inicializando Base de Datos y Binds... ==="
su - db2inst1 -c "db2 connect to TESTDB && \
  db2 -tvf /var/custom/scripts-db/esquema.sql && \
  db2 -tvf /var/custom/scripts-db/datos.sql && \
  db2 'BIND /project/Mainframe/cobol/modulos/MLOGIN.bnd VALIDATE RUN' && \
  db2 terminate"

cd /project
#***cobc -x -fstatic-call Mainframe/cobol/main/MAIN.cbl Mainframe/cobol/modulos/MLOGIN.cbl Mainframe/puente.c /opt/ibm/db2/V11.5/lib64/libdb2gmf.a -I/opt/ibm/db2/V11.5/include/cobol_mf -L /opt/ibm/db2/V11.5/lib64 -ldb2
cobc -x -fstatic-call \
  -o /project/Mainframe/bin/MAIN/MAIN \
  Mainframe/cobol/main/MAIN.cbl \
  Mainframe/cobol/modulos/MLOGIN.cbl \
  Mainframe/puente.c \
  /opt/ibm/db2/V11.5/lib64/libdb2gmf.a \
  -I/opt/ibm/db2/V11.5/include/cobol_mf \
  -L /opt/ibm/db2/V11.5/lib64 \
  -ldb2

echo "=== [Pasarela] DB2 listo. Levantando Ncat en el puerto 9000... ==="
while true; do
  ncat -lk 0.0.0.0 9000 -c "/bin/su - db2inst1 -c /project/Mainframe/bin/MAIN/MAIN"
  sleep 1
done