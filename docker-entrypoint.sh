#!/usr/bin/env bash
set -e

#mkdir -p /app/Style-Bert-VITS2/bert /app/Style-Bert-VITS2/model_assets

if [ ! -f /app/Style-Bert-VITS2/bert/bert_models.json ] && [ -f /app/defaults/bert/bert_models.json ]; then
  cp /app/defaults/bert/bert_models.json /app/Style-Bert-VITS2/bert/bert_models.json
fi

if [ ! -f /app/Style-Bert-VITS2/config.yml ] && [ -f /app/defaults/config.yml ]; then
  cp /app/defaults/config.yml /app/Style-Bert-VITS2/config.yml
fi

#ホストのボリュームをマウント後だと中身が空になるのでここでコピーしている。
if [ -f /app/Style-Bert-VITS2/default-config.yml]; then
  cp /app/Style-Bert-VITS2/default-config.yml /app/Style-Bert-VITS2/config.yml
fi

exec "$@"
