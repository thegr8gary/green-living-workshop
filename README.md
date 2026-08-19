# green-living-workshop

「超高齡社會下的綠色生活」國際工作坊（2026/8/1–8/7）的成果介紹網站。

**線上版本**：https://thegr8gary.github.io/green-living-workshop/

老師於 2026-08-18 交辦，起因是 K-Bus（音譯）希望把工作坊成果與過程放上網路，讓各參與國的老師能帶回自己的學校介紹與交流。

## 現況

已完成並上線。內容包含：

| 區塊 | 內容 |
|---|---|
| 課程流程 | D1–D6，每日 4 張照片 + 課程名 + 講者（取自官方英文課表） |
| 工作坊現場 | 60 張照片三欄瀑布 |
| 各組成果 | 7 組，可展開影片（2–3 分鐘）+ 簡報翻頁器（共 237 頁） |
| 國際論壇 | 8/7 完整議程 10 項 + 講者照片 + 合照 |

## 技術

單一 `index.html`（約 80KB），CSS/JS 全部內嵌。**無建置流程、無 npm、無 CDN 依賴**（僅 Google Fonts）。
託管在 GitHub Pages，改檔 `git push` 後約 60 秒自動上線。

## 檔案

| 路徑 | 內容 |
|---|---|
| `index.html` | 網站本體 |
| `design-tokens.md` | 視覺規則的單一真實來源。**改樣式前先讀這份** |
| `SPEC.md` | 內容與形式規格書，含老師口頭指示的出處時間戳 |
| `scripts/optimize-photos.sh` | 照片批次壓縮 |
| `scripts/build-media.sh` | 影片壓縮 + 簡報 PDF 轉圖 |
| `assets/photos/` | 96 張壓縮後照片（每日 16 張） |
| `assets/slides/gN/` | 各組簡報逐頁 JPEG |
| `assets/video/` | 7 支壓縮後影片 + poster |
| `assets/forum/` | 論壇講者與合照 |

## ⚠️ 原始素材沒有進版控

`assets/raw/`（4.8GB）、`assets/videos/`（932MB）、`assets/pdf/`（264MB）合計約 **6GB**，
在 `.gitignore` 中排除，**只存在本機**。

**這些檔案遺失就無法重新產生網站素材** —— Drive 上雖有備份，但那是他人帳號、非本人擁有。
**請另外備份到外接硬碟或自己的雲端。**

## 重建素材的方式

```bash
# 照片：assets/raw/D1..D7/ → assets/photos/
MAX_PER_DAY=16 ./scripts/optimize-photos.sh

# 影片與簡報：assets/videos/ 與 ~/Downloads/Group N.pdf → assets/video/, assets/slides/
./scripts/build-media.sh
```

兩支腳本都會跳過已存在的輸出，可重複執行。需要 `ffmpeg` 與 `pdftoppm`（`brew install ffmpeg poppler`）。

## 部署

```bash
git add -A && git commit -m "..." && git push
```

GitHub Pages 自動建置。查狀態：`gh api repos/thegr8gary/green-living-workshop/pages --jq '.status'`

## 已知落差

- **MVCB 分群資料**未取得（各組成果目前顯示基地代碼與指導老師）
- 論壇 12 支講者錄影（每支約 1GB）未放上網站，僅用照片呈現
- 網站設 `noindex`：可用連結瀏覽，但不被搜尋引擎收錄

## 相關

- 需求來源：vault `30-筆記/會議紀錄/2026-08-18_碩論方向與工作坊檢討會議.md`
- 視覺參考：`~/Desktop/Claude Code/分組報告連結啟動頁/index.html`

> 專案即時狀態不寫在這裡 —— 唯一來源是 vault 的 `20-資料夾概述/索引/專案總覽.md`。
