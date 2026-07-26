from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from app.models.user import InventoryItem
from app.repositories.inventory_repository import InventoryRepository
from app.schemas.inventory_schema import AddScanToInventoryRequest, InventoryCreateRequest


class InventoryService:
    def __init__(self, db: Session):
        self.db = db
        self.inventory_repository = InventoryRepository(db)

    def get_user_inventory(self, user_id: int) -> list[InventoryItem]:
        items = self.inventory_repository.get_by_user_id(user_id)
        # Add expiry_date calculation
        for item in items:
            if not hasattr(item, 'expiry_date') or item.expiry_date is None:
                item.expiry_date = datetime.now() + timedelta(days=item.expiry_days)
        return items

    def add_inventory_item(
        self,
        user_id: int,
        payload: InventoryCreateRequest | None = None,
        name: str | None = None,
        quantity: int | None = None,
        unit: str | None = None,
        expiry_days: int | None = None
    ) -> InventoryItem:
        # Support both payload-based and parameter-based creation
        if payload:
            name = payload.name.strip()
            quantity = payload.quantity
            unit = payload.unit.strip()
            expiry_days = payload.expiry_days
        else:
            name = name.strip() if name else ""
            unit = unit.strip() if unit else "Item"
            expiry_days = expiry_days or 0
            quantity = quantity or 1

        return self.inventory_repository.create(
            user_id=user_id,
            name=name,
            quantity=quantity,
            unit=unit,
            expiry_days=expiry_days
        )

    def delete_item(self, user_id: int, item_id: int) -> bool:
        return self.inventory_repository.delete_by_id(user_id, item_id)
