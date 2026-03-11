# Estate of Betrayal — Setup Guide

Complete setup in four steps. Takes ~20 minutes.

---

## Step 1 — Export Slides from PowerPoint

Run the included PowerShell script to export all 10 slides as JPG images:

```powershell
cd C:\Users\lando\Desktop\estate-of-betrayal
.\extract-slides.ps1
```

This creates `slides/slide-01.jpg` through `slides/slide-10.jpg` at 1920×1080.

> **Requires:** Microsoft PowerPoint installed on this machine (not 365 web).

---

## Step 2 — Set Up Cloudflare R2

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **R2 Object Storage**
2. Click **Create bucket** → name it `estate-of-betrayal` → Create
3. In the bucket, click **Settings** → **Public access** → Enable public access
4. Note your **Public bucket URL** — it looks like:
   `https://pub-XXXXXXXXXXXX.r2.dev`

### Upload your files

Upload everything into these paths in R2:

```
slides/slide-01.jpg
slides/slide-02.jpg
...
slides/slide-10.jpg
audio/ep01-the-baseline.mp3
audio/ep02-the-pivot.mp3
audio/ep03-acceleration.mp3
audio/ep04-stealing-a-home.mp3
audio/ep05-the-endgame.mp3
audio/ep06-the-pattern.mp3
audio/ep07-the-dual-channel.mp3
audio/ep08-the-blueprint.mp3
```

You can drag-and-drop files directly in the R2 dashboard, or use the R2 CLI.

> **Tip:** Audio files can be added later. The site works with slides only first.

---

## Step 3 — Update the R2 URL in index.html

Open `index.html` and find this line near the top of the `<script>` block:

```js
const R2_BASE = 'https://YOUR_R2_BUCKET.r2.dev';
```

Replace `YOUR_R2_BUCKET` with your actual R2 public URL, e.g.:

```js
const R2_BASE = 'https://pub-abc123def456.r2.dev';
```

Save the file.

---

## Step 4 — Deploy to Vercel

### Option A — Vercel Dashboard (easiest)

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your GitHub account **4websec**
3. Create a new GitHub repo (e.g. `estate-of-betrayal`) and push the project files
4. Vercel auto-detects the static site and deploys instantly
5. In **Project Settings → Domains**, add `katherinecazort.org`
6. Follow Vercel's DNS instructions to point your domain

### Option B — Vercel CLI

```powershell
npm install -g vercel
cd C:\Users\lando\Desktop\estate-of-betrayal
vercel --prod
```

Follow the prompts. When asked for a domain, enter `katherinecazort.org`.

---

## File Structure

```
estate-of-betrayal/
├── index.html          ← The entire website (single file)
├── vercel.json         ← Vercel deployment config
├── extract-slides.ps1  ← PowerPoint → JPG export script
├── SETUP.md            ← This file
└── slides/             ← Exported slide images (gitignore large files if needed)
    ├── slide-01.jpg
    └── ...
```

---

## Updating Episode Audio

When new audio files are ready, upload them to R2 under `audio/` and update
the `EPISODES` array in `index.html` to set the correct filenames and durations.

Each episode entry looks like:
```js
{ n:'04', title:'Stealing a Home During a Heart Attack',
  dur:'41:18', desc:'...', file:'ep04-stealing-a-home.mp3' }
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Slides show "Loading Evidence..." forever | Check R2 URL in `index.html`, verify files are uploaded |
| Audio doesn't play | Verify R2 public access is enabled; check browser console |
| CORS error on audio | In R2 bucket settings, add CORS rule allowing `GET` from your domain |
| `extract-slides.ps1` fails | Ensure PowerPoint is installed; run PowerShell as Administrator |
| Site shows on Vercel URL but not custom domain | Check DNS propagation (can take up to 48h) |
