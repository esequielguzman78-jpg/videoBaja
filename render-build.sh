#!/usr/bin/env bash
set -e

echo "=== Instalando dependencias Python ==="
pip install -r requirements.txt

echo "=== Descargando bgutil ==="
rm -rf "$PWD/bgutil"

git clone --depth 1 \
https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
"$PWD/bgutil"

echo "=== Instalando dependencias de bgutil ==="
cd "$PWD/bgutil/server"

npm ci

echo "=== Compilando bgutil ==="
npx tsc

echo "=== Verificando compilación ==="
test -f build/main.js

echo "=== BUILD COMPLETADO ==="
ls -lh build/main.js
