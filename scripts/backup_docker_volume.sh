#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Uso: $0 nome_do_volume"
  exit 1
fi

VOLUME="$1"
TMP_DIR=$(mktemp -d)
BACKUP_FILE="${VOLUME}.tar.gz"

echo "[+] Criando backup do volume: $VOLUME"
docker run --rm -v "${VOLUME}":/volume -v "${TMP_DIR}":/backup busybox \
  sh -c "cd /volume && tar czf /backup/${BACKUP_FILE} ."

mv "${TMP_DIR}/${BACKUP_FILE}" ./
rm -rf "${TMP_DIR}"

echo "[+] Backup finalizado: ${BACKUP_FILE}"
