#!/system/bin/sh

# --- CONFIGURACIÓN DE ACTUALIZACIÓN ONLINE ---
VERSION_ACTUAL="1.3.2"
URL_VERSION="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/version.txt"
URL_SCRIPT="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/PedroModz666.sh"
URL_FIREBASE="https://pedromodz-keys-default-rtdb.firebaseio.com/keys"
# ---------------------------------------------

# Función universal para peticiones web (Compatible con Curl, Wget o Busybox)
enviar_web() {
    local url="$1"
    local data="$2"
    if command -v curl >/dev/null 2>&1; then
        if [ -n "$data" ]; then
            curl -s -X POST "$url" -d "$data"
        else
            curl -s "$url"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if [ -n "$data" ]; then
            wget -qO- --post-data="$data" "$url"
        else
            wget -qO- "$url"
        fi
    elif busybox wget --help >/dev/null 2>&1; then
        if [ -n "$data" ]; then
            busybox wget -qO- --post-data="$data" "$url"
        else
            busybox wget -qO- "$url"
        fi
    fi
}

verificar_actualizacion() {
    VERSION_REMOTA=$(enviar_web "$URL_VERSION?v=$(date +%s)" "" | tr -d '\r' | tr -d '\n' | xargs)
    
    if [ -n "$VERSION_REMOTA" ] && [ "$VERSION_ACTUAL" != "$VERSION_REMOTA" ]; then
        printf "\n\033[1;31m╔════════════════════════════════════════╗\n"
        printf "║    🔥 ¡NUEVA ACTUALIZACIÓN DISPONIBLE! 🔥    ║\n"
        printf "╚════════════════════════════════════════╝\033[0m\n"
        printf "\033[1;33mVersión actual: $VERSION_ACTUAL ➔ Nueva: $VERSION_REMOTA\033[0m\n"
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
            printf "\n\033[1;31m[!] Debes actualizar el script para continuar. Saliendo...\033[0m\n\n"
            exit 0
        fi
    fi
}

verificar_actualizacion

# --- CONFIGURACIÓN DE TELEGRAM ---
TOKEN_BOT="8683483962:AAGHLpFhkenCuKPbo_jDSlHP5RtomhR3L4Y"
TU_CHAT_ID="7024840116"

INTENTOS_MAXIMOS=3

# Colores ANSI Estilizados
ROJO='\033[1;31m'
VERDE='\033[1;32m'
AZUL='\033[1;36m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

# --- RUTAS DE ARCHIVOS Y DESTINO (Free Fire TH) ---
FILE_ORI="/storage/emulated/0/PedroMod666/Ori/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_PECHO="/storage/emulated/0/PedroMod666/Pecho/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_CUELLO="/storage/emulated/0/PedroMod666/Cuello/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_ROJO_V2="/storage/emulated/0/PedroMod666/666V2 Crítico Rojo/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

DESTINO="/data/user/0/com.dts.freefireth/files/contentcache/Compulsory/android/gameassetbundles/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

clear

# Variables globales para control de sesión
TIPO_USUARIO="normal"
KEY_INGRESADA=""

# --- VERIFICACIÓN DE KEY CONTRA FIREBASE ---
intentos=0
while [ "$intentos" -lt "$INTENTOS_MAXIMOS" ]; do
    printf "${AZUL}╔════════════════════════════════════════╗${RESET}\n"
    printf "${VERDE}║         ⚡️ PEDROMODZ666 ADMIN ⚡️       ║${RESET}\n"
    printf "${AZUL}╚════════════════════════════════════════╝${RESET}\n"
    printf "${MAGENTA}        🔐 VALIDACIÓN DE LICENCIA 🔐      ${RESET}\n"
    printf "${AZUL}════════════════════════════════════════${RESET}\n"
    printf "${AMARILLO} ➔ Ingresa tu Licencia: ${RESET}"
    read password

    password_limpia=$(printf "%s" "$password" | tr -cd 'A-Za-z0-9_-')

    if [ -z "$password_limpia" ]; then
        printf "\n${ROJO}[✖] Por favor ingresa una licencia válida.${RESET}\n\n"
        sleep 1
        clear
        continue
    fi

    # Petición al backend de Firebase para consultar la key específica
    RESPUESTA_FB=$(enviar_web "$URL_FIREBASE/$password_limpia.json" "")

    if [ -z "$RESPUESTA_FB" ]; then
        printf "\n${ROJO}[!] Error: Sin conexión a internet o servidor inaccesible.${RESET}\n"
        exit 1
    fi

    KEY_VALIDA=0
    MOTIVO_ERROR="Licencia inválida o no existe"

    if [ "$RESPUESTA_FB" != "null" ]; then
        ESTADO=$(printf "%s" "$RESPUESTA_FB" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        TIPO_USUARIO=$(printf "%s" "$RESPUESTA_FB" | grep -o '"type":"[^"]*"' | cut -d'"' -f4)
        EXPIRA=$(printf "%s" "$RESPUESTA_FB" | grep -o '"expires":"[^"]*"' | cut -d'"' -f4)
        AHORA=$(date +%s)

        if [ -z "$TIPO_USUARIO" ]; then
            TIPO_USUARIO="normal"
        fi

        if [ "$ESTADO" = "active" ]; then
            # Validación de expiración si no es permanente (null)
            if [ -z "$EXPIRA" ] || [ "$EXPIRA" = "null" ]; then
                KEY_VALIDA=1
            else
                EXPIRA_EPOCH=$(date -d "$EXPIRA" +%s 2>/dev/null || echo 0)
                if [ "$EXPIRA_EPOCH" -eq 0 ] || [ "$EXPIRA_EPOCH" -gt "$AHORA" ]; then
                    KEY_VALIDA=1
                else
                    MOTIVO_ERROR="La licencia ha expirado"
                fi
            fi
        else
            MOTIVO_ERROR="Licencia inactiva o bloqueada"
        fi
    fi

    if [ "$KEY_VALIDA" -eq 1 ]; then
        KEY_INGRESADA="$password_limpia"
        MSG_TG="👀 ACCESO SCRIPT FF:\nKey correcta usada ($TIPO_USUARIO): $password_limpia"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${VERDE}┌────────────────────────────────────────┐${RESET}\n"
        printf "${VERDE}│   [✔] ¡ACCESO AUTORIZADO! RANGO: ${TIPO_USUARIO^^}   │${RESET}\n"
        printf "${VERDE}└────────────────────────────────────────┘${RESET}\n\n"
        sleep 1.2
        break
    else
        intentos=$((intentos + 1))
        restantes=$((INTENTOS_MAXIMOS - intentos))
        
        MSG_TG="⚠️ Fallo de acceso ($MOTIVO_ERROR): $password_limpia (Restantes: $restantes)"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${ROJO}┌────────────────────────────────────────┐${RESET}\n"
        printf "${ROJO}│   [✖] $MOTIVO_ERROR (Restantes: $restantes) │${RESET}\n"
        printf "${ROJO}└────────────────────────────────────────┘${RESET}\n\n"
        
        if [ "$intentos" -ge "$INTENTOS_MAXIMOS" ]; then
            MSG_TG="🚫 Script bloqueado por exceder intentos de keys erróneas."
            enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

            printf "${ROJO}[!] Demasiados intentos fallidos. Saliendo...${RESET}\n\n"
            exit 1
        fi
        sleep 1.5
        clear
    fi
done

# --- FUNCIÓN DE INFO DEL DISPOSITIVO ---
obtener_info_dispositivo() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconocido")
    ANDROID_VER=$(getprop ro.build.version.release 2>/dev/null || echo "N/A")
    if [ -d /data/adb/magisk ] || [ -f /system/bin/su ] || [ -f /system/xbin/su ]; then
        ROOT_STATUS="${VERDE}Root [✔]${RESET}"
    else
        ROOT_STATUS="${AMARILLO}Sin Root${RESET}"
    fi
}

# --- MENÚ PRINCIPAL DINÁMICO ---
while true; do
    clear
    obtener_info_dispositivo

    printf "${AZUL}╔════════════════════════════════════════╗${RESET}\n"
    printf "${VERDE}            ⚡ PedroModz666 ⚡            \n"
    printf "${CYAN}     Rango: ${TIPO_USUARIO^^} | Soporte: +593986520417 \n"
    printf "${AZUL}╚════════════════════════════════════════╝${RESET}\n"
    printf "${AMARILLO} 📱 Celular:${RESET} $MODELO\n"
    printf "${AMARILLO} 🤖 Android:${RESET} $ANDROID_VER | $ROOT_STATUS\n"
    printf "${AZUL}════════════════════════════════════════${RESET}\n"
    printf "${AMARILLO}  [1]${RESET} 🚀 Bypass Avion\n"
    printf "${AMARILLO}  [2]${RESET} 🎯 Aimbot Pecho\n"
    printf "${AMARILLO}  [3]${RESET} 🎯 Aimbot Cuello\n"
    
    # Menú condicional: Si el usuario es VIP, mostramos la opción crítica
    if [ "$TIPO_USUARIO" = "vip" ]; then
        printf "${AMARILLO}  [4]${RESET} ⚠️🔥 Aimbot Crítico [VIP EXCLUSIVO]\n"
        printf "${AMARILLO}  [5]${RESET} 🛡️ Bypass Offline\n"
        printf "${AMARILLO}  [6]${RESET} ❌ Salir\n"
        OPCION_MAX=6
    else
        printf "${AMARILLO}  [4]${RESET} 🛡️ Bypass Offline\n"
        printf "${AMARILLO}  [5]${RESET} ❌ Salir\n"
        OPCION_MAX=5
    fi
    
    printf "${AZUL}════════════════════════════════════════${RESET}\n"
    printf "${VERDE} ➔ Selecciona una opción: ${RESET}"
    read opcion

    case "$opcion" in
        1)
            if [ -f "$FILE_ORI" ]; then
                printf "\n${CYAN}⏳ Inyectando Bypass en Free Fire TH...${RESET}\n"
                cat "$FILE_ORI" > "$DESTINO" 2>/dev/null
                printf "${VERDE}[✔] ¡Bypass Activado con éxito! Disfruta 🚀${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en la ruta Ori/${RESET}\n"
            fi
            ;;
        2)
            if [ -f "$FILE_PECHO" ]; then
                printf "\n${CYAN}⏳ Inyectando Aimbot Pecho...${RESET}\n"
                cat "$FILE_PECHO" > "$DESTINO" 2>/dev/null
                printf "${VERDE}[✔] ¡Aimbot Pecho aplicado correctamente! 🔥${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Pecho/${RESET}\n"
            fi
            ;;
        3)
            if [ -f "$FILE_CUELLO" ]; then
                printf "\n${CYAN}⏳ Inyectando Aimbot Cuello...${RESET}\n"
                cat "$FILE_CUELLO" > "$DESTINO" 2>/dev/null
                printf "${VERDE}[✔] ¡Aimbot Cuello aplicado correctamente! 🎯${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Cuello/${RESET}\n"
            fi
            ;;
        4)
            if [ "$TIPO_USUARIO" = "vip" ]; then
                # Opción exclusiva para usuarios VIP (Aimbot Crítico / 666V2)
                if [ -f "$FILE_ROJO_V2" ]; then
                    printf "\n${CYAN}⏳ Inyectando Aimbot Crítico VIP...${RESET}\n"
                    cat "$FILE_ROJO_V2" > "$DESTINO" 2>/dev/null
                    printf "${VERDE}[✔] ¡Aimbot Crítico aplicado con éxito! ⚠️🔥${RESET}\n"
                else
                    printf "\n${ROJO}[!] Error: No se encuentra el archivo en la ruta RojoV2/${RESET}\n"
                fi
            else
                # Si es normal, la opción 4 ejecuta el Bypass Offline
                printf "\n${CYAN}⏳ Ejecutando Bypass Offline...${RESET}\n"
                rm -rf /data/user/0/com.dts.freefireth/files/contentcache 2>/dev/null
                if [ $? -eq 0 ]; then
                    printf "${VERDE}[✔] BYPASS OFFLINE ACTIVO. 🛡️${RESET}\n"
                else
                    printf "${ROJO}[!] Error al eliminar. Asegúrate de otorgar permisos Root.${RESET}\n"
                fi
            fi
            ;;
        5)
            if [ "$TIPO_USUARIO" = "vip" ]; then
                # Opción 5 para VIP es el Bypass Offline
                printf "\n${CYAN}⏳ Ejecutando Bypass Offline...${RESET}\n"
                rm -rf /data/user/0/com.dts.freefireth/files/contentcache 2>/dev/null
                if [ $? -eq 0 ]; then
                    printf "${VERDE}[✔] BYPASS OFFLINE ACTIVO. 🛡️${RESET}\n"
                else
                    printf "${ROJO}[!] Error al eliminar. Asegúrate de otorgar permisos Root.${RESET}\n"
                fi
            else
                # Opción 5 para Normal es Salir
                printf "\n${CYAN}👋 ¡Hasta luego, crack!${RESET}\n\n"
                exit 0
            fi
            ;;
        6)
            if [ "$TIPO_USUARIO" = "vip" ]; then
                # Opción 6 para VIP es Salir
                printf "\n${CYAN}👋 ¡Hasta luego, crack!${RESET}\n\n"
                exit 0
            else
                printf "\n${ROJO}[!] Opción no válida.${RESET}\n"
            fi
            ;;
        *)
            printf "\n${ROJO}[!] Opción no válida, intenta de nuevo.${RESET}\n"
            ;;
    esac

    sleep 2
done
