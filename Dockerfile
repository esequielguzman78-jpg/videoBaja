FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN git clone --depth 1 \
    https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git \
    /app/bgutil

RUN cd /app/bgutil/server && \
    npm ci && \
    npx tsc

COPY . .

CMD ["sh", "-c", "node /app/bgutil/server/build/main.js & sleep 3; exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
