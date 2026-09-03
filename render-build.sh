#!/usr/bin/env bash

set -e

echo "Instalando dependencias de Python..."
pip install -r requirements.txt

echo "Instalando Node.js..."
apt-get update
apt-get install -y nodejs npm

echo "Descargando proveedor PO Token..."
git clone --depth 1 --branch 1.3.1 \
https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
/tmp/bgutil-ytdlp-pot-provider

echo "Instalando proveedor..."
cd /tmp/bgutil-ytdlp-pot-provider/server
npm ci --omit=dev
npx tsc

echo "Proveedor PO Token preparado."
