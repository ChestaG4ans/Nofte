document.addEventListener("DOMContentLoaded", async () => {
    await loadDashboardData();
});

async function loadDashboardData() {
    const token = getToken();

    if (!token) {
        logout();
        return;
    }

    try {
        const [historyRes, inventoryRes] = await Promise.all([
            fetch(`${API_BASE_URL}/history`, {
                headers: { Authorization: `Bearer ${token}` }
            }),
            fetch(`${API_BASE_URL}/inventory`, {
                headers: { Authorization: `Bearer ${token}` }
            })
        ]);

        if (historyRes.status === 401 || inventoryRes.status === 401) {
            logout();
            return;
        }

        if (!historyRes.ok || !inventoryRes.ok) {
            throw new Error("Gagal memuat dashboard.");
        }

        const histories = await historyRes.json();
        const inventories = await inventoryRes.json();

        renderStats(histories);
        renderRecent(histories);
        renderInventoryPreview(inventories);
    } catch (error) {
        console.error(error);
    }
}

function renderStats(histories) {
    const totalScanEl = document.getElementById("statTotalScan");
    const safeFoodEl = document.getElementById("statSafeFood");
    const expiringEl = document.getElementById("statExpiring");

    const foods = [];

    (histories || []).forEach((item) => {
        try {
            const parsed = JSON.parse(item.scan_result || "{}");
            if (Array.isArray(parsed.foods)) {
                foods.push(...parsed.foods);
            }
        } catch (_) {}
    });

    const totalScan = histories.length;
    const safeFood = foods.filter((f) => String(f.freshness || "").toLowerCase().includes("fresh")).length;
    const expiring = foods.filter((f) => {
        const shelf = String(f.shelf_life || "");
        const m = shelf.match(/\d+/);
        if (!m) return false;
        return Number(m[0]) <= 3;
    }).length;

    if (totalScanEl) totalScanEl.textContent = String(totalScan);
    if (safeFoodEl) safeFoodEl.textContent = String(safeFood);
    if (expiringEl) expiringEl.textContent = String(expiring);
}

function renderRecent(histories) {
    const recentGrid = document.getElementById("recentGrid");
    if (!recentGrid) return;

    const rows = [];

    (histories || []).forEach((item) => {
        try {
            const parsed = JSON.parse(item.scan_result || "{}");
            const foods = Array.isArray(parsed.foods) ? parsed.foods : [];
            foods.forEach((food) => {
                let days = 7;
                const m = String(food.shelf_life || "").match(/\d+/);
                if (m) days = Number(m[0]);
                rows.push({
                    name: food.name || "Hasil Scan",
                    days
                });
            });
        } catch (_) {}
    });

    rows.sort((a, b) => a.days - b.days);

    recentGrid.innerHTML = "";
    rows.slice(0, 3).forEach((item) => {
        const className = item.days <= 1 ? "danger" : item.days <= 3 ? "warning" : "success";
        const el = document.createElement("div");
        el.className = "recent-item";
        el.innerHTML = `
            <div>${escapeHtml(item.name)}</div>
            <span class="${className}">${item.days} Hari Lagi</span>
        `;
        recentGrid.appendChild(el);
    });

    if (!rows.length) {
        recentGrid.innerHTML = `<div class="recent-item"><div>Belum ada riwayat scan</div><span class="success">-</span></div>`;
    }
}

function renderInventoryPreview(items) {
    const container = document.getElementById("inventoryPreview");
    if (!container) return;

    container.innerHTML = "";

    (items || []).slice(0, 4).forEach((item) => {
        const card = document.createElement("div");
        card.className = "inventory-card";
        card.innerHTML = `
            📦
            <h3>${escapeHtml(item.name)}</h3>
            <span>${item.quantity} ${escapeHtml(item.unit)}</span>
        `;
        container.appendChild(card);
    });

    if (!(items || []).length) {
        container.innerHTML = `<div class="inventory-card"><h3>Inventory kosong</h3><span>Tambahkan barang di menu Inventory</span></div>`;
    }
}

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "<")
        .replace(/>/g, ">");
}
