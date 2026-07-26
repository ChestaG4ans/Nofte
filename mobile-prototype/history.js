const searchInput = document.getElementById("searchFood");
const historyTable = document.getElementById("historyTable");

let cachedRows = [];

document.addEventListener("DOMContentLoaded", async () => {
    await loadHistory();

    if (searchInput) {
        searchInput.addEventListener("keyup", filterRows);
    }
});

async function loadHistory() {
    const token = getToken();

    if (!token) {
        logout();
        return;
    }

    historyTable.innerHTML = `<tr><td colspan="4">Memuat riwayat...</td></tr>`;

    try {
        const response = await fetch(`${API_BASE_URL}/history`, {
            method: "GET",
            headers: {
                "Authorization": `Bearer ${token}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error("Gagal memuat riwayat.");
        }

        const histories = await response.json();
        renderHistory(histories);
    } catch (error) {
        historyTable.innerHTML = `<tr><td colspan="4">Gagal memuat riwayat.</td></tr>`;
        console.error(error);
    }
}

function renderHistory(histories) {
    historyTable.innerHTML = "";

    if (!histories.length) {
        historyTable.innerHTML = `<tr><td colspan="4">Belum ada riwayat scan.</td></tr>`;
        cachedRows = [];
        return;
    }

    const allRows = [];

    histories.forEach((item) => {
        const row = document.createElement("tr");

        const date = new Date(item.created_at);
        const dateText = Number.isNaN(date.getTime())
            ? "-"
            : date.toLocaleDateString("id-ID");

        let firstFood = {
            name: "-",
            freshness: "-",
            confidence: null
        };

        try {
            const parsed = JSON.parse(item.scan_result || "{}");
            if (Array.isArray(parsed.foods) && parsed.foods.length > 0) {
                firstFood = parsed.foods[0];
            }
        } catch (_) {}

        const confidenceText =
            typeof firstFood.confidence === "number"
                ? `${Math.round(firstFood.confidence * 100)}%`
                : "-";

        row.innerHTML = `
            <td>${dateText}</td>
            <td>${firstFood.name || "-"}</td>
            <td>${firstFood.freshness || "-"}</td>
            <td>${confidenceText}</td>
        `;

        historyTable.appendChild(row);
        allRows.push(row);
    });

    cachedRows = allRows;
}

function filterRows() {
    const keyword = (searchInput.value || "").toLowerCase();

    cachedRows.forEach((row) => {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(keyword) ? "" : "none";
    });
}
