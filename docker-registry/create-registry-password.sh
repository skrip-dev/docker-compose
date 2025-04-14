#!/bin/bash

# Defina o nome de usuário padrão se não for fornecido
USERNAME=${REGISTRY_USER:-docker}

# Gere uma senha aleatória de 16 caracteres
if [ -z "$REGISTRY_PASSWORD" ]; then
  # Gera uma senha aleatória com caracteres alfanuméricos e alguns símbolos
  PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#%*_+' < /dev/urandom | head -c 32)
else
  PASSWORD=$REGISTRY_PASSWORD
fi

# Crie o diretório se não existir
mkdir -p data/auth

# Execute o contêiner temporário para gerar o arquivo htpasswd
# Montando o volume para garantir que o arquivo seja salvo na pasta local
docker run --rm \
  -v $(pwd)/data/auth:/auth \
  httpd:2 \
  sh -c "htpasswd -Bbc /auth/registry.password $USERNAME $PASSWORD"

echo "================================================================="
echo "Arquivo de senha criado com sucesso em data/auth/registry.password"
echo "Usuário: $USERNAME"
echo "Senha: $PASSWORD"
echo "================================================================="
echo "IMPORTANTE: Guarde esta senha em um local seguro!"
echo "Você pode iniciar o registry agora com: docker compose up -d"
