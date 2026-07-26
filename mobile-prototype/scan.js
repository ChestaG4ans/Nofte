const API_URL = `${API_BASE_URL}`;
const SCAN_ENDPOINT = `${API_URL}/scan`;
const INVENTORY_ENDPOINT = `${API_URL}/inventory`;

const imageInput = document.getElementById("imageInput");
const previewImage = document.getElementById("previewImage");
const scanButton = document.getElementById("scanButton");
const results = document.getElementById("results");

let selectedFile = null;
let lastScanResults = [];

imageInput.addEventListener("change", () => {
    selectedFile = imageInput.files[0];
    if (!selectedFile) return;

    previewImage.src = URL.createObjectURL(selectedFile);
    previewImage.style.display = "block";
});

scanButton.addEventListener("click", scanFood);

async function scanFood() {
    if (!selectedFile) return;

    results.innerHTML = "<p class='loading'>Memindai...</p>";

    try {
        const token = getToken();
        if (!token) {
            logout();
            return;
        }

        const response = await fetch(SCAN_ENDPOINT, {
            method: "POST",
            headers: {
                "Content-Type": selectedFile.type,
                "Authorization": `Bearer ${token}`
            },
            body: selectedFile
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || "Gagal scan");
        }

        const data = await response.json();
        lastScanResults = data.foods || [];
        renderFoods(lastScanResults);

    } catch (err) {
        results.innerHTML = `<p class='error'>Gagal scan: ${err.message}</p>`;
        console.error(err);
    }
}

function renderFoods(foods) {
    results.innerHTML = "";

    if (!foods.length) {
        results.innerHTML = "<p class='info'>Tidak ada makanan terdeteksi.</p>";
        return;
    }

    foods.forEach((food, index) => {
        const div = document.createElement("div");
        div.className = "result-card";

        const freshnessColor = getFreshnessColor(food.freshness);
        const expiryDate = calculateExpiryDate(food.shelf_life);

        div.innerHTML = `
            <h3>${escapeHtml(food.name)}</h3>
            <p class="freshness" style="color: ${freshnessColor}">
                <strong>${food.freshness}</strong>
            </p>
            <p>Confidence: ${Math.round((food.confidence || 0) * 100)}%</p>
            <p>Shelf Life: ${food.shelf_life} Hari</p>
            <p class="expiry-info">
                <strong>Kadaluarsa:</strong> ${expiryDate}
            </p>
            <div class="nutrition-info">
                ${renderNutrition(food.nutrition)}
            </div>
            <button class="add-to-inventory-btn" onclick="addToInventory(${index})">
                + Tambah ke Inventory
            </button>
        `;

        results.appendChild(div);
    });
}

function getFreshnessColor(freshness) {
    if (!freshness) return "#666";
    const lower = freshness.toLowerCase();
    if (lower.includes("segar") || lower.includes("fresh")) return "#22c55e";
    if (lower.includes("perlu") || lower.includes("check")) return "#eab308";
    if (lower.includes("tidak segar") || lower.includes("rotten")) return "#ef4444";
    return "#666";
}

function calculateExpiryDate(shelfLifeDays) {
    if (!shelfLifeDays || shelfLifeDays <= 0) return "Sudah kadaluarsa";

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + shelfLifeDays);

    return expiryDate.toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric"
    });
}

function renderNutrition(nutrition) {
    if (!nutrition) return "<p class='no-nutrition'>Info nutrisi tidak tersedia</p>";

    return `
        <details>
            <summary>📊 Info Nutrisi</summary>
            <div class="nutrition-details">
                ${nutrition.serving ? `<p>Serving: ${nutrition.serving}</p>` : ""}
                ${nutrition.calories ? `<p>Calories: ${nutrition.calories}</p>` : ""}
                ${nutrition.protein_g ? `<p>Protein: ${nutrition.protein_g}g</p>` : ""}
                ${nutrition.carbohydrates_g ? `<p>Carbs: ${nutrition.carbohydrates_g}g</p>` : ""}
                ${nutrition.total_fat_g ? `<p>Fat: ${nutrition.total_fat_g}g</p>` : ""}
                ${nutrition.fiber_g ? `<p>Fiber: ${nutrition.fiber_g}g</p>` : ""}
            </div>
        </details>
    `;
}

async function addToInventory(foodIndex) {
    const food = lastScanResults[foodIndex];
    if (!food) return;

    const token = getToken();
    if (!token) {
        logout();
        return;
    }

    const payload = {
        name: food.name,
        expiry_days: food.shelf_life || 0,
        quantity: 1,
        unit: "Item"
    };

    try {
        const response = await fetch(`${INVENTORY_ENDPOINT}/from-scan`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify(payload)
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || "Gagal menambah ke inventory");
        }

        const result = await response.json();
        alert(`✅ ${food.name} berhasil ditambahkan ke inventory!\nKadaluarsa: ${calculateExpiryDate(food.shelf_life)}`);

    } catch (err) {
        alert(`❌ Gagal: ${err.message}`);
        console.error(err);
    }
}

function escapeHtml(value) {
    if (value === null || value === undefined) return "";
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
