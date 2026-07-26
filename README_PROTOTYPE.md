# NoFTe Prototype Roadmap

NoFTe akan dibuat sebagai prototipe mobile dengan backend AI.

## Prasyarat

1. **PostgreSQL** - Buat database `nofte`:
   ```sql
   CREATE DATABASE nofte;
   ```

2. **Environment Variables** (opsional, copy dari .env.example):
   - `DATABASE_URL=postgresql://postgres:postgres@localhost:5432/nofte`
   - `JWT_SECRET_KEY=your-secret-key`

3. **Install dependencies**:
   ```powershell
   pip install -r requirements.txt
   ```

## Tahap 1 - CNN

Latih model klasifikasi makanan dari folder `dataset_selected`.

```powershell
venv\Scripts\python.exe scripts\train_cnn.py --epochs 8
```

Output:

- `models/cnn_food_classifier.keras`
- `models/cnn_food_classifier.tflite`
- `models/class_names.json`

## Tahap 2 - Backend

Jalankan API:

```powershell
venv\Scripts\python.exe -m uvicorn main:app --reload
```

Atau gunakan script yang sudah disediakan:

```text
start_backend.bat
```

### API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/` | Health check | No |
| POST | `/auth/register` | Register user | No |
| POST | `/auth/login` | Login | No |
| GET | `/auth/me` | Get current user | Yes |
| POST | `/scan` | Scan food image | Yes |
| GET | `/history` | Get scan history | Yes |
| GET | `/inventory` | Get inventory | Yes |
| POST | `/inventory` | Add inventory item | Yes |

### Scan Endpoint

`POST /scan` menerima foto sebagai raw binary body dengan header:
- `Content-Type`: image/* (image/jpeg, image/png, dll)
- `Authorization`: Bearer {token}

## Tahap 3 - YOLO

YOLO membutuhkan label bounding box. Dataset saat ini belum memiliki file label YOLO, jadi perlu anotasi dulu dengan format:

```text
class x_center y_center width height
```

Setelah anotasi selesai, model YOLO bisa dilatih dan hasil deteksinya dipakai untuk crop gambar sebelum masuk ke CNN.

Untuk prototipe cepat, buat label YOLO otomatis dari dataset satu objek:

```powershell
venv\Scripts\python.exe scripts\prepare_yolo_dataset.py
```

Lalu latih YOLO:

```powershell
venv\Scripts\python.exe -m pip install ultralytics
venv\Scripts\python.exe scripts\train_yolo.py --epochs 3 --imgsz 320 --batch 8
```

Catatan: label otomatis ini cukup untuk demo alur YOLO, tetapi untuk akurasi nyata tetap perlu anotasi manual di foto yang mirip kondisi kamera pengguna.

Model YOLO prototipe tersimpan di:

```text
runs/yolo/nofte_detect/weights/best.pt
```

## Tahap 4 - Mobile

Mobile prototype akan berisi:

- kamera/upload foto
- tombol scan
- hasil nama makanan
- freshness
- estimasi daya simpan
- informasi nutrisi

Versi Flutter ada di:

```text
nofte_flutter/
```

Jalankan dengan:

```text
nofte_flutter/run_flutter.bat
```

Prototype mobile bisa dibuka dari:

```text
mobile-prototype/index.html
```

Default backend yang dipakai:

```text
http://127.0.0.1:8000/scan
```

Jika dicoba dari HP fisik, ganti alamat backend di tombol pengaturan menjadi IP laptop, misalnya:

```text
http://192.168.1.10:8000/scan
```
