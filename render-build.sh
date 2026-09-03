#!/usr/bin/env bash

set -e

pip install -r requirements.txt

apt-get update
apt-get install -y nodejs npm git

rm -rf /tmp/bgutil

git clone --depth 1 --branch 1.3.1 \
https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
/tmp/bgutil

cd /tmp/bgutil/server

npm install
npx tsc
