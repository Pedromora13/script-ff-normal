#!/system/bin/sh

# --- CONFIGURACIÓN DE ACTUALIZACIÓN ONLINE ---
VERSION_ACTUAL="1.0"
URL_VERSION="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/version.txt"
URL_SCRIPT="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/PedroModz666.sh"
URL_KEYS="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/keys.txt"
# ---------------------------------------------

# Función universal para peticiones web en MT Manager
enviar_web() {
    url="$1"
    data="$2"
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
        printf "║     ¡NUEVA ACTUALIZACIÓN DISPONIBLE!   ║\n"
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

DESTINO="/data/user/0/com.dts.freefireth/files/contentcache/Compulsory/android/gameassetbundles/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

clear

# --- VERIFICACIÓN SOLO DE KEY ---
intentos=0
while [ "$intentos" -lt "$INTENTOS_MAXIMOS" ]; do
    printf "${AZUL}╔════════════════════════════════════════╗${RESET}\n"
    printf "${VERDE}║        🔥 PANEL VIP 🔥                 ║${RESET}\n"
    printf "${AZUL}╚════════════════════════════════════════╝${RESET}\n"
    printf "${MAGENTA}         🔐 PEDROMODZ666 🔐        ${RESET}\n"
    printf "${AZUL}════════════════════════════════════════${RESET}\n"
    printf "${AMARILLO} ➔ Ingresa tu Licencia: ${RESET}"
    read password

    # Descarga la lista de keys del nuevo repositorio limpia
    LISTA_KEYS=$(enviar_web "$URL_KEYS?v=$(date +%s)" "" | tr -d '\r')

    if [ -z "$LISTA_KEYS" ]; then
        printf "\n${ROJO}[!] Error: Sin conexión a internet o herramientas de red.${RESET}\n"
        exit 1
    fi
    
    # Busca si la key existe exacta en alguna línea
    LINEA_MATCH=$(echo "$LISTA_KEYS" | grep -E "^${password}(\\||$)" | head -n 1)

    if [ -n "$password" ] && [ -n "$LINEA_MATCH" ]; then
        # Notificación a Telegram indicando el uso de la key correcta
        MSG_TG="👀 SCRIPT FF NORMAL:\nKey correcta usada: $password"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${VERDE}┌────────────────────────────────────────┐${RESET}\n"
        printf "${VERDE}│    [✔] ¡LICENCIA VÁLIDA! BIENVENIDO CRACK │${RESET}\n"
        printf "${VERDE}└────────────────────────────────────────┘${RESET}\n\n"
        sleep 1.2
        break
    else
        intentos=$((intentos + 1))
        restantes=$((INTENTOS_MAXIMOS - intentos))
        
        # Notificación a Telegram de key errónea
        MSG_TG="⚠️ Key inválida intentada: $password (Restantes: $restantes)"
        enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

        printf "\n${ROJO}┌────────────────────────────────────────┐${RESET}\n"
        printf "${ROJO}│    [✖] KEY INCORRECTA (Intentos: $restantes)   │${RESET}\n"
        printf "${ROJO}└────────────────────────────────────────┘${RESET}\n\n"
        
        if [ "$intentos" -ge "$INTENTOS_MAXIMOS" ]; then
            MSG_TG="🚫 Script bloqueado por exceder intentos de keys inválidas."
            enviar_web "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" "chat_id=$TU_CHAT_ID&text=$MSG_TG" > /dev/null 2>&1

            printf "${ROJO}[!] Demasiados intentos fallidos. Saliendo...${RESET}\n\n"
            exit 1
        fi
        sleep 1.5
        clear
    fi
done

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    printf "${AZUL}╔════════════════════════════════════════╗${RESET}\n"
    printf "${VERDE}            ⚡ PedroModz666 ⚡            \n"
    printf "${CYAN}        Soporte: +593 986520417          \n"
    printf "${AZUL}╚════════════════════════════════════════╝${RESET}\n"
    printf "${AMARILLO}  [1]${RESET} 🚀 Bypass Avion\n"
    printf "${AMARILLO}  [2]${RESET} 🎯 Aimbot Pecho\n"
    printf "${AMARILLO}  [3]${RESET} 🎯 Aimbot Cuello\n"
    printf "${AMARILLO}  [4]${RESET} ❌ Salir\n"
    printf "${AZUL}════════════════════════════════════════${RESET}\n"
    printf "${VERDE} ➔ Selecciona una opción [1-4]: ${RESET}"
    read opcion

    case "$opcion" in
        1)
            if [ -f "$FILE_ORI" ]; then
                printf "\n${CYAN}⏳ Inyectando Bypass en Free Fire TH...${RESET}\n"
                cat "$FILE_ORI" > "$DESTINO"
                printf "${VERDE}[✔] ¡Bypass Activado con éxito! Disfruta 🚀${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en la ruta Ori/${RESET}\n"
            fi
            ;;
        2)
            if [ -f "$FILE_PECHO" ]; then
                printf "\n${CYAN}⏳ Inyectando Aimbot Pecho...${RESET}\n"
                cat "$FILE_PECHO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aimbot Pecho aplicado correctamente! 🔥${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Pecho/${RESET}\n"
            fi
            ;;
        3)
            if [ -f "$FILE_CUELLO" ]; then
                printf "\n${CYAN}⏳ Inyectando Aimbot Cuello...${RESET}\n"
                cat "$FILE_CUELLO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aimbot Cuello aplicado correctamente! 🎯${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en Cuello/${RESET}\n"
            fi
            ;;
        4)
            printf "\n${CYAN}👋 Saliendo. ¡Hasta luego, crack!${RESET}\n\n"
            exit 0
            ;;
        *)
            printf "\n${ROJO}[!] Opción no válida, intenta de nuevo.${RESET}\n"
            ;;
    esac

    sleep 2
done