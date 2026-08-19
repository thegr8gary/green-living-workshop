#!/usr/bin/env bash
# 影片壓縮 + 簡報 PDF 轉圖。原始素材在 assets/videos/ 與 ~/Downloads/，產出進 assets/
# ponytail: 固定 720p CRF28 / 96dpi q72，實測 23x 與 7x 縮減。要更清晰就降 CRF 或升 DPI。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# --- 影片：檔名對應組別 ---
declare -a VIDS=(
  "1|assets/videos/Group 1_Vedio.mp4"
  "2|assets/videos/Group 2.mp4"
  "3|assets/videos/G3 video.mp4"
  "4|assets/videos/Group 4.mp4"
  "5|assets/videos/G5 video.mp4"
  "6|assets/videos/group 6_Tainan Green Way.mp4"
  "7|assets/videos/Group 7.mp4"
)
mkdir -p assets/video
for item in "${VIDS[@]}"; do
  n="${item%%|*}"; src="${item#*|}"
  [ -f "$src" ] || { echo "跳過 g$n（找不到 $src）"; continue; }
  out="assets/video/g$n.mp4"
  [ -f "$out" ] && { echo "g$n 已存在，跳過"; continue; }
  ffmpeg -v error -i "$src" -vf "scale=1280:-2" -c:v libx264 -crf 28 -preset veryfast \
         -c:a aac -b:a 96k -movflags +faststart "$out" -y &
done
wait
echo "影片完成："; ls -la assets/video/*.mp4 | awk '{printf "  %s %.1f MB\n",$9,$5/1048576}'

# --- 簡報 PDF → JPEG ---
declare -a PDFS=(
  "1|$HOME/Downloads/Group 1.pdf"
  "2|$HOME/Downloads/Group 2.pdf"
  "3|$HOME/Downloads/GROUP 3.pdf"
  "4|$HOME/Downloads/Group 4.pdf"
  "5|$HOME/Downloads/Group 5.pdf"
  "6|$HOME/Downloads/group 6_Green Way.pdf"
  "7|$HOME/Downloads/Group 7.pdf"
)
for item in "${PDFS[@]}"; do
  n="${item%%|*}"; src="${item#*|}"
  [ -f "$src" ] || { echo "跳過簡報 g$n"; continue; }
  d="assets/slides/g$n"; mkdir -p "$d"
  [ -n "$(ls -A "$d" 2>/dev/null)" ] && { echo "簡報 g$n 已存在，跳過"; continue; }
  pdftoppm -jpeg -r 96 -jpegopt quality=72 "$src" "$d/p" &
done
wait
echo "簡報完成："
for d in assets/slides/g*/; do echo "  $(basename $d): $(ls "$d" | wc -l | tr -d ' ') 頁"; done
du -sh assets/video assets/slides

# --- 基地簡報 → 三張說明圖 ---
# 來源：盧紀邦老師 8/1 開幕基地簡報（臺南綠園道・城市參與行動）
SITE_PDF="$HOME/Downloads/20260801 NCKU_Green Living (briefly grouping).pdf"
if [ -f "$SITE_PDF" ]; then
  mkdir -p assets/site
  # p.5 區位圖、p.2 三時代疊圖、p.4 綠廊願景圖
  for pair in "5|s-map" "2|s-history" "4|s-vision"; do
    pg="${pair%%|*}"; name="${pair#*|}"
    [ -f "assets/site/$name.jpg" ] && { echo "基地圖 $name 已存在，跳過"; continue; }
    pdftoppm -jpeg -jpegopt quality=80 -r 110 -f "$pg" -l "$pg" "$SITE_PDF" "assets/site/tmp-$name"
    mv assets/site/tmp-$name-*.jpg "assets/site/$name.jpg"
  done
  echo "基地圖完成："; ls -la assets/site/*.jpg | awk '{printf "  %s %.0f KB\n",$9,$5/1024}'
else
  echo "跳過基地圖（找不到來源簡報）"
fi
