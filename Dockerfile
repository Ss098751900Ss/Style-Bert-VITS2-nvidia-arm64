FROM nvcr.io/nvidia/pytorch:25.10-py3

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs curl ca-certificates \
    build-essential cmake pkg-config \
    ffmpeg \
    libsndfile1 libsndfile1-dev \
    libopenblas-dev libgomp1 \
    libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev \
    libavfilter-dev libswscale-dev libswresample-dev \
    espeak-ng \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/litagin02/Style-Bert-VITS2.git /app/Style-Bert-VITS2

RUN mkdir -p /app/defaults/bert \
    && cp /app/Style-Bert-VITS2/bert/bert_models.json /app/defaults/bert/bert_models.json

#RUN  cp /app/Style-Bert-VITS2/config.yml /app/defaults/config.yml

WORKDIR /app/Style-Bert-VITS2

RUN python -m pip install "setuptools<81" wheel

RUN grep -v -E "^(torch|torchaudio|torchvision|onnxruntime|onnxruntime-gpu|onnxruntime-directml|faster-whisper|stable-ts|pyannote\.audio)([[:space:];=<>!~].*)?$" requirements.txt > /tmp/requirements-dgx.txt \
    && echo "===== filtered requirements check =====" \
    && grep -n -E "torch|onnxruntime|faster-whisper|stable-ts|pyannote|av" /tmp/requirements-dgx.txt || true \
    && python -m pip install -r /tmp/requirements-dgx.txt \
    && python -m pip install onnxruntime \
    && python -m pip install "setuptools<81"

RUN cd /app/Style-Bert-VITS2 \
    && python - <<'PY'
from pathlib import Path

for file in [
    Path("style_bert_vits2/models/models_jp_extra.py"),
    Path("style_bert_vits2/models/models.py"),
]:
    if not file.exists():
        continue

    text = file.read_text()
    old = "self.bert_proj(bert).transpose(1, 2)"
    new = "self.bert_proj(bert.to(self.bert_proj.weight.dtype)).transpose(1, 2)"

    if old in text:
        file.write_text(text.replace(old, new))
        print(f"patched: {file}")
    else:
        print(f"no target or already patched: {file}")
PY

EXPOSE 5000

#ここに書かれているスクリプトで退避した必要なファイルを再度必要なディレクトリへ戻している。
#エントリーポイントはボリュームがマウントされたあとに実行される。
#なので、
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python", "server_fastapi.py"]

