# NoFTe Flutter

Prototype mobile Flutter untuk NoFTe.

## 1. Jalankan Backend

Dari folder utama `Nofte`, jalankan:

```bat
start_backend.bat
```

Backend akan aktif di:

```text
http://127.0.0.1:8000
```

## 2. Jalankan App Flutter

Dari folder `nofte_flutter`, jalankan:

```powershell
flutter pub get
flutter run
```

Atau klik:

```text
run_flutter.bat
```

Untuk membuat APK debug:

```text
build_apk.bat
```

Default API di aplikasi:

```text
http://10.0.2.2:8000/scan
```

Alamat `10.0.2.2` dipakai untuk Android emulator. Kalau memakai HP fisik, buka tombol pengaturan di aplikasi lalu ganti ke IP laptop, misalnya:

```text
http://192.168.1.10:8000/scan
```

## Fitur

- Ambil foto dari kamera.
- Pilih foto dari galeri.
- Kirim foto ke backend FastAPI.
- Tampilkan hasil CNN, YOLO, confidence, bounding box, freshness, estimasi daya simpan, dan nutrisi.
