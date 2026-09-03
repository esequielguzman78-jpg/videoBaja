from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from pathlib import Path
import yt_dlp
import uuid
import re

app = FastAPI(title="videoBaja API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

DOWNLOAD_DIR = Path("/tmp/videobaja")
DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)


class DownloadRequest(BaseModel):
    url: str
    platform: str


def allowed_url(url: str, platform: str) -> bool:
    domains = {
        "youtube": [
            "youtube.com",
            "youtu.be",
            "www.youtube.com",
        ],
        "facebook": [
            "facebook.com",
            "www.facebook.com",
            "fb.watch",
        ],
        "tiktok": [
            "tiktok.com",
            "www.tiktok.com",
        ],
        "instagram": [
            "instagram.com",
            "www.instagram.com",
        ],
    }

    platform = platform.lower()

    if platform not in domains:
        return False

    return any(
        domain in url.lower()
        for domain in domains[platform]
    )


@app.get("/")
def home():
    return {
        "service": "videoBaja API",
        "status": "online"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }


@app.post("/api/download")
def download_video(request: DownloadRequest):

    url = request.url.strip()

    if not re.match(r"^https?://", url):
        raise HTTPException(
            status_code=400,
            detail="URL no válida"
        )

    if not allowed_url(url, request.platform):
        raise HTTPException(
            status_code=400,
            detail="La URL no corresponde a la plataforma seleccionada"
        )

    job_id = str(uuid.uuid4())

    output_template = str(
        DOWNLOAD_DIR / f"{job_id}.%(ext)s"
    )

    options = {
        "outtmpl": output_template,
        "format": "best[ext=mp4]/best",
        "noplaylist": True,
        "quiet": True,
        "no_warnings": True,

        "extractor_args": {
    "youtube": {
        "player_client": [
            "mweb"
        ]
    },
    "youtubepot-bgutilhttp": {
        "base_url": [
            "http://127.0.0.1:4416"
        ]
    }
},
    }

    try:

        with yt_dlp.YoutubeDL(options) as ydl:

            info = ydl.extract_info(
                url,
                download=True
            )

            filename = ydl.prepare_filename(info)

        file_path = Path(filename)

        if not file_path.exists():

            files = list(
                DOWNLOAD_DIR.glob(
                    f"{job_id}.*"
                )
            )

            if not files:
                raise Exception(
                    "No se encontró el archivo descargado"
                )

            file_path = files[0]

        return {
            "success": True,

            "title": info.get(
                "title",
                "Video preparado"
            ),

            "thumbnail": info.get(
                "thumbnail",
                ""
            ),

            "download_url": (
                "https://videobaja-downloader.onrender.com"
                f"/api/file/{file_path.name}"
            )
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=(
                "No se pudo procesar el video: "
                f"{str(e)}"
            )
        )


@app.get("/api/file/{filename}")
def get_file(filename: str):

    file_path = DOWNLOAD_DIR / filename

    if not file_path.exists():

        raise HTTPException(
            status_code=404,
            detail="Archivo no encontrado"
        )

    return FileResponse(
        path=file_path,
        filename=file_path.name,
        media_type="application/octet-stream"
    )
