#!/usr/bin/env bash
# 批次壓縮工作坊照片：assets/raw/<D1..D6>/*.jpg → assets/photos/dN-XX.jpg
# ponytail: 固定 1400px 寬 / q6，實測單張 4MB → ~160KB。要更小改 -q:v 或寬度即可。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/raw"
OUT="$ROOT/assets/photos"
WIDTH=1400
QUALITY=6
# 每天最多取幾張（906 張全壓沒必要，網站用不到那麼多）
MAX_PER_DAY="${MAX_PER_DAY:-16}"

[ -d "$SRC" ] || { echo "找不到 $SRC —— 請先把 Drive 的 photo/ 解壓到這裡"; exit 1; }
mkdir -p "$OUT"

total=0
skipped=0
for day in D1 D2 D3 D4 D5 D6; do
  dir="$SRC/$day"
  [ -d "$dir" ] || { echo "略過 $day（不存在）"; continue; }
  n=0
  # 依檔名排序，取用時順序穩定
  while IFS= read -r f; do
    [ "$n" -ge "$MAX_PER_DAY" ] && break
    n=$((n+1))
    out="$OUT/$(echo "$day" | tr 'A-Z' 'a-z')-$(printf '%02d' "$n").jpg"
    # 已存在就跳過：d3-01/02/04、d6-02/03/04 等是人工指定來源的照片，
    # 依序號重生會把它們覆蓋掉。要重新產生請先手動刪除該檔（或設 FORCE=1）。
    if [ -f "$out" ] && [ "${FORCE:-0}" != "1" ]; then
      skipped=$((skipped+1)); continue
    fi
    ffmpeg -v error -i "$f" -vf "scale=${WIDTH}:-2" -q:v "$QUALITY" "$out" -y
    total=$((total+1))
  done < <(find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort)
  echo "$day → $n 張"
done

echo "---"
echo "共 $total 張，輸出在 assets/photos/"
[ "$skipped" -gt 0 ] && echo "跳過 $skipped 張既有檔案（保護人工挑選的照片；FORCE=1 可強制覆寫）"
du -sh "$OUT" | awk '{print "總大小: "$1}'
find "$OUT" -name '*.jpg' -size +300k | while read -r big; do
  echo "⚠ 超過 300KB: $(basename "$big") ($(du -h "$big" | cut -f1))"
done
