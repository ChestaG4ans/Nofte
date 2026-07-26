// ====================================
// NOFTE AI ASSISTANT
// ====================================

console.log("CHAT.JS LOADED");

// ====================================
// CONFIG
// ====================================

const API_URL =
    "http://localhost:3000/api/chat";

const MAX_RETRIES = 2;

// ====================================
// ELEMENT
// ====================================

const chatBox =
    document.getElementById("chatBox");

const chatInput =
    document.getElementById("chatInput");

const sendBtn =
    document.getElementById("sendBtn");

// ====================================
// STATE
// ====================================

let isLoading = false;

// ====================================
// EVENT
// ====================================

sendBtn.addEventListener(
    "click",
    sendMessage
);

chatInput.addEventListener(
    "keydown",
    (e) => {

        if (e.key === "Enter") {

            sendMessage();

        }

    }
);

// ====================================
// LOAD HISTORY
// ====================================

loadHistory();

// ====================================
// SEND MESSAGE
// ====================================

async function sendMessage() {

    if (isLoading) return;

    const message =
        chatInput.value.trim();

    if (!message)
        return;

    // Disable input saat loading
    setLoading(true);

    addMessage(
        escapeHtml(message),
        "user"
    );

    chatInput.value = "";

    const loading =
        addMessage(
            "🤔 Memikirkan jawaban...",
            "ai"
        );

    let success = false;

    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {

        try {

            const response =
                await fetch(
                    API_URL,
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/json"
                        },

                        body: JSON.stringify({
                            message
                        })
                    }
                );

            const data =
                await response.json();

            loading.remove();

            if (!response.ok) {

                addMessage(
                    `❌ Error: ${data.error || "Terjadi kesalahan"}`,
                    "ai"
                );

            } else {

                addMessage(
                    formatAIResponse(data.reply || "Tidak ada jawaban."),
                    "ai"
                );

                success = true;

            }

            break;

        } catch (err) {

            console.error(`Attempt ${attempt + 1} failed:`, err);

            if (attempt === MAX_RETRIES) {

                loading.remove();

                addMessage(
                    "❌ Gagal terhubung ke server. Pastikan server berjalan di localhost:3000",
                    "ai"
                );

            } else {

                loading.innerHTML =
                    `🔄 Mencoba ulang... (${attempt + 1}/${MAX_RETRIES})`;

                await sleep(1000);

            }

        }

    }

    setLoading(false);

    saveHistory();

}

// ====================================
// SET LOADING STATE
// ====================================

function setLoading(loading) {

    isLoading = loading;

    chatInput.disabled = loading;
    sendBtn.disabled = loading;

    chatInput.placeholder =
        loading
            ? "Menunggu jawaban..."
            : "Tanyakan sesuatu...";

}

// ====================================
// FORMAT AI RESPONSE
// ====================================

function formatAIResponse(text) {

    // Escape HTML dulu
    let formatted =
        escapeHtml(text);

    // Format bullet points
    formatted =
        formatted.replace(
            /^[•\-*]\s+(.+)$/gm,
            "• $1"
        );

    // Format numbered lists
    formatted =
        formatted.replace(
            /^(\d+)\.\s+(.+)$/gm,
            "<strong>$1.</strong> $2"
        );

    // Bold text (**text**)
    formatted =
        formatted.replace(
            /\*\*(.+?)\*\*/g,
            "<strong>$1</strong>"
        );

    // Italic text (*text*)
    formatted =
        formatted.replace(
            /\*(.+?)\*/g,
            "<em>$1</em>"
        );

    // Code blocks
    formatted =
        formatted.replace(
            /`([^`]+)`/g,
            "<code>$1</code>"
        );

    // Newlines ke <br>
    formatted =
        formatted.replace(
            /\n/g,
            "<br>"
        );

    return formatted;

}

// ====================================
// ESCAPE HTML
// ====================================

function escapeHtml(text) {

    const div =
        document.createElement("div");

    div.textContent = text;

    return div.innerHTML;

}

// ====================================
// SLEEP
// ====================================

function sleep(ms) {

    return new Promise(
        resolve =>
            setTimeout(resolve, ms)
    );

}

// ====================================
// ADD MESSAGE
// ====================================

function addMessage(
    html,
    type
) {

    const div =
        document.createElement(
            "div"
        );

    div.className =
        `message ${type}`;

    div.innerHTML = html;

    chatBox.appendChild(
        div
    );

    scrollBottom();

    return div;

}

// ====================================
// SCROLL
// ====================================

function scrollBottom() {

    chatBox.scrollTop =
        chatBox.scrollHeight;

}

// ====================================
// SAVE HISTORY
// ====================================

function saveHistory() {

    localStorage.setItem(
        "nofte_chat",
        chatBox.innerHTML
    );

}

// ====================================
// LOAD HISTORY
// ====================================

function loadHistory() {

    const history =
        localStorage.getItem(
            "nofte_chat"
        );

    if (history) {

        chatBox.innerHTML =
            history;

    }

}

// ====================================
// CLEAR CHAT
// ====================================

function clearChat() {

    localStorage.removeItem(
        "nofte_chat"
    );

    chatBox.innerHTML =
        `
        <div class="message ai">
            Halo 👋<br>
            Saya siap membantu Anda.
        </div>
        `;

}

window.clearChat =
    clearChat;