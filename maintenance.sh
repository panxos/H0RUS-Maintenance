#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  ██╗  ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗    ███╗   ███╗ █████╗ ██╗███╗   ██╗████████╗
#  ██║  ██║██╔═══██╗██╔══██╗██║   ██║██╔════╝    ████╗ ████║██╔══██╗██║████╗  ██║╚══██╔══╝
#  ███████║██║   ██║██████╔╝██║   ██║███████╗    ██╔████╔██║███████║██║██╔██╗ ██║   ██║
#  ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║    ██║╚██╔╝██║██╔══██║██║██║╚██╗██║   ██║
#  ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║    ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║   ██║
#  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝
#
#  H0RUS System Maintenance PRO - Multi-Distro & Advanced Optimization
#  Versión: 3.0 - The "BleachBit" Killer
#  Author: Panxos 
#  Repository: https://github.com/panxos/H0RUS-Maintenance
#═══════════════════════════════════════════════════════════════════════════════

set -o pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN GLOBAL
# ═══════════════════════════════════════════════════════════════════════════════

VERSION="3.0"
SCRIPT_NAME="H0RUS Maintenance"
CONFIG_DIR="$HOME/.config/h0rus"
BACKUP_DIR="$HOME/.local/share/h0rus/backups"
LOG_DIR="$HOME/.local/share/h0rus/logs"
LOG_FILE="$LOG_DIR/maintenance_$(date +%Y%m%d_%H%M%S).log"
LOCK_FILE="/tmp/h0rus-maintenance.lock"
EXCLUSIONS_FILE="$CONFIG_DIR/excluded_paths.conf"
CONFIG_FILE="$CONFIG_DIR/config.conf"

# Crear estructura de directorios
mkdir -p "$BACKUP_DIR" "$CONFIG_DIR" "$LOG_DIR"

# Colores y Estilos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# Iconos
ICON_OK="✓"
ICON_FAIL="✗"
ICON_WARN="⚠"
ICON_INFO="ℹ"
ICON_CLEAN="🧹"
ICON_PACKAGE="📦"
ICON_DISK="💾"
ICON_ROCKET="🚀"
ICON_SHIELD="🛡"
ICON_TRASH="🗑"
ICON_NET="🌐"
ICON_CPU="⚡"
ICON_TEMP="🌡"
ICON_LOCK="🔒"
ICON_BACKUP="💿"
ICON_GAME="🎮"
ICON_TIME="⏱"
ICON_SNAP="📸"
ICON_NOTIF="🔔"

# Navegadores soportados para limpieza
BROWSERS=("firefox" "google-chrome" "chromium" "brave" "opera" "vivaldi" "microsoft-edge")

# Variables de Estado
IS_LAPTOP=false
IS_SSD=false
DISTRO_FAMILY=""
PKG_MANAGER=""
PKG_UPDATE=""
PKG_CLEAN=""
PKG_INSTALL=""
SNAPPER_AVAILABLE=false
TELEGRAM_ENABLED=false
TELEGRAM_TOKEN=""
TELEGRAM_CHAT_ID=""

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCIONES BÁSICAS DE LOGGING & UI
# ═══════════════════════════════════════════════════════════════════════════════

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   ██╗  ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗    System Optimizer            ║
║   ██║  ██║██╔═══██╗██╔══██╗██║   ██║██╔════╝    ─────────────────           ║
║   ███████║██║   ██║██████╔╝██║   ██║███████╗    Multi-Distro Edition        ║
║   ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║    Automated Maintenance       ║
║   ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║    & Security Suite            ║
║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝                                ║
║                                                                               ║
EOF
    # Ajuste de marco dinámico (total width 81 chars: 1 border + 79 space + 1 border)
    # Top border has 79 '═', total length 81.
    local info_text="v$VERSION - $DISTRO_FAMILY Detected"
    printf "║   %-75s ║\n" "$info_text"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${WHITE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "SECTION: $1"
}

print_subsection() {
    echo ""
    echo -e "  ${GRAY}┌─ ${WHITE}$1${GRAY} ─────────────────────────────────────────────────${NC}"
}

print_status() {
    local status=$1
    local message=$2
    case $status in
        "ok")    echo -e "  ${GREEN}${ICON_OK}${NC} ${message}" ;;
        "fail")  echo -e "  ${RED}${ICON_FAIL}${NC} ${message}" ;;
        "warn")  echo -e "  ${YELLOW}${ICON_WARN}${NC} ${message}" ;;
        "info")  echo -e "  ${CYAN}${ICON_INFO}${NC} ${message}" ;;
        "clean") echo -e "  ${MAGENTA}${ICON_CLEAN}${NC} ${message}" ;;
        "skip")  echo -e "  ${GRAY}○${NC} ${DIM}${message}${NC}" ;;
    esac
    log "$status: $message"
}

confirm_action() {
    local message=$1
    echo -e "\n${YELLOW}${ICON_WARN} ${message}${NC}"
    read -p "  ¿Continuar? [s/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Ss]$ ]]
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p $pid &>/dev/null; do
        for i in $(seq 0 9); do
            printf "\r  ${CYAN}${spinstr:$i:1}${NC} %s" "$2"
            sleep $delay
        done
    done
    printf "\r"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN & NOTIFICACIONES
# ═══════════════════════════════════════════════════════════════════════════════

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        if [[ -n "$TELEGRAM_TOKEN" ]] && [[ -n "$TELEGRAM_CHAT_ID" ]]; then
            TELEGRAM_ENABLED=true
        fi
    fi
    
    # Check dependencies
    if command -v snapper &>/dev/null; then
        SNAPPER_AVAILABLE=true
    fi
}

setup_telegram() {
    echo ""
    print_subsection "Configuración de Telegram Bot"
    echo -e "  ${GRAY}Necesitas un Bot Token (@BotFather) y tu Chat ID (@userinfobot)${NC}"
    
    read -p "  Ingrese Bot Token (o Enter para omitir): " token
    if [[ -n "$token" ]]; then
        read -p "  Ingrese Chat ID: " chat_id
        
        # Test
        if curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chat_id" -d text="H0RUS: Test de conexión exitoso" | grep -q '"ok":true'; then
            print_status "ok" "Conexión exitosa"
            
            # Guardar config
            echo "TELEGRAM_TOKEN=\"$token\"" > "$CONFIG_FILE"
            echo "TELEGRAM_CHAT_ID=\"$chat_id\"" >> "$CONFIG_FILE"
            print_status "ok" "Configuración guardada en $CONFIG_FILE"
        else
            print_status "fail" "No se pudo conectar con el Bot. Verifique token/ID."
        fi
    else
        print_status "skip" "Configuración de Telegram omitida"
    fi
}

send_notification() {
    local message="$1"
    local level="${2:-normal}" # normal, critical
    
    # Desktop Notification
    if command -v notify-send &>/dev/null; then
        notify-send -u "$level" -a "H0RUS Maintenance" "Sistema Optimizado" "$message" 2>/dev/null
    fi
    
    # Telegram Notification
    if $TELEGRAM_ENABLED; then
        local icon="ℹ️"
        [[ "$level" == "critical" ]] && icon="🚨"
        [[ "$message" == *"Éxito"* ]] && icon="✅"
        
        local text="$icon *H0RUS Maintenance Report*%0AHost: $(hostname)%0A%0A$message"
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d parse_mode="Markdown" \
            -d text="$text" >/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# DETECCIÓN DE SISTEMA Y DISTRO
# ═══════════════════════════════════════════════════════════════════════════════

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            arch|manjaro|endeavouros)
                DISTRO_FAMILY="Arch"
                PKG_MANAGER="pacman"
                PKG_UPDATE="pacman -Syu --noconfirm"
                PKG_CLEAN="pacman -Sc --noconfirm"
                PKG_INSTALL="pacman -S --noconfirm --needed"
                ;;
            debian|ubuntu|linuxmint|pop)
                DISTRO_FAMILY="Debian"
                PKG_MANAGER="apt"
                PKG_UPDATE="apt update && apt full-upgrade -y"
                PKG_CLEAN="apt autoremove -y && apt clean"
                PKG_INSTALL="apt install -y"
                ;;
            fedora|rhel|centos|alma)
                DISTRO_FAMILY="RedHat"
                PKG_MANAGER="dnf"
                PKG_UPDATE="dnf update -y"
                PKG_CLEAN="dnf autoremove -y && dnf clean all"
                PKG_INSTALL="dnf install -y"
                ;;
            *)
                DISTRO_FAMILY="Unknown"
                print_status "warn" "Distribución no soportada oficialmente: $ID"
                ;;
        esac
    fi
    
    # Hardware Detection
    [[ -d /sys/class/power_supply/BAT0 ]] && IS_LAPTOP=true
    grep -q 0 /sys/block/sd*/queue/rotational 2>/dev/null && IS_SSD=true
    grep -q 0 /sys/block/nvme*/queue/rotational 2>/dev/null && IS_SSD=true
}

# ═══════════════════════════════════════════════════════════════════════════════
# GESTIÓN DE SNAPSHOTS (SNAPPER)
# ═══════════════════════════════════════════════════════════════════════════════

create_snapshot() {
    local desc="$1"
    local type="${2:-single}" # pre, post, single
    
    if $SNAPPER_AVAILABLE; then
        print_subsection "System Snapshot (Snapper)"
        
        # Verificar config 'root'
        if sudo snapper -c root list &>/dev/null; then
            local snap_out
            snap_out=$(sudo snapper -c root create --description "H0RUS: $desc" --cleanup-algorithm number --print-number 2>&1)
            
            if [[ $? -eq 0 ]]; then
                print_status "ok" "Snapshot #$snap_out creado: $desc"
                log "Snapshot $snap_out created ($desc)"
            else
                print_status "fail" "Error al crear snapshot: $snap_out"
            fi
        else
            print_status "warn" "Configuración 'root' de snapper no encontrada"
        fi
    else
        print_status "skip" "Snapper no instalado - Saltando snapshot"
    fi
}

cleanup_old_snapshots() {
    if $SNAPPER_AVAILABLE; then
        # Snapper gestiona su propia limpieza via timeline/number cleanup,
        # pero podemos forzar una limpieza de snapshots vacíos o muy viejos si fuera necesario.
        # Por ahora, confiamos en el algoritmo 'number' invocado en create.
        :
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MÓDULO DE LIMPIEZA PROFUNDA (BLEACHBIT STYLE)
# ═══════════════════════════════════════════════════════════════════════════════

clean_browser_databases() {
    local browser_name=$1
    local db_path=$2
    
    if [[ -f "$db_path" ]]; then
        local size_before=$(du -b "$db_path" | cut -f1)
        sqlite3 "$db_path" "VACUUM;" 2>/dev/null
        local size_after=$(du -b "$db_path" | cut -f1)
        
        if [[ $size_before -gt $size_after ]]; then
            local saved=$((size_before - size_after))
            print_status "clean" "Vacuum $browser_name: Ahorrado $(numfmt --to=iec $saved)"
        fi
    fi
}

run_deep_clean() {
    print_section "${ICON_CLEAN} LIMPIEZA PROFUNDA (BleachBit Style)"
    
    # 1. System Logs & Journals
    print_subsection "Logs del Sistema"
    local journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.?\d*[GMK]')
    sudo journalctl --vacuum-time=3d 2>/dev/null
    sudo journalctl --vacuum-size=100M 2>/dev/null
    print_status "clean" "Journal vaciado (Antes: $journal_size)"
    
    # 2. Package Manager Cache
    print_subsection "Caché de Paquetes ($DISTRO_FAMILY)"
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        # Arch: paccache es más seguro que -Sc
        if command -v paccache &>/dev/null; then
            sudo paccache -rk1 2>/dev/null # Keep only 1 version
            print_status "clean" "Pacman cache (paccache keep 1)"
        else
            sudo pacman -Sc --noconfirm
        fi
        # Huérfanos
        if pacman -Qtdq &>/dev/null; then
            sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null
            print_status "clean" "Paquetes huérfanos eliminados"
        fi
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt autoremove -y && sudo apt clean
        print_status "clean" "APT autoremove & clean ejecutado"
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf autoremove -y && sudo dnf clean all
        print_status "clean" "DNF autoremove & clean ejecutado"
    fi
    
    # 3. Miniaturas (Thumbnails)
    print_subsection "Miniaturas & Caché Usuario"
    rm -rf ~/.cache/thumbnails/* 2>/dev/null
    print_status "clean" "Miniaturas eliminadas"
    
    # 4. Navegadores (Vacuum de Bases de Datos - Firefox/Chrome)
    # Requiere que el navegador esté cerrado idealmente
    print_subsection "Optimización de Navegadores"
    if pgrep -x "firefox" >/dev/null || pgrep -x "chrome" >/dev/null; then
        print_status "warn" "Navegadores abiertos - Saltando optimización DB para evitar corrupción"
    else
        # Firefox
        find ~/.mozilla/firefox -name "*.sqlite" -print0 2>/dev/null | while IFS= read -r -d '' db; do
            clean_browser_databases "Firefox" "$db"
        done
        # Chrome/Brave/Etc (History files are sqlite)
        find ~/.config/google-chrome -name "History" -print0 2>/dev/null | while IFS= read -r -d '' db; do
            clean_browser_databases "Chrome" "$db"
        done
    fi
    
    # 5. Archivos Temporales
    print_subsection "Archivos Temporales"
    rm -rf ~/.cache/pip/* 2>/dev/null
    rm -rf ~/.cache/npm/* 2>/dev/null
    sudo rm -rf /var/tmp/* 2>/dev/null
    print_status "clean" "Cachés de desarrollo y temporales limpiados"
}

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIMIZACIÓN & SEGURIDAD
# ═══════════════════════════════════════════════════════════════════════════════

run_optimization() {
    print_section "${ICON_ROCKET} OPTIMIZACIÓN DEL SISTEMA"
    
    # 1. Swappiness
    print_subsection "Memoria Virtual"
    local total_ram=$(free -g | awk '/^Mem:/ {print $2}')
    local swappiness=60
    [[ $total_ram -ge 16 ]] && swappiness=10
    [[ $total_ram -ge 32 ]] && swappiness=5
    
    # Aplicar temporalmente
    sudo sysctl vm.swappiness=$swappiness >/dev/null
    print_status "ok" "Swappiness ajustado a $swappiness"
    
    # 2. Filesystem
    print_subsection "Filesystem"
    if $IS_SSD; then
        sudo fstrim -av 2>/dev/null | head -1 | awk '{print "Trim ejecutado: " $0}'
        print_status "ok" "TRIM ejecutado en SSDs"
    fi
    
    # 3. Network (BBR)
    # Verificar si ya está activo
    if ! sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/99-h0rus-net.conf >/dev/null
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/99-h0rus-net.conf >/dev/null
        sudo sysctl --system >/dev/null 2>&1
        print_status "ok" "Algoritmo BBR activado para TCP"
    else
        print_status "ok" "BBR ya está activo"
    fi
}

check_security() {
    print_section "${ICON_SHIELD} VERIFICACIÓN DE SEGURIDAD"
    
    # Failed Logins
    local failed_ssh=$(journalctl -u sshd --since "24 hours ago" 2>/dev/null | grep -c "Failed password")
    if [[ $failed_ssh -gt 0 ]]; then
        print_status "warn" "SSH: $failed_ssh intentos fallidos en 24h"
    else
        print_status "ok" "SSH: Sin intentos fallidos recientes"
    fi
    
    # Firewall Check
    if command -v ufw &>/dev/null; then
        if sudo ufw status | grep -q "active"; then
            print_status "ok" "Firewall UFW: Activo"
        else
            print_status "fail" "Firewall UFW: Inactivo"
        fi
    elif command -v firewall-cmd &>/dev/null; then
         if sudo firewall-cmd --state 2>&1 | grep -q "running"; then
            print_status "ok" "Firewalld: Activo"
         else
            print_status "fail" "Firewalld: Inactivo"
         fi
    else
        print_status "warn" "No se detectó firewall conocido"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# AUTOMATIZACIÓN (TIMER/CRON)
# ═══════════════════════════════════════════════════════════════════════════════

setup_schedule() {
    print_section "${ICON_TIME} PROGRAMACIÓN DE MANTENIMIENTO"
    
    # Crear script wrapper para cron/systemd
    local wrapper_path="/usr/local/bin/h0rus-auto"
    
    echo "#!/bin/bash" | sudo tee "$wrapper_path" >/dev/null
    echo "$0 --auto" | sudo tee -a "$wrapper_path" >/dev/null
    sudo chmod +x "$wrapper_path"
    
    # Preferir Systemd Timer
    if pidof systemd >/dev/null; then
        local service_file="/etc/systemd/system/h0rus-maintenance.service"
        local timer_file="/etc/systemd/system/h0rus-maintenance.timer"
        
        cat << EOF | sudo tee "$service_file" >/dev/null
[Unit]
Description=H0RUS System Maintenance
After=network.target

[Service]
Type=oneshot
ExecStart=$wrapper_path
EOF

        cat << EOF | sudo tee "$timer_file" >/dev/null
[Unit]
Description=Run H0RUS weekly

[Timer]
OnCalendar=weekly
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable --now h0rus-maintenance.timer
        print_status "ok" "Systemd Timer instalado (Semanal)"
    else
        # Fallback a Cron
        (crontab -l 2>/dev/null; echo "0 3 * * 0 $wrapper_path") | crontab -
        print_status "ok" "Cron job instalado (Domingos 3 AM)"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MODOS DE EJECUCIÓN
# ═══════════════════════════════════════════════════════════════════════════════

run_auto_mode() {
    # Modo no interactivo para cron/timers
    log "AUTO: Iniciando mantenimiento automático"
    
    # 1. Snapshot
    create_snapshot "AutoMain-Pre" "pre"
    
    # 2. Update
    log "AUTO: Actualizando sistema..."
    eval "$PKG_UPDATE" >> "$LOG_FILE" 2>&1
    
    # 3. Clean
    run_deep_clean >> "$LOG_FILE" 2>&1
    
    # 4. Report
    if [[ $? -eq 0 ]]; then
        send_notification "Mantenimiento automático completado con éxito." "normal"
    else
        send_notification "Mantenimiento automático finalizó con errores. Revisar logs." "critical"
    fi
    
    # 5. Snapshot Post (opcional, si hubo cambios grandes)
    # create_snapshot "AutoMain-Post" "post"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    while true; do
        print_header
        
        echo -e "  ${WHITE}Panel de Control:${NC}"
        echo -e "  ${CYAN}1)${NC} ${ICON_ROCKET}  Optimización 1-Click (Recomendado)"
        echo -e "  ${CYAN}2)${NC} ${ICON_CLEAN}  Limpieza Profunda (BleachBit Mode)"
        echo -e "  ${CYAN}3)${NC} ${ICON_PACKAGE} Actualizar Sistema ($PKG_MANAGER)"
        echo -e "  ${CYAN}4)${NC} ${ICON_SHIELD} Auditoría de Seguridad"
        echo -e "  ${CYAN}5)${NC} ${ICON_SNAP} Gestionar Snapshots (Snapper)"
        echo -e "  ${CYAN}6)${NC} ${ICON_TIME} Configurar Programación Auto"
        echo -e "  ${CYAN}7)${NC} ${ICON_NOTIF} Configurar Notificaciones (Telegram)"
        echo -e "  ${CYAN}0)${NC} Salir"
        echo ""
        
        read -p "  Seleccione: " opt
        
        case $opt in
            1)
                create_snapshot "Pre-Optimization"
                run_deep_clean
                run_optimization
                eval "$PKG_UPDATE"
                send_notification "Optimización manual completada"
                read -p "  Presione Enter..."
                ;;
            2)
                echo -e "\n  ${RED}${BOLD}IMPORTANTE:${NC} Esto borrará caché de navegadores, logs y temporales."
                if confirm_action "¿Proceder con limpieza agresiva?"; then
                    create_snapshot "Pre-DeepClean"
                    run_deep_clean
                    send_notification "Limpieza profunda completada"
                fi
                read -p "  Presione Enter..."
                ;;
            3)
                print_section "Actualizando Sistema"
                create_snapshot "Pre-Update"
                eval "$PKG_UPDATE"
                read -p "  Presione Enter..."
                ;;
            4)
                check_security
                read -p "  Presione Enter..."
                ;;
            5)
                create_snapshot "Manual-Snapshot"
                read -p "  Presione Enter..."
                ;;
            6)
                setup_schedule
                read -p "  Presione Enter..."
                ;;
            7)
                setup_telegram
                read -p "  Presione Enter..."
                ;;
            0)
                exit 0
                ;;
            *)
                print_status "fail" "Opción inválida"
                sleep 1
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# INIT
# ═══════════════════════════════════════════════════════════════════════════════

# Detectar configuración inicial
detect_distro
load_config

# Rutina de argumentos
if [[ "$1" == "--auto" ]]; then
    run_auto_mode
elif [[ "$1" == "--help" ]]; then
    echo "H0RUS Maintenance PRO $VERSION"
    echo "Usage: $0 [--auto | --help]"
else
    # Verificar root (necesario para mantenimiento real)
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Nota: Algunas funciones requieren root.${NC}"
        # No forzamos exit, pero los comandos sudo pedirán pass
    fi
    show_menu
fi
