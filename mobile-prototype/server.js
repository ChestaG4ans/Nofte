require("dotenv").config();

const express = require("express");
const cors = require("cors");
const path = require("path");
const OpenAI = require("openai");

const app = express();

app.use(cors());
app.use(express.json());

// Serve static files from current directory
app.use(express.static(__dirname));

// Initialize OpenAI
const API_KEY = process.env.OPENAI_API_KEY;
if (!API_KEY) {
    console.error("OPENAI_API_KEY not found in .env file!");
    process.exit(1);
}

const client = new OpenAI({
    apiKey: API_KEY,
});

// AI Chat endpoint
app.post("/api/chat", async (req, res) => {
    try {
        const message = req.body.message;

        if (!message) {
            return res.status(400).json({ error: "Pesan kosong" });
        }

        // Create prompt with system instructions
        const prompt = `Kamu adalah asisten dapur pintar bernama NOFTe. Kamu membantu pengguna mengelola bahan makanan, memberikan saran resep, dan tips memasak. Selalu jawab dalam Bahasa Indonesia yang sopan dan ramah.

Pertanyaan pengguna: ${message}`;

        // Generate response using OpenAI API
        const response = await client.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                {
                    role: "system",
                    content: "Kamu adalah asisten dapur pintar bernama NOFTe. Kamu membantu pengguna mengelola bahan makanan, memberikan saran resep, dan tips memasak. Selalu jawab dalam Bahasa Indonesia yang sopan dan ramah."
                },
                {
                    role: "user",
                    content: message
                }
            ],
            max_tokens: 500,
            temperature: 0.7,
        });

        const reply = response.choices[0].message.content;

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
    console.log("🍳 NOFTe AI Server Berjalan");
    console.log("=".repeat(40));
    console.log(`🌐 URL: http://localhost:${PORT}`);
    console.log(`📝 API Key: ✓ Terkonfigurasi`);
    console.log(`🤖 Model: gpt-4o-mini`);
    console.log("=".repeat(40));
});
