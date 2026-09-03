#!/usr/bin/env bash

set -e

echo "=== Instalando Python ==="
pip install -r requirements.txt

echo "=== Instalando Node.js ==="
apt-get update
apt-get install -y nodejs npm

echo "=== Descargando bgutil ==="
rm -rf /tmp/bgutil-ytdlp-pot-provider

git clone --depth 1 --branch 1.3.1 \
https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
/tmp/bgutil-ytdlp-pot-provider

echo "=== Instalando bgutil ==="
cd /tmp/bgutil-ytdlp-pot-provider/server

npm ci
npx tsc

echo "=== bgutil listo ==="
