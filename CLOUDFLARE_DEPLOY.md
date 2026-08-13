# NOFTe - Cloudflare Deployment Guide

## Prerequisites
1. Node.js installed
2. Cloudflare account (free at cloudflare.com)
3. Wrangler CLI: `npm install -g wrangler`

---

## Deploy Backend (Cloudflare Worker)

### 1. Install Dependencies
```bash
cd mobile-prototype
npm install
```

### 2. Login to Cloudflare
```bash
wrangler login
```

### 3. Set API Key Secret
```bash
wrangler secret put GROQ_API_KEY
# Paste your Groq API key (get from console.groq.com)
```

### 4. Deploy Worker
```bash
cd cloudflare
wrangler deploy
```

### 5. Get Worker URL
```bash
wrangler info
# Or check dashboard at dash.cloudflare.com
```

Your API will be at: `https://nofte-api.<your-subdomain>.workers.dev/api/chat`

---

## Deploy Frontend (Cloudflare Pages)

### 1. Push to GitHub
```bash
cd ..
git init nofte-web
cd nofte-web
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/nofte-web.git
git push -u origin main
```

### 2. Connect to Cloudflare Pages
1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Workers & Pages → Create Application → Pages
3. Connect to GitHub → Select `nofte-web`
4. Build settings: (leave empty for static)
5. Environment variables:
   - `CHAT_API_URL` = `https://nofte-api.<your-subdomain>.workers.dev/api/chat`
6. Deploy!

---

## Update Frontend for Production

After deploying Worker, update `chat.js`:

```javascript
// Replace this:
const CHAT_API_URL = "/api/chat";

// With your Worker URL:
const CHAT_API_URL = "https://nofte-api.xxx.workers.dev/api/chat";
```

Or use environment variables in Cloudflare Pages.

---

## Free Tier Limits

### Cloudflare Workers (Backend)
- 100,000 requests/day
- 10ms CPU time per request
- 512 MB memory

### Cloudflare Pages (Frontend)
- Unlimited requests
- 500 builds/month
- 100 GB bandwidth/month

---

## Summary

| Component | Service | Cost |
|-----------|---------|------|
| Frontend | Cloudflare Pages | FREE |
| Backend API | Cloudflare Worker | FREE |
| AI (Groq) | llama-3.1-8b-instant | FREE (60 req/min) |
