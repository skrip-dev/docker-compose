#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Uso: $0 arquivo_backup.tar.gz nome_do_volume_destino"
  echo "Exemplo: $0 meu_volume.tar.gz novo_volume"
  exit 1
fi

BACKUP_FILE="$1"
VOLUME_DESTINO="$2"
TMP_DIR=$(mktemp -d)

# Verifica se o arquivo de backup existe
if [ ! -f "$BACKUP_FILE" ]; then
  echo "[-] Erro: Arquivo de backup '$BACKUP_FILE' não encontrado!"
  exit 1
fi

# Verifica se o volume existe, se não existir, cria
if ! docker volume inspect "$VOLUME_DESTINO" >/dev/null 2>&1; then
  echo "[+] Volume '$VOLUME_DESTINO' não existe. Criando..."
  docker volume create "$VOLUME_DESTINO"
fi

echo "[+] Copiando backup para diretório temporário..."
cp "$BACKUP_FILE" "$TMP_DIR/"

echo "[+] Limpando volume de destino: $VOLUME_DESTINO"
docker run --rm -v "${VOLUME_DESTINO}":/volume busybox \
  sh -c "rm -rf /volume/* /volume/.[^.]* /volume/..?*" 2>/dev/null || true

echo "[+] Restaurando backup no volume: $VOLUME_DESTINO"
docker run --rm -v "${VOLUME_DESTINO}":/volume -v "${TMP_DIR}":/backup busybox \
  sh -c "cd /volume && tar xzf /backup/$(basename $BACKUP_FILE) --overwrite"

# Limpa arquivos temporários
rm -rf "${TMP_DIR}"

echo "[+] Restauração finalizada no volume: ${VOLUME_DESTINO}"
echo "[+] Para verificar o conteúdo, use: docker run --rm -v ${VOLUME_DESTINO}:/volume busybox ls -la /volume"
