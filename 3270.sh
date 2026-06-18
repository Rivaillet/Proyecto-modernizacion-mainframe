#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' 

echo -e "${CYAN}=== [Cliente] Configuración de la consulta ===${NC}"
echo -n "Introduce el número de cuenta que deseas consultar: "
read CUENTA


if [ -z "$CUENTA" ]; then
  CUENTA="1"
  echo -e "${CYAN}No introdujiste ningún valor. Usando cuenta por defecto: $CUENTA${NC}"
fi

echo -e "\n${GREEN}=== [Cliente] Lanzando petición a la API Spring Boot para la cuenta: $CUENTA ===${NC}"

curl -s "http://localhost:8080/consultar?cuenta=$CUENTA"

echo -e "\n${GREEN}=======================================================${NC}"
