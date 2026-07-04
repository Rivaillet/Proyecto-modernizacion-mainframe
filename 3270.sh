#!/bin/bash

echo "=================================================="
echo "🔐 [CAJERO] Inicio de Sesión - Modernización"
echo "=================================================="

# 1. Pedir el DNI de forma interactiva
read -p "👉 Introduce tu DNI: " DNI

# 2. Pedir la contraseña sin eco en la pantalla (modo oculto)
read -s -p "👉 Introduce tu contraseña: " PASSWORD
echo "" # Este echo es necesario para dar un salto de línea tras ocultar la contraseña

# Validación simple por si el usuario deja campos vacíos antes de lanzar el curl
if [ -z "$DNI" ] || [ -z "$PASSWORD" ]; then
    echo -e "\n❌ Error: El DNI y la contraseña son obligatorios."
    exit 1
fi

echo -e "\n📡 Enviando credenciales de forma segura a Spring Boot..."

# 3. Lanzar la petición HTTP POST inyectando las variables leídas
curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d "{\"dni\":\"$DNI\", \"password\":\"$PASSWORD\"}"

echo -e "\n\n=================================================="
echo "🏁 Fin de la conexión."
echo "=================================================="