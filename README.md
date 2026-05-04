
## サーバーが起動した際のテストケース

```bash
curl -G "http://localhost:5000/voice" \
  --data-urlencode "text=こんにちは。これはテスト音声です。" \
  --data-urlencode "language=JP" \
  --data-urlencode "model_id=0" \
  --data-urlencode "speaker_id=0" \
  --data-urlencode "style=Neutral" \
  -o test.wav
```

## 起動する際の手順
```bash
git clone https://hoge.com
#mkdir ./style-bert-vits2
cd style-bert-vits2
mkdir model_assets bert

sudo docker compose run --rm style-bert-vits2 python initialize.py --only_infer

sudo docker compose up -d

sudo docker compose logs -f style-bert-vits2
```
