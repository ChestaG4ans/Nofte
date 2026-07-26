const EXPIRY_ENDPOINT = `${API_BASE_URL}/inventory`;

document.addEventListener("DOMContentLoaded", async () => {
    await loadExpiryData();
});

async function loadExpiryData() {
    const token = getToken();
    const expiryGrid = document.querySelector(".expiry-grid");

    if (!token) {
        logout();
        return;
    }

    if (expiryGrid) {
        expiryGrid.innerHTML = `<div class="expiry warning"><p>Memuat data...</p></div>`;
    }

    try {
        const response = await fetch(EXPIRY_ENDPOINT, {
            method: "GET",
            headers: { Authorization: `Bearer ${token}` }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error("Gagal memuat data kadaluarsa.");
        }

        const items = await response.json();
        renderExpiry(items);

    } catch (error) {
        if (expiryGrid) {
            expiryGrid.innerHTML = `<div class="expiry danger"><p>Gagal memuat data</p><small>${error.message}</small></div>`;
        }
        console.error(error);
    }
}

function renderExpiry(items) {
    const expiryGrid = document.querySelector(".expiry-grid");
    if (!expiryGrid) return;

    expiryGrid.innerHTML = "";

    if (!items || !items.length) {
        expiryGrid.innerHTML = `<div class="expiry success"><p>Inventory kosong</p><small>Scan dan tambah makanan ke inventory</small></div>`;
        return;
    }

    // Sort by expiry days (soonest first)
    const sortedItems = [...items].sort((a, b) => (a.expiry_days || 0) - (b.expiry_days || 0));

    sortedItems.forEach((item) => {
        const box = document.createElement("div");
        const daysLeft = item.expiry_days || 0;

        let urgencyClass = "safe";
        let urgencyIcon = "✅";

        if (daysLeft <= 0) {
            urgencyClass = "expired";
            urgencyIcon = "❌";
        } else if (daysLeft <= 2) {
            urgencyClass = "critical";
            urgencyIcon = "🚨";
        } else if (daysLeft <= 5) {
            urgencyClass = "warning";
            urgencyIcon = "⚠️";
        }

        const expiryDate = calculateExpiryDate(daysLeft);

        box.className = `expiry-card ${urgencyClass}`;
        box.innerHTML = `
            <div class="expiry-header">
                <span class="urgency-icon">${urgencyIcon}</span>
                <h4>${escapeHtml(item.name)}</h4>
            </div>
            <div class="expiry-details">
                <p class="quantity">${item.quantity} ${escapeHtml(item.unit)}</p>
                <p class="days-badge">${daysLeft} hari</p>
                <p class="expiry-date">${expiryDate}</p>
            </div>
        `;

        expiryGrid.appendChild(box);
    });
}

function calculateExpiryDate(daysLeft) {
    if (!daysLeft || daysLeft <= 0) {
        return "Sudah kadaluarsa!";
    }

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + daysLeft);

    return expiryDate.toLocaleDateString("id-ID", {
        weekday: "short",
        day: "numeric",
        month: "short",
        year: "numeric"
    });
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
