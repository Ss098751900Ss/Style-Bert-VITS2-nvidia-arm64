
## サーバーが起動した際のテストケース

```bash
curl -G "http://localhost:5000/voice" \
  --data-urlencode "text=こんにちは。これはテスト音声です。" \
  --data-urlencode "language=JP" \
  --data-urlencode "model_id=0" \
  --data-urlencode "speaker_id=0" \
  --data-urlencode "style=Neutral" \
  -o 0504test.wav
```

## 起動する際の手順
```bash
git clone https://github.com/Ss098751900Ss/style-bert-vits2-nvidia-arm64.git

cd style-bert-vits2

sudo docker compose build

mkdir model_assets bert

touch config.yml

sudo docker compose run --rm style-bert-vits2 python initialize.py --only_infer

sudo docker compose up -d

sudo docker compose logs -f style-bert-vits2
```
