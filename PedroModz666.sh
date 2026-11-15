#!/system/bin/sh

# --- CONFIGURACIÓN DE ACTUALIZACIÓN Y FIREBASE ---
VERSION_ACTUAL="1.3.1"
URL_VERSION="https://raw.githubusercontent.com/Pedromora13/PedroModz666/main/version.txt"
URL_SCRIPT="https://raw.githubusercontent.com/Pedromora13/PedroModz666/main/PedroModz666.sh"
URL_FIREBASE="https://pedromodz-keys-default-rtdb.firebaseio.com/keys"
# -------------------------------------------------

enviar_web() {
    local url="$1"
    local data="$2"
    
    if command -v curl >/dev/null 2>&1; then
        _curl="curl"
    elif [ -x /data/data/com.termux/files/usr/bin/curl ]; then
        _curl="/data/data/com.termux/files/usr/bin/curl"
    fi

    if [ -n "$_curl" ]; then
        if [ -n "$data" ]; then
            "$_curl" -s -X POST "$url" -d "$data"
        else
            "$_curl" -s "$url"
        fi
        return 0
    fi

    if command -v wget >/dev/null 2>&1; then
        _wget="wget"
    elif [ -x /data/data/com.termux/files/usr/bin/wget ]; then
        _wget="/data/data/com.termux/files/usr/bin/wget"
    fi

    if [ -n "$_wget" ]; then
        if [ -n "$data" ]; then
            "$_wget" -qO- --post-data="$data" "$url"
        else
            "$_wget" -qO- "$url"
        fi
        return 0
    fi

    if busybox wget --help >/dev/null 2>&1; then
        _bb="busybox"
    elif [ -x /system/xbin/busybox ]; then
        _bb="/system/xbin/busybox"
    elif [ -x /system/bin/busybox ]; then
        _bb="/system/bin/busybox"
    elif [ -x /sbin/busybox ]; then
        _bb="/sbin/busybox"
    fi

    if [ -n "$_bb" ]; then
        if [ -n "$data" ]; then
            "$_bb" wget -qO- --post-data="$data" "$url"
        else
            "$_bb" wget -qO- "$url"
        fi
        return 0
    fi

    if command -v toybox >/dev/null 2>&1; then
        toybox wget -qO- "$url" 2>/dev/null
        return 0
    fi
}

verificar_actualizacion() {
    VERSION_REMOTA=$(enviar_web "$URL_VERSION?v=$(date +%s)" "" | tr -d '\r' | tr -d '\n' | xargs)
    
    if [ -n "$VERSION_REMOTA" ] && [ "$VERSION_ACTUAL" != "$VERSION_REMOTA" ]; then
        printf "\n\033[1;31m¡Nueva actualización disponible ($VERSION_REMOTA)!\033[0m\n"
        printf "¿Deseas actualizar ahora? (s/n): "
        read respuesta
        if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
            printf "Actualizando script...\n"
            if command -v curl >/dev/null 2>&1; then
                curl -s -o "$0" "$URL_SCRIPT"
            elif command -v wget >/dev/null 2>&1; then
                wget -q -O "$0" "$URL_SCRIPT"
            else
                busybox wget -q -O "$0" "$URL_SCRIPT"
            fi
            chmod +x "$0"
            printf "\033[1;32m¡Actualización completada! Vuelve a abrir el script.\033[0m\n\n"
            exit 0
        else
            printf "\n\033[1;31m[!] Debes actualizar el script. Saliendo...\033[0m\n\n"
            exit 0
        fi
    fi
}

verificar_actualizacion

# --- CONFIGURACIÓN DE TELEGRAM ---
TOKEN_BOT="8683483962:AAGHLpFhkenCuKPbo_jDSlHP5RtomhR3L4Y"
TU_CHAT_ID="7024840116"
INTENTOS_MAXIMOS=3

ROJO='\033[1;31m'
VERDE='\033[1;32m'
AZUL='\033[1;36m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

FILE_ORI="/storage/emulated/0/PedroModz666/Ori/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_PECHO="/storage/emulated/0/PedroModz666/Pecho/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_CUELLO="/storage/emulated/0/PedroModz666/Cuello/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
DESTINO="/data/user/0/com.dts.freefiremax/files/contentcache/Compulsory/android/gameassetbundles/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

clear

# --- VERIFICACIÓN DE KEY CONTRA FIREBASE ---
intentos=0
while [ "$intentos" -lt "$INTENTOS_MAXIMOS" ]; do
    printf "${AZUL}======================================\n"
    printf "${VERDE}        🔐 INGRESA TU LICENCIA 🔐        \n"
    printf "${AZUL}======================================${RESET}\n"
    printf "${AMARILLO}Ingresa tu Licencia: ${RESET}"
    read password

    # Limpiar caracteres peligrosos para evitar consultas inválidas en la URL
    password_limpia=$(printf "%s" "$password" | tr -cd 'A-Za-z0-9_-')

    if [ -z "$password_limpia" ]; then
        printf "\n${ROJO}[✖] Ingresa una licencia válida.${RESET}\n\n"
        sleep 1
        clear
        continue
    fi

    # Consultar la key específica en Firebase
    RESPUESTA_FB=$(enviar_web "$URL_FIREBASE/$password_limpia.json" "")

    if [ -z "$RESPUESTA_FB" ]; then
        printf "\n${ROJO}[!] Error: No hay conexión a internet o al servidor.${RESET}\n"
        exit 1
    fi

    KEY_VALIDA=0
    MOTIVO_ERROR="Key inválida o no existe"

    if [ "$RESPUESTA_FB" != "null" ]; then
        # Extraer estado y fecha de expiración del JSON devuelto por Firebase
        ESTADO=$(printf "%s" "$RESPUESTA_FB" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        EXPIRA=$(printf "%s" "$RESPUESTA_FB" | grep -o '"expires":[0-9]*' | cut -d':' -f2)
        AHORA=$(date +%s)

        if [ "$ESTADO" = "active" ]; then
            if [ -z "$EXPIRA" ] || [ "$EXPIRA" -eq 0 ] || [ "$EXPIRA" -gt "$AHORA" ]; then
                KEY_VALIDA=1
            else
                MOTIVO_ERROR="Licencia expirada"
            fi
        else
            MOTIVO_ERROR="Licencia bloqueada o pausada"
        fi
    fi

    if [ "$KEY_VALIDA" -eq 1 ]; then
        MSG_TG="👀 USO DE SCRIPT: Key correcta usada: $password_limpia"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${VERDE}[✔] ¡Licencia aceptada! Acceso concedido.${RESET}\n\n"
        sleep 1
        break
    else
        intentos=$((intentos + 1))
        restantes=$((INTENTOS_MAXIMOS - intentos))
        
        MSG_TG="⚠️ Fallo de acceso ($MOTIVO_ERROR): $password_limpia (Restantes: $restantes)"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${ROJO}[✖] $MOTIVO_ERROR. Intentos restantes: $restantes${RESET}\n\n"
        if [ "$intentos" -ge "$INTENTOS_MAXIMOS" ]; then
            MSG_TG="🚫 Script bloqueado por exceder intentos fallidos."
            enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

            printf "${ROJO}[!] Demasiados intentos fallidos. Saliendo...${RESET}\n\n"
            exit 1
        fi
        sleep 1
        clear
    fi
done

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    printf "${AZUL}======================================\n"
    printf "${VERDE}             PedroModz666             \n"
    printf "${CYAN}     Contacto: +593 986520417         \n"
    printf "${AZUL}======================================\n"
    printf "${AMARILLO}        1)${RESET} Bypass Avion\n"
    printf "${AMARILLO}        2)${RESET} Aimbot Pecho\n"
    printf "${AMARILLO}        3)${RESET} Aimbot Cuello\n"
    printf "${AMARILLO}        4)${RESET} Salir\n"
    printf "${AZUL}======================================${RESET}\n"
    printf "${VERDE}Selecciona una opción [1-4]: ${RESET}"
    read opcion

    case "$opcion" in
        1)
            if [ -f "$FILE_ORI" ]; then
                printf "\n${CYAN}Inyectando Bypass...${RESET}\n"
                cat "$FILE_ORI" > "$DESTINO"
                printf "${VERDE}[✔] ¡Bypass Active Disfruta!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo Bypass/${RESET}\n"
            fi
            ;;
        2)
            if [ -f "$FILE_PECHO" ]; then
                printf "\n${CYAN}Inyectando Aimbot...${RESET}\n"
                cat "$FILE_PECHO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aimbot Pecho aplicado con éxito!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Pecho/${RESET}\n"
            fi
            ;;
        3)
            if [ -f "$FILE_CUELLO" ]; then
                printf "\n${CYAN}Inyectando Aimbot Cuello...${RESET}\n"
                cat "$FILE_CUELLO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aimbot Cuello aplicado con éxito!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Cuello/${RESET}\n"
            fi
            ;;
        4)
            printf "\n${CYAN}Saliendo. ¡Hasta luego, crack!${RESET}\n\n"
            exit 0
            ;;
        *)
            printf "\n${ROJO}[!] Opción no válida.${RESET}\n"
            ;;
    esac

    sleep 1.5
done
