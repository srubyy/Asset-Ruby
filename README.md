# Digital Asset Protection (DAP)

A real-time sports media piracy monitoring and takedown platform built with Flutter Web.

## 🚀 Features

- **Real-Time Threat Dashboard** — Live feed of piracy threats with match confidence scoring
- **Asset Ingestion Hub** — Upload media and generate AI fingerprints via Vertex AI
- **Scout Engine** — Simulates scanning platforms (Twitter, Telegram, Reddit, Discord, IPTV)
- **One-Click Takedown Generator** — Auto-generates DMCA notices with reference IDs
- **Live Geo-Propagation Map** — World map showing piracy spread in real-time
- **Piracy DNA Analyzer** — Powered by Gemini 1.5 Flash — detects HOW content was mutated

## 🛠 Tech Stack

- **Frontend**: Flutter Web
- **Backend**: Firebase Cloud Functions (Node.js)
- **AI**: Vertex AI (`multimodalembedding@001`), Gemini 1.5 Flash, Cloud Vision API
- **Database**: Firestore, Vertex AI Vector Search
- **Storage**: Firebase Storage
- **Map**: flutter_map + CartoDB Dark tiles

## ▶️ Running Locally

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open http://localhost:8080

## 🔑 Gemini API Key (for DNA Analyzer)

Get a free key at https://aistudio.google.com/app/apikey and set it in:
`lib/services/gemini_service.dart` → `_apiKey`
