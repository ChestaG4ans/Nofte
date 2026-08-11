// NoFTe API Configuration
// For static hosting (Cloudflare Pages), we use localStorage simulation
// For backend mode, set API_BASE_URL to your server

const TOKEN_KEY = "nofte_access_token";
const USER_KEY = "nofte_user";

// API URLs - Fallback ke demo mode jika tidak ada backend
const API_BASE_URL = (typeof window !== 'undefined' && window.location.hostname === 'localhost')
    ? "http://localhost:8000"
    : null; // Null means demo mode (no backend)
const CHAT_API_URL = (typeof window !== 'undefined' && window.location.hostname === 'localhost')
    ? "http://localhost:3000"
    : null;

// =========================
// TOKEN MANAGEMENT
// =========================

function getToken() {
    return localStorage.getItem(TOKEN_KEY);
}

function setToken(token) {
    localStorage.setItem(TOKEN_KEY, token);
}

function clearToken() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
}

function getUser() {
    const userStr = localStorage.getItem(USER_KEY);
    return userStr ? JSON.parse(userStr) : null;
}

function setUser(user) {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
}

// =========================
// AUTH CHECK
// =========================

function requireAuth() {
    const currentPage = window.location.pathname.split("/").pop() || "index.html";
    const publicPages = ["login.html", "register.html"];

    if (!publicPages.includes(currentPage) && !getToken()) {
        window.location.href = "login.html";
        return false;
    }
    return true;
}

function logout() {
    clearToken();
    window.location.href = "login.html";
}

// =========================
// DEMO MODE HELPERS
// =========================

function isDemoMode() {
    return API_BASE_URL === null;
}

function saveDemoUser(name, email) {
    const demoUser = { name, email, isDemo: true };
    setUser(demoUser);
    setToken('demo_token_' + Date.now());
    return demoUser;
}

function validateDemoLogin(email, password) {
    // Demo mode: accept any valid email format with password >= 8 chars
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email) && password.length >= 8;
}

// =========================
// API HELPERS
// =========================

async function apiRequest(endpoint, options = {}) {
    if (isDemoMode()) {
        throw new Error('Demo mode: No backend available');
    }

    const token = getToken();
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers
    });

    // Handle 401 Unauthorized
    if (response.status === 401) {
        logout();
        throw new Error('Session expired. Please login again.');
    }

    return response;
}

// Initialize auth check
document.addEventListener('DOMContentLoaded', requireAuth);
