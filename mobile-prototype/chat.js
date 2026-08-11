// Chat JavaScript - NOFTe AI Assistant
// Works with static hosting (Cloudflare Pages)

const chatBox = document.getElementById("chatBox");
const chatInput = document.getElementById("chatInput");
const sendBtn = document.getElementById("sendBtn");

// NOTE: Untuk production, gunakan Cloudflare Workers sebagai proxy
// karena Gemini API key tidak boleh exposed di client-side
// Untuk demo prototype, gunakan API key langsung

let isLoading = false;

if (sendBtn) {
    sendBtn.addEventListener("click", sendMessage);
}

if (chatInput) {
    chatInput.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            sendMessage();
        }
    });
}

// Load chat history
loadChatHistory();

async function sendMessage() {
    if (isLoading) return;

    const message = chatInput ? chatInput.value.trim() : "";
    if (!message) return;

    isLoading = true;
    if (sendBtn) sendBtn.disabled = true;

    addMessage(escapeHtml(message), "user");
    if (chatInput) chatInput.value = "";

    const loading = addMessage("🤔 Memikirkan jawaban...", "ai");

    try {
        // Call Gemini API
        const reply = await getAIResponse(message);

        if (loading.parentNode) loading.remove();
        addMessage(formatAIResponse(reply), "ai");

    } catch (err) {
        console.error("Chat Error:", err);
        if (loading.parentNode) loading.remove();
        addMessage("⚠️ Gagal terhubung ke server AI. Pastikan koneksi internet stabil.", "ai");
    }

    isLoading = false;
    if (sendBtn) sendBtn.disabled = false;
    saveChatHistory();
}

async function getAIResponse(message) {
    // Gemini API configuration
    // NOTE: Untuk production, API key seharusnya di backend/Cloudflare Worker
    const API_KEY = "AIzaSyDAQ.Ab8RN6ITgEZPCZyJ9tgtwDik8bKwRLHq2HXh5cNahrKJAoWmcw";
    const API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    const prompt = `Kamu adalah asisten dapur pintar bernama NOFTe. Kamu membantu pengguna mengelola bahan makanan, memberikan saran resep, dan tips memasak.

Aturan:
- Selalu jawab dalam Bahasa Indonesia yang sopan dan ramah
- Berikan jawaban yang informatif dan praktis
- Jika tidak tahu, katakan dengan jujur

Pertanyaan pengguna: ${message}`;

    try {
        const response = await fetch(`${API_URL}?key=${API_KEY}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                contents: [{
                    parts: [{
                        text: prompt
                    }]
                }],
                generationConfig: {
                    temperature: 0.7,
                    maxOutputTokens: 500,
                    topP: 0.8,
                    topK: 40
                }
            })
        });

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            console.error("API Error:", response.status, errorData);

            // Return demo response if API fails
            return getDemoResponse(message);
        }

        const data = await response.json();

        if (data.candidates && data.candidates.length > 0) {
            return data.candidates[0].content.parts[0].text;
        } else if (data.error) {
            console.error("Gemini Error:", data.error);
            return getDemoResponse(message);
        }

        return getDemoResponse(message);

    } catch (err) {
        console.error("Fetch Error:", err);
        return getDemoResponse(message);
    }
}

function getDemoResponse(message) {
    const msg = message.toLowerCase();

    if (msg.includes('resep') || msg.includes('masak')) {
        return "🍳 Berikut beberapa resep mudah untuk pemula:\n\n• **Tumis Buncis** - 15 menit, 2 orang\n• **Nasi Goreng Sederhana** - 20 menit, 1 orang\n• **Telur Dadar** - 10 menit, 1 orang\n\nMau tahu resep yang lebih spesifik? Kunci dulu bahannya ya!";
    }

    if (msg.includes('kadaluarsa') || msg.includes('expired')) {
        return "📅 Tips menyimpan makanan agar tidak cepat kadaluarsa:\n\n• **Simpan di kulkas** dengan suhu yang tepat (4°C atau kurang)\n• **Gunakan container kedap udara** untuk sayur dan buah\n• **Pisahkan daging dan ikan** dari bahan lain\n• **Catat tanggal beli** agar mudah diingat\n\nBahan apa yang ingin kamu simpan?";
    }

    if (msg.includes('ayam')) {
        return "🍗 Tips menyimpan ayam:\n\n• Simpan di freezer bisa tahan **9-12 bulan**\n• Di kulkas (bagian bawah) tahan **1-2 hari**\n• marinasi sebelum bekukan agar lebih tahan lama\n• Jangan cuci ayam sebelum disimpan!";
    }

    if (msg.includes('sayur') || msg.includes('sayuran')) {
        return "🥬 Tips menyimpan sayuran:\n\n• **Daun hijau** - bungkus dengan tisu, simpan di plastik berlubang\n• **Wortel & kentang** - simpan di tempat sejuk, gelap\n• **Tomat** - simpan di suhu ruangan, jangan di kulkas\n• **Brokoli** - bungkus dengan plastik perforasi";
    }

    return "👋 Halo! Saya NOFTe, asisten dapur kamu.\n\nSaya bisa bantu kamu:\n• 🍳 Memberikan ide resep\n• 📅 Tips menyimpan makanan\n• 📋 Membantu inventory kulkas\n\nAda yang bisa saya bantu?";
}

function formatAIResponse(text) {
    if (!text) return "🤖 Maaf, saya tidak dapat memproses jawaban ini.";

    let formatted = escapeHtml(text);
    // Format markdown-style text
    formatted = formatted.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
    formatted = formatted.replace(/\*(.+?)\*/g, "<em>$1</em>");
    formatted = formatted.replace(/`([^`]+)`/g, "<code style='background: var(--bg-tertiary); padding: 2px 6px; border-radius: 4px;'>$1</code>");
    // Format bullet points
    formatted = formatted.replace(/^[-•]\s(.+)$/gm, "<li>$1</li>");
    formatted = formatted.replace(/(<li>.*<\/li>)/s, "<ul>$1</ul>");
    // Line breaks
    formatted = formatted.replace(/\n/g, "<br>");

    return formatted;
}

function escapeHtml(text) {
    if (!text) return "";
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
}

function addMessage(html, type) {
    if (!chatBox) return null;

    const div = document.createElement("div");
    div.className = `message ${type}`;
    div.innerHTML = html;
    chatBox.appendChild(div);
    chatBox.scrollTop = chatBox.scrollHeight;

    return div;
}

function saveChatHistory() {
    if (chatBox) {
        localStorage.setItem("nofte_chat_history", chatBox.innerHTML);
    }
}

function loadChatHistory() {
    const history = localStorage.getItem("nofte_chat_history");
    if (history && chatBox) {
        chatBox.innerHTML = history;
        chatBox.scrollTop = chatBox.scrollHeight;
    }
}

function clearChat() {
    localStorage.removeItem("nofte_chat_history");
    if (chatBox) {
        chatBox.innerHTML = `
            <div class="message ai">
                👋 Halo!<br><br>
                Saya NOFTe, asisten dapur pintar Anda. Saya siap membantu Anda:<br><br>
                • Memberikan saran resep berdasarkan bahan yang ada<br>
                • Memberitahu tips menyimpan makanan<br>
                • Membantu mengatur bahan di kulkas<br><br>
                Ada yang bisa saya bantu?
            </div>
        `;
    }
}

window.clearChat = clearChat;
