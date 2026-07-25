#!/usr/bin/env bash
# ==============================================================================
# SRE Backup Agent Script - FinFlow / AWS Cloud Resiliency & Scaling Sprint
# ==============================================================================

set -e # Salir en caso de error

# Directorio de respaldos
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILENAME="backup_${TIMESTAMP}.sql.gz"
BACKUP_FILEpath="${BACKUP_DIR}/${BACKUP_FILENAME}"

# Nombre del contenedor de Base de Datos y usuario DB
DB_CONTAINER="postgres-db"
DB_USER="postgres"

echo "=========================================="
echo "🤖 [SRE Agent] Iniciando respaldo de BD..."
echo "=========================================="

# 1. Crear el directorio de backups si no existe
mkdir -p "${BACKUP_DIR}"

# 2. Ejecutar pg_dumpall dentro del contenedor y comprimir con gzip
echo "📦 Generando Dump SQL comprimido..."
docker exec -t ${DB_CONTAINER} pg_dumpall -c -U ${DB_USER} | gzip > "${BACKUP_FILEpath}"

# 3. Validar existencia y tamaño del archivo generado (> 0 bytes)
if [ -f "${BACKUP_FILEpath}" ]; then
    FILE_SIZE=$(stat -c%s "${BACKUP_FILEpath}" 2>/dev/null || stat -f%z "${BACKUP_FILEpath}" 2>/dev/null || echo "0")
    
    if [ "$FILE_SIZE" -gt 0 ]; then
        echo "✅ Respaldo exitoso: ${BACKUP_FILEpath}"
        echo "📊 Tamaño del archivo: ${FILE_SIZE} bytes (> 0 bytes OK)"
        echo "=========================================="
        exit 0
    else
        echo "❌ ERROR: El archivo de respaldo se generó pero tiene 0 bytes."
        exit 1
    fi
else
    echo "❌ ERROR: No se pudo crear el archivo de respaldo."
    exit 1
fi
