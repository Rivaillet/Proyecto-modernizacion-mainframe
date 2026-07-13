#!/bin/bash

echo "=================================================="
echo "🔐 [CAJERO] Inicio de Sesión - Modernización"
echo "=================================================="

# 1. Pedir el DNI de forma interactiva
read -p "👉 Introduce tu DNI: " DNI

# 2. Pedir la contraseña sin eco en la pantalla (modo oculto)
read -s -p "👉 Introduce tu contraseña: " PASSWORD
echo "" # Salto de línea tras ocultar la contraseña

# Validación simple por si el usuario deja campos vacíos
if [ -z "$DNI" ] || [ -z "$PASSWORD" ]; then
    echo -e "\n❌ Error: El DNI y la contraseña son obligatorios."
    exit 1
fi

echo -e "\n📡 Conectando con el Core Bancario Spring Boot + Mainframe..."

# 3. Lanzamos la petición de forma silenciosa (-s) y guardamos el JSON recibido
RESPONSE=$(curl -s -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d "{\"dni\":\"$DNI\", \"password\":\"$PASSWORD\"}")

# 4. Parseo rápido del JSON (Compatible 100% con Windows Git Bash usando sed)
STATUS=$(echo "$RESPONSE" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')
MESSAGE=$(echo "$RESPONSE" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p')
idCliente=$(echo "$RESPONSE" | sed -n 's/.*"idCliente":"\([^"]*\)".*/\1/p')

echo "--------------------------------------------------"

# 5. Lógica del Front en base al resultado de la API
if [ "$STATUS" = "OK" ]; then
    # Pintamos solo el mensaje limpio
    echo -e "🟢 \033[1m$MESSAGE\033[0m"
    echo "ID de Cliente asignado: $idCliente"
    
    # Preguntamos al usuario si quiere pasar al Paso 2
    read -p "❓ ¿Deseas consultar el saldo y movimientos de tu cuenta? (s/n): " OPCION
    
    if [[ "$OPCION" =~ ^[Ss]$ ]]; then
        echo -e "\n📡 [Paso 2] Solicitando cuentas asociadas al ID Cliente: $idCliente a la API..."
        
        # Petición al endpoint de consulta que acabamos de montar en Spring Boot
        RESPONSE_CUENTAS=$(curl -s -X GET http://localhost:8080/api/consulta/cuenta/$idCliente)
        
        echo "=================================================="
        echo "🏦  ESTADO DE CUENTAS DEL CLIENTE                 "
        echo "=================================================="
        
        # ─── PARSEO CON SED/GREP DE LA CONSULTA DE CUENTAS ───
        COD_RETORNO=$(echo "$RESPONSE_CUENTAS" | sed -n 's/.*"codigoRetorno":"\([^"]*\)".*/\1/p')
        TOTAL_CUENTAS=$(echo "$RESPONSE_CUENTAS" | sed -n 's/.*"totalCuentas":\([0-9]*\).*/\1/p')
        
        echo -e "Retorno Core: \033[33m$COD_RETORNO\033[0m | Número de Cuentas: \033[33m$TOTAL_CUENTAS\033[0m"
        echo "--------------------------------------------------"
        
        # Comprobamos si el número de cuentas es válido y mayor que cero
        if [ "$TOTAL_CUENTAS" -gt 0 ] 2>/dev/null; then
            
            # El truco: grep -o extrae en líneas independientes cada bloque de cuenta del array
            echo "$RESPONSE_CUENTAS" | grep -o '"iban":"[^"]*","saldoEfectivo":[0-9.-]*,"saldoEmbargado":[0-9.-]*' | while read -r CUENTA_LINE; do
                
                # Extraemos las variables individuales de cada línea
                IBAN=$(echo "$CUENTA_LINE" | sed -n 's/.*"iban":"\([^"]*\)".*/\1/p')
                SALDO=$(echo "$CUENTA_LINE" | sed -n 's/.*"saldoEfectivo":\([0-9.-]*\).*/\1/p')
                EMBARGADO=$(echo "$CUENTA_LINE" | sed -n 's/.*"saldoEmbargado":\([0-9.-]*\).*/\1/p')
                
                # Formateamos la salida visual para el usuario
                echo -e "💳 \033[1;36mIBAN:\033[0m $IBAN"
                echo -e "   💰 \033[32mSaldo Disp:\033[0m $SALDO €"
                if (( $(echo "$EMBARGADO > 0" | awk '{print ($1 " == 1")}') )) 2>/dev/null || [ "$EMBARGADO" != "0.0" -a "$EMBARGADO" != "0.00" -a "$EMBARGADO" != "0" ]; then
                    echo -e "   🔒 \033[31m⚠️ Embargado:\033[0m $EMBARGADO €"
                else
                    echo -e "   🔒 \033[90mEmbargado:\033[0m $EMBARGADO €"
                fi
                echo "--------------------------------------------------"
            done
        else
            echo -e "⚠️ \033[33mEl cliente no dispone de cuentas activas en el sistema.\033[0m"
            echo "--------------------------------------------------"
        fi
        
    else
        echo -e "\n👋 Operación cancelada. Gracias por usar el cajero."
    fi

else
    # Si la API devolvió un error, pintamos el mensaje de error de forma elegante
    if [ -z "$MESSAGE" ]; then
        echo -e "❌ Error: No se pudo conectar con el servidor API."
    else
        echo -e "❌ Acceso Denegado: $MESSAGE"
    fi
fi

echo -e "=================================================="
echo "🏁 Fin de la conexión."
echo "=================================================="