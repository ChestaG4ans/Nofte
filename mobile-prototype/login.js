let isRegisterMode = false;

const authTitle = document.getElementById("authTitle");
const authSubtitle = document.getElementById("authSubtitle");
const nameWrap = document.getElementById("nameWrap");
const nameInput = document.getElementById("nameInput");
const emailInput = document.getElementById("emailInput");
const passwordInput = document.getElementById("passwordInput");
const authMessage = document.getElementById("authMessage");
const submitAuthBtn = document.getElementById("submitAuthBtn");
const switchLabel = document.getElementById("switchLabel");
const switchAuthMode = document.getElementById("switchAuthMode");

const currentToken = getToken();
if (currentToken) {
    window.location.href = "index.html";
}

switchAuthMode.addEventListener("click", (e) => {
    e.preventDefault();
    isRegisterMode = !isRegisterMode;
    renderMode();
});

submitAuthBtn.addEventListener("click", submitAuth);

function renderMode() {
    if (isRegisterMode) {
        authTitle.innerText = "Daftar";
        authSubtitle.innerText = "Buat akun baru untuk mulai menggunakan NoFTe.";
        nameWrap.style.display = "block";
        submitAuthBtn.innerText = "Daftar";
        switchLabel.innerText = "Sudah punya akun?";
        switchAuthMode.innerText = "Login";
    } else {
        authTitle.innerText = "Login";
        authSubtitle.innerText = "Masuk untuk melanjutkan ke NoFTe.";
        nameWrap.style.display = "none";
        submitAuthBtn.innerText = "Login";
        switchLabel.innerText = "Belum punya akun?";
        switchAuthMode.innerText = "Daftar";
    }
    authMessage.innerText = "";
}

async function submitAuth() {
    const email = emailInput.value.trim();
    const password = passwordInput.value.trim();
    const name = nameInput.value.trim();

    if (!email || !password) {
        authMessage.innerText = "Email dan password wajib diisi.";
        return;
    }

    if (password.length < 8) {
        authMessage.innerText = "Password minimal 8 karakter.";
        return;
    }

    submitAuthBtn.disabled = true;
    authMessage.innerText = isRegisterMode ? "Memproses pendaftaran..." : "Memproses login...";

    try {
        if (isRegisterMode) {
            const registerResponse = await fetch(`${API_BASE_URL}/auth/register`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    name: name || null,
                    email,
                    password
                })
            });

            if (!registerResponse.ok) {
                const err = await registerResponse.json();
                throw new Error(err.detail || "Registrasi gagal.");
            }

            authMessage.innerText = "Registrasi berhasil. Melakukan login...";
        }

        const loginResponse = await fetch(`${API_BASE_URL}/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        });

        if (!loginResponse.ok) {
            const err = await loginResponse.json();
            throw new Error(err.detail || "Login gagal.");
        }

        const loginData = await loginResponse.json();
        setToken(loginData.access_token);

        authMessage.innerText = "Berhasil login. Mengarahkan...";
        window.location.href = "index.html";
    } catch (error) {
        authMessage.innerText = error.message || "Terjadi kesalahan.";
    } finally {
        submitAuthBtn.disabled = false;
    }
}

renderMode();
