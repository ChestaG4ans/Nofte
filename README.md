# 🍎 NoFTe - Deteksi & Pantau Kesegaran Makanan

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.9+-blue.svg" alt="Python">
  <img src="https://img.shields.io/badge/FastAPI-0.100+-green.svg" alt="FastAPI">
  <img src="https://img.shields.io/badge/Flutter-3.12+-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/TensorFlow-2.x-orange.svg" alt="TensorFlow">
  <img src="https://img.shields.io/badge/YOLOv8-Latest-red.svg" alt="YOLOv8">
</p>

> **NoFTe** adalah aplikasi berbasis AI untuk mendeteksi jenis makanan dan memantau kesegaran serta daya simpan食材. Menggunakan CNN untuk klasifikasi dan YOLO untuk deteksi objek.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 📷 **Scan Makanan** | Ambil foto makanan menggunakan kamera atau galeri |
| 🧠 **Deteksi AI** | Identifikasi jenis makanan menggunakan CNN & YOLO |
| 📊 **Analisis Kesegaran** | Cek kesegaran makanan secara otomatis |
| 📦 **Inventory** | Simpan hasil scan dan pantau kadaluarsa |
| 💬 **AI Assistant** | Chat bantuan untuk tips penyimpanan makanan |
| 📜 **Riwayat** | Lihat semua hasil scan sebelumnya |

---

## 🛠️ Tech Stack

### Backend
- **FastAPI** - REST API framework
- **TensorFlow/Keras** - CNN model untuk klasifikasi
- **YOLOv8** - Object detection
- **SQLite** - Database
- **Uvicorn** - ASGI server

### Mobile App
- **Flutter 3.12+** - Cross-platform mobile development
- **Dart** - Programming language
- **http** - API client

### Machine Learning
- **TensorFlow** - Deep learning framework
- **YOLOv8 (Ultralytics)** - Object detection
- **NumPy/Pandas** - Data processing

---

## 📁 Struktur Project

```
Nofte/
├── app/                    # Backend FastAPI application
│   ├── api/               # API endpoints
│   ├── core/              # Core configurations
│   ├── database/          # Database setup
│   ├── models/            # Pydantic models
│   ├── repositories/      # Data access layer
│   ├── schemas/           # Request/Response schemas
│   └── services/          # Business logic
├── main.py                # FastAPI entry point
├── requirements.txt       # Python dependencies
├── nofte_flutter/         # Flutter mobile app
│   ├── lib/
│   │   ├── config/        # API configuration
│   │   ├── models/       # Data models
│   │   ├── screens/      # UI screens
│   │   └── services/     # API services
│   └── pubspec.yaml      # Flutter dependencies
├── models/                # Trained ML models
│   ├── cnn_food_classifier.tflite
│   ├── cnn_food_classifier.keras
│   └── class_names.json
├── scripts/               # Helper scripts
└── README.md
```

---

## 🚀 Cara Menjalankan

### 1. Backend (FastAPI)

```bash
# Install dependencies
pip install -r requirements.txt

# Jalankan backend
start_backend.bat
# Atau manual:
python main.py

# Server aktif di: http://127.0.0.1:8000
```

### 2. Flutter Mobile App

```bash
# Masuk ke folder Flutter
cd nofte_flutter

# Install dependencies
flutter pub get

# Jalankan app
flutter run
```

### 3. Build APK

```bash
cd nofte_flutter
flutter build apk --debug
```

---

## 📸 Screenshots

| Login | Scan | Inventory |
|:-----:|:----:|:---------:|
| ![Login](https://via.placeholder.com/300x600?text=Login+Screen) | ![Scan](https://via.placeholder.com/300x600?text=Scan+Screen) | ![Inventory](https://via.placeholder.com/300x600?text=Inventory) |

---

## 🤖 Machine Learning Models

### CNN Food Classifier
- **Input**: Gambar makanan (224x224 RGB)
- **Output**: Jenis makanan + confidence score
- **Format**: Keras (.keras) & TFLite (.tflite)

### YOLOv8 Object Detection
- **Input**: Gambar makanan (640x640)
- **Output**: Bounding box + class + confidence
- **Format**: PyTorch (.pt)

### Supported Food Classes
Mangga, Apel, Jeruk, Pisang, Stroberi, Tomat, Wortel, Brokoli, Daging Sapi, Ikan, dan lainnya...

---

## 🔒 Environment Variables

Buat file `.env` berdasarkan `.env.example`:

```env
DATABASE_URL=sqlite:///./nofte.db
API_HOST=0.0.0.0
API_PORT=8000
MODEL_PATH=./models
```

---

## 📝 Lisensi

Project ini dibuat untuk tugas **SARMAG** (Sistem Multimedia dan Aparat).

---

## 👨‍💻 Author

**Chesta Adabi Karnen**

- GitHub: [@ChestaG4ans](https://github.com/ChestaG4ans)

---

<p align="center">
  <sub>Made with ❤️ for detecting food freshness</sub>
</p>
