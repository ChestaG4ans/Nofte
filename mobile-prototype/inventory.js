const INVENTORY_ENDPOINT = `${API_BASE_URL}/inventory`;

const inventoryForm = document.getElementById("inventoryForm");
const inventoryGrid = document.getElementById("inventoryGrid");
const inventoryMessage = document.getElementById("inventoryMessage");

document.addEventListener("DOMContentLoaded", async () => {
    await loadInventory();

    if (inventoryForm) {
        inventoryForm.addEventListener("submit", onSubmitInventory);
    }
});

async function loadInventory() {
    const token = getToken();

    if (!token) {
        logout();
        return;
    }

    inventoryGrid.innerHTML = `<div class="inventory-card loading"><p>Memuat inventory...</p></div>`;

    try {
        const response = await fetch(INVENTORY_ENDPOINT, {
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
            const error = await response.json();
            throw new Error(error.detail || "Gagal memuat inventory");
        }

        const items = await response.json();
        renderInventory(items);

    } catch (error) {
        inventoryGrid.innerHTML = `<div class="inventory-card error"><p>Gagal memuat inventory</p><small>${error.message}</small></div>`;
        console.error("Inventory error:", error);
    }
}

function renderInventory(items) {
    inventoryGrid.innerHTML = "";

    if (!items || !items.length) {
        inventoryGrid.innerHTML = `<div class="inventory-card empty"><h3>Inventory kosong</h3><p>Scan makanan dan tambahkan ke inventory untuk melihat di sini.</p></div>`;
        return;
    }

    items.forEach((item) => {
        const card = document.createElement("div");
        card.className = "inventory-card";

        const expiryDate = calculateExpiryDate(item.expiry_days);
        const daysLeft = item.expiry_days || 0;
        const urgencyClass = getUrgencyClass(daysLeft);

        card.innerHTML = `
            <h3>${escapeHtml(item.name)}</h3>
            <p class="quantity">${item.quantity} ${escapeHtml(item.unit)}</p>
            <div class="expiry-badge ${urgencyClass}">
                <span class="days-left">${daysLeft} hari</span>
                <span class="expiry-date">${expiryDate}</span>
            </div>
            <button class="delete-btn" onclick="deleteInventoryItem(${item.id})">Hapus</button>
        `;

        inventoryGrid.appendChild(card);
    });
}

function calculateExpiryDate(daysLeft) {
    if (!daysLeft || daysLeft <= 0) {
        return "Sudah kadaluarsa";
    }

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + daysLeft);

    return expiryDate.toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric"
    });
}

function getUrgencyClass(daysLeft) {
    if (daysLeft <= 0) return "expired";
    if (daysLeft <= 2) return "critical";
    if (daysLeft <= 5) return "warning";
    return "safe";
}

async function onSubmitInventory(event) {
    event.preventDefault();

    const token = getToken();
    if (!token) {
        logout();
        return;
    }

    const payload = {
        name: document.getElementById("itemName").value.trim(),
        quantity: Number(document.getElementById("itemQty").value) || 1,
        unit: document.getElementById("itemUnit").value.trim() || "Item",
        expiry_days: Number(document.getElementById("itemExpiry").value) || 0
    };

    if (!payload.name) {
        inventoryMessage.textContent = "Nama barang harus diisi.";
        return;
    }

    inventoryMessage.textContent = "Menyimpan...";

    try {
        const response = await fetch(INVENTORY_ENDPOINT, {
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
            throw new Error(error.detail || "Gagal menambah barang.");
        }

        inventoryForm.reset();
        document.getElementById("itemExpiry").value = "0";
        inventoryMessage.textContent = "Barang berhasil ditambahkan!";
        await loadInventory();

    } catch (error) {
        inventoryMessage.textContent = `Gagal: ${error.message}`;
        console.error(error);
    }
}

async function deleteInventoryItem(itemId) {
    if (!confirm("Yakin ingin menghapus item ini?")) return;

    const token = getToken();
    if (!token) {
        logout();
        return;
    }

    try {
        const response = await fetch(`${INVENTORY_ENDPOINT}/${itemId}`, {
            method: "DELETE",
            headers: {
                "Authorization": `Bearer ${token}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || "Gagal menghapus item.");
        }

        await loadInventory();

    } catch (error) {
        alert(`Gagal menghapus: ${error.message}`);
        console.error(error);
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
