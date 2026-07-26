from fastapi import APIRouter, Body
from pydantic import BaseModel
import httpx
import os
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/api", tags=["AI Chat"])

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

# Local fallback responses for common questions
FALLBACK_RESPONSES = {
    "simpan": """🍎 **Tips Menyimpan Makanan**

**Buah-buahan:**
• Apel, pisang, alpukat simpan di suhu ruang sampai matang
• Setelah matang, pindahkan ke kulkas
• Jangan simpan pisang dekat buah lain (menghasilkan etilen)

**Sayuran:**
• Cuci bersih sebelum disimpan (untuk sayuran berdaun)
• Bungkus dengan tisu dapur untuk menyerap kelembaban
• Simpan di laci kulkas dengan ventilasi

**Daging & Seafood:**
• Simpan di freezer jika tidak segera dimasak
• Thawing: pindahkan ke kulkas bawah, bukan di suhu ruang
• Gunakan dalam 1-2 hari setelah thawed""",

    "resep": """🍳 **Resep Cepat dengan Bahan Sederhana**

**Tumis Sayuran (10 menit)**
1. Panaskan minyak, tumis bawang putih
2. Masukkan sayuran (wortel, buncis, kol)
3. Tambahkan kecap asin, garam, merica
4. Aduk sampai setengah matang
5. Sajikan hangat

**Salad Segar**
1. Potong sayuran segar
2. Tambahkan tomat, mentimun
3. Dressing: minyak zaitun + lemon + garam""",

    "food waste": """♻️ **Tips Mengurangi Food Waste**

1. **Buy Smart**: Buat daftar belanja,不要 beli berlebihan
2. **First In, First Out**: Gunakan bahan lama duluan
3. **Proper Storage**: Simpan dengan benar sesuai jenis makanan
4. **Freeze Before Expired**: Bekukan sebelum kadaluarsa
5. **Creative Cooking**: Gunakan sisa untuk masakan baru
6. **Komposting**: Buang Limbah organik ke komposer""",

    "nutrisi": """📊 **Info Nutrisi Umum**

**Buah Segar (per 100g):**
• Apel: ~52 kkal, kaya serat & vitamin C
• Pisang: ~89 kkal, tinggi kalium
• Jeruk: ~47 kkal, kaya vitamin C

**Sayuran (per 100g):**
• Brokoli: ~34 kkal, kaya vitamin K
• Bayam: ~23 kkal, tinggi zat besi
• Wortel: ~41 kkal, kaya vitamin A

Klik menu 'Scan' untuk info nutrisi spesifik makanan Anda!""",

    "kadaluarsa": """📅 **Estimasi Shelf Life Makanan**

**Segar:**
• Daging sapi: 2-3 hari di kulkas, 4-12 bulan di freezer
• Ayam: 1-2 hari di kulkas, 9-12 bulan di freezer
• Ikan: 1-2 hari di kulkas
• Telur: 3-5 minggu dari tanggal pembelian
• Susu: 7 hari setelah dibuka

**Buah:**
• Pisang: 2-7 hari
• Apel: 3-6 minggu
• Jeruk: 1-2 minggu

Gunakan fitur **Scan** NoFTe untuk deteksi kesegaran otomatis!""",
}

def get_fallback_response(message: str) -> str:
    """Get a local fallback response based on keywords"""
    msg_lower = message.lower()

    for keyword, response in FALLBACK_RESPONSES.items():
        if keyword in msg_lower:
            return response

    # Default response
    return """👋 Halo! Saya AI Assistant NoFTe!

Saya siap membantu Anda dengan pertanyaan tentang:

🍎 **Tips menyimpan makanan** dengan benar
🍳 **Resep memasak** bahan makanan segar
♻️ **Cara mengurangi food waste**
📊 **Info nutrisi** makanan
📅 **Kadaluarsa dan shelf life**

Ketik pertanyaan spesifik saya, misalnya:
• "cara menyimpan apel?"
• "resep sayuran cepat"
• "tips kurangi food waste"

Atau gunakan fitur **Scan** untuk mendeteksi kesegaran makanan secara otomatis! 🔍"""

class ChatRequest(BaseModel):
    message: str

@router.post("/chat")
async def chat_with_ai(request: ChatRequest):
    """
    Chat endpoint using Gemini AI with local fallback
    """
    message = request.message

    if not message or not message.strip():
        return {"reply": "Pesan kosong. Silakan ketik pertanyaan Anda."}

    # If no API key, use local responses
    if not GEMINI_API_KEY:
        return {"reply": get_fallback_response(message)}

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}",
                json={
                    "contents": [{
                        "parts": [{
                            "text": f"""Kamu adalah AI Assistant untuk aplikasi NoFTe (No Food Waste) - aplikasi untuk mendeteksi kesegaran makanan dan mengelola inventory dapur.

Jawab pertanyaan berikut dengan helpful, ramah, dan dalam Bahasa Indonesia. Berikan tips praktis tentang:
- Menyimpan makanan dengan benar
- Resep memasak bahan makanan
- Cara mengurangi food waste
- Info nutrisi makanan
- Kadaluarsa dan shelf life makanan

Pertanyaan: {message}"""
                        }]
                    }]
                },
                headers={"Content-Type": "application/json"}
            )

            data = response.json()

            if response.status_code == 200 and data.get("candidates"):
                reply = data["candidates"][0]["content"]["parts"][0]["text"]
                return {"reply": reply}
            else:
                # API error - use fallback
                error_msg = data.get("error", {}).get("message", "") if "error" in data else str(data)
                print(f"Gemini API Error: {error_msg}")
                if "quota" in error_msg.lower() or "429" in error_msg:
                    return {"reply": get_fallback_response(message)}
                return {
                    "reply": "Maaf, terjadi kesalahan saat memproses pesan Anda. Saya akan coba bantu dengan informasi umum.\n\n" + get_fallback_response(message)
                }

    except httpx.TimeoutException:
        return {"reply": get_fallback_response(message)}
    except Exception as e:
        print(f"Chat Error: {e}")
        return {"reply": get_fallback_response(message)}
