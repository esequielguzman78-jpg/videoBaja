#!/usr/bin/env bash

set -e

echo "=== Instalando dependencias Python ==="
pip install -r requirements.txt

echo "=== Instalando Node.js y Git ==="
apt-get update
apt-get install -y nodejs npm git

echo "=== Descargando bgutil ==="
rm -rf /tmp/bgutil

git clone --depth 1 \
https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
/tmp/bgutil

echo "=== Contenido del proveedor ==="
ls -la /tmp/bgutil
ls -la /tmp/bgutil/server

echo "=== Instalando dependencias del servidor ==="
cd /tmp/bgutil/server
npm install

echo "=== Compilando servidor ==="
npm run build

echo "=== Buscando archivos compilados ==="
find /tmp/bgutil/server -maxdepth 3 -type f | sort

echo "=== BUILD COMPLETADO ==="
