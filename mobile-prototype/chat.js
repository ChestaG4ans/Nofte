// Chat JavaScript - Connects to NoFTe Backend

const chatBox = document.getElementById("chatBox");
const chatInput = document.getElementById("chatInput");
const sendBtn = document.getElementById("sendBtn");

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

    const loading = addMessage("&#129300; Memikirkan jawaban...", "ai");

    try {
        const response = await fetch(`${API_BASE_URL}/api/chat`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message })
        });

        if (loading.parentNode) loading.remove();

        if (!response.ok) {
            const data = await response.json();
            addMessage(`&#9888; Error: ${data.error || "Terjadi kesalahan"}`, "ai");
        } else {
            const data = await response.json();
            addMessage(formatAIResponse(data.reply || "Tidak ada jawaban."), "ai");
        }

    } catch (err) {
        console.error("Chat Error:", err);
        if (loading.parentNode) loading.remove();
        addMessage("&#9888; Gagal terhubung ke server. Pastikan backend NoFTe berjalan.", "ai");
    }

    isLoading = false;
    if (sendBtn) sendBtn.disabled = false;
    saveChatHistory();
}

function formatAIResponse(text) {
    let formatted = escapeHtml(text);
    formatted = formatted.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
    formatted = formatted.replace(/\*(.+?)\*/g, "<em>$1</em>");
    formatted = formatted.replace(/`([^`]+)`/g, "<code style='background: var(--bg-tertiary); padding: 2px 6px; border-radius: 4px;'>$1</code>");
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
        localStorage.setItem("nofte_chat", chatBox.innerHTML);
    }
}

function loadChatHistory() {
    const history = localStorage.getItem("nofte_chat");
    if (history && chatBox) {
        chatBox.innerHTML = history;
        chatBox.scrollTop = chatBox.scrollHeight;
    }
}

function clearChat() {
    localStorage.removeItem("nofte_chat");
    if (chatBox) {
        chatBox.innerHTML = `
            <div class="message ai">
                &#128075; Halo!<br><br>
                Saya siap membantu Anda.
            </div>
        `;
    }
}

window.clearChat = clearChat;
