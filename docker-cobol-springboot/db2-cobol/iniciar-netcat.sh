#!/bin/bash

echo "=== [Pasarela] Esperando a que DB2 responda en el puerto 50000... ==="
while ! nc -z localhost 50000; do
  sleep 2
done

su - db2inst1 -c "db2 connect to TESTDB && db2 'BIND /project/Mainframe/consultadb2.bnd VALIDATE RUN' && db2 terminate"
cd /project/Mainframe
cobc -x -fstatic-call consultadb2.cbl puente.c /opt/ibm/db2/V11.5/lib64/libdb2gmf.a -I/opt/ibm/db2/V11.5/include/cobol_mf -L/opt/ibm/db2/V11.5/lib64 -ldb2   

echo "=== [Pasarela] DB2 listo. Levantando Ncat en el puerto 9000... ==="
while true; do
  ncat -lk 0.0.0.0 9000 -e "/bin/su - db2inst1 -c /project/Mainframe/consultadb2"
  sleep 1
done