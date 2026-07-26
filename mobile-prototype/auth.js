const API_BASE_URL = "http://127.0.0.1:8000";
const TOKEN_KEY = "nofte_access_token";

function getToken() {
    return localStorage.getItem(TOKEN_KEY);
}

function setToken(token) {
    localStorage.setItem(TOKEN_KEY, token);
}

function clearToken() {
    localStorage.removeItem(TOKEN_KEY);
}

function requireAuth() {
    const currentPage = window.location.pathname.split("/").pop() || "index.html";
    const publicPages = ["login.html"];

    if (!publicPages.includes(currentPage) && !getToken()) {
        window.location.href = "login.html";
    }
}

function logout() {
    clearToken();
    window.location.href = "login.html";
}

requireAuth();
