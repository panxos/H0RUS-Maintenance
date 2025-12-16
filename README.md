# H0RUS System Maintenance PRO v3.0

![Bash](https://img.shields.io/badge/Lenguaje-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Arch%20%7C%20Debian%20%7C%20RHEL-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/Licencia-MIT-blue?style=for-the-badge)

**H0RUS Maintenance PRO** es la suite definitiva de mantenimiento y optimización automatizada para sistemas Linux. Diseñada para actuar como un "Administrador de Sistemas en una caja", combina la potencia de limpieza de herramientas tipo BleachBit con la seguridad de Snapper y la comodidad de las notificaciones móviles.

> **Novedad v3.0**: Ahora compatible automáticamente con familias **Arch Linux, Debian/Ubuntu y Fedora/RHEL**.

## 🚀 Características Principales

### 🛡️ Seguridad Primero (Integración con Snapper)
El sistema detecta automáticamente si `snapper` está configurado. Antes de cualquier operación crítica (como una actualización masiva o una limpieza profunda), crea un **Snapshot del Sistema de Archivos**.
- *¿Algo salió mal tras actualizar?* Simplemente revierte al snapshot creado automáticamente.
- *Tranquilidad total* al ejecutar scripts de mantenimiento.

### 🧹 Limpieza Profunda "Estilo BleachBit"
No se limita a borrar `tmp`. H0RUS va donde otros scripts no se atreven (con tu permiso):
- **Vacuum de Navegadores**: Compacta las bases de datos SQLite de Firefox, Chrome, Brave, Opera y Edge para recuperar velocidad de navegación.
- **Journal Systemd**: Rota y vacía logs antiguos que ocupan GBs innecesariamente.
- **Caché Inteligente**: Limpia el caché de paquetes (pacman/apt/dnf) pero mantiene las últimas versiones estables por seguridad.
- **Desarrollo**: Limpia cachés residuales de `npm`, `pip`, `cargo` y miniaturas.

### 🤖 Soporte Multi-Distro
Un solo script para gobernarlos a todos. H0RUS detecta tu distribución al inicio y adapta sus comandos:
- **Arch Linux**: Usa `pacman` y `paccache`.
- **Debian/Ubuntu/Mint**: Usa `apt`, `autoremove`.
- **RHEL/Fedora/CentOS**: Usa `dnf`.

### 📱 Notificaciones en Tiempo Real (Telegram)
¿Gestionas servidores o simplemente quieres saber cuándo termina tu PC de actualizarse?
- Recibe un **reporte detallado** en tu móvil vía Telegram al finalizar el mantenimiento.
- Alertas críticas diferenciadas (Iconos 🚨 vs ✅).
- Configuración guiada paso a paso integrada en el script.

### ⚡ Optimización 1-Click
Aplica las mejores prácticas de sysadmin con una sola opción:
- **Kernel Tuning**: Ajusta `vm.swappiness` y `vfs_cache_pressure` según tu RAM instalada.
- **Red (BBR)**: Activa el algoritmo de control de congestión TCP BBR de Google para mejorar la velocidad de red.
- **SSD Trim**: Fuerza un TRIM en discos SSD/NVMe para mantener el rendimiento.

### ⏲️ Automatización "Set & Forget"
Incluye un módulo para autoconfigurarse como un **Timer de Systemd**:
- Se ejecuta silenciosamente una vez a la semana.
- Realiza todo el mantenimiento sin intervención.
- Te envía un mensaje a Telegram cuando termina.

---

## 📦 Instalación

### Requisitos Previos
- **Bash**: Shell por defecto en la mayoría de distros.
- **Permisos de Root**: Necesarios para actualizaciones y limpieza profunda (`sudo`).
- **Opcional (Recomendado)**:
    - `snapper`: Para la funcionalidad de snapshots.
    - `curl`: Para las notificaciones de Telegram.

### Pasos
1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/tu-usuario/Update-System-Arch.git
    cd Update-System-Arch
    ```

2.  **Dar permisos de ejecución:**
    ```bash
    chmod +x maintenance.sh
    ```

3.  **Ejecutar:**
    ```bash
    ./maintenance.sh
    ```

---

## 🛠️ Guía de Uso y Configuración

Al iniciar el script, verás un menú interactivo. Aquí detallamos cada opción:

### 1. 🚀 Optimización 1-Click (Recomendado)
Esta es la opción para el día a día. Realiza una secuencia segura: `Snapshot -> Limpieza Suave -> Optimización Kernel/Red -> Actualización de Sistema`. Ideal para ejecutar una vez por semana manualmente.

### 2. 🧹 Limpieza Profunda (Modo BleachBit)
**¡Advertencia!** Esta opción está diseñada para liberar espacio drásticamente.
- Cerrará tus navegadores para optimizar sus bases de datos.
- Borrará caché de miniaturas y temporales de usuario.
- Vaciará logs del sistema.
*El script pedirá confirmación explícita antes de proceder.*

### 3. 📦 Actualizar Sistema
Un wrapper inteligente para tu gestor de paquetes.
- En Arch: `pacman -Syu`
- En Debian: `apt update && apt full-upgrade`
- En Fedora: `dnf update`
Siempre intenta crear un snapshot antes de empezar.

### 4. 🛡️ Auditoría de Seguridad
Realiza un chequeo rápido del estado de seguridad:
- Verifica si el Firewall (UFW/Firewalld) está activo.
- Busca intentos fallidos de login SSH recientes.

### 5. 📸 Gestionar Snapshots
Acceso directo a comandos de `snapper`. Permite crear snapshots manuales con descripciones personalizadas.

### 6. ⏱️ Configurar Programación Auto
Instala el servicio `h0rus-maintenance.timer` en `/etc/systemd/system/`. Esto programará el script para ejecutarse automáticamente (por defecto, semanalmente) en segundo plano.

### 7. 🔔 Configurar Notificaciones (Telegram)
Asistente para vincular el script con tu bot de Telegram.
1.  Crea un bot en Telegram hablando con [@BotFather](https://t.me/BotFather). Te dará un **API Token**.
2.  Avergigua tu ID de usuario hablando con [@userinfobot](https://t.me/userinfobot).
3.  Ingresa estos datos cuando el asistente lo pida.
Se guardarán en `~/.config/h0rus/config.conf` (o ruta equivalente según el script).

---

## 🤖 Modo Automático (CLI)
Si prefieres usar tus propios cronjobs o scripts, puedes invocar H0RUS en modo no interactivo:

```bash
sudo ./maintenance.sh --auto
```

Este comando:
1.  No pide confirmaciones.
2.  Ejecuta limpieza segura.
3.  Actualiza el sistema.
4.  Envía reporte a Telegram (si está configurado).

## ⚠️ Responsabilidad
Aunque H0RUS incluye mecanismos de seguridad (Snapshots, verificaciones), el mantenimiento de sistemas conlleva riesgos inherentes. El autor no se hace responsable de pérdida de datos. **Mantén siempre copias de seguridad de tus archivos importantes.**

## 📝 Licencia
Este proyecto está bajo la Licencia **MIT**. Eres libre de usarlo, modificarlo y distribuirlo.
