require("dotenv").config();

const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());

// Serve static files from current directory
app.use(express.static(__dirname));

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY) {
    console.error("GEMINI_API_KEY not found in .env file!");
    process.exit(1);
}

// AI Chat endpoint
app.post("/api/chat", async (req, res) => {
    try {
        const message = req.body.message;

        if (!message) {
            return res.status(400).json({ error: "Pesan kosong" });
        }

        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${API_KEY}`,
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    contents: [{
                        parts: [{
                            text: `Kamu adalah asisten dapur pintar bernama NOFTe. Kamu membantu pengguna mengelola bahan makanan, memberikan saran resep, dan tips memasak. Selalu jawab dalam Bahasa Indonesia yang sopan dan ramah.\n\nPertanyaan pengguna: ${message}`
                        }]
                    }],
                    generationConfig: {
                        temperature: 0.7,
                        maxOutputTokens: 500
                    }
                })
            }
        );

        const data = await response.json();

        let reply = "Maaf, saya tidak dapat menjawab saat ini.";

        if (data.candidates && data.candidates.length > 0) {
            reply = data.candidates[0].content.parts[0].text;
        } else if (data.error) {
            console.error("Gemini API Error:", data.error);
            reply = `Error: ${data.error.message || "Terjadi kesalahan pada API"}`;
        }

        res.json({ reply });

    } catch (err) {
        console.error("Server Error:", err);
        res.status(500).json({ error: err.message || "Internal server error" });
    }
});

// Health check
app.get("/api/health", (req, res) => {
    res.json({ status: "ok", timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log("=".repeat(40));
    console.log("🍳 NOFTe Server Berjalan");
    console.log("=".repeat(40));
    console.log(`🌐 URL: http://localhost:${PORT}`);
    console.log(`📝 API Key: ${API_KEY ? "✓ Terkonfigurasi" : "✗ Tidak ditemukan"}`);
    console.log("=".repeat(40));
});
