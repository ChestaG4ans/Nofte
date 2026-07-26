from sqlalchemy.orm import Session

from app.models.user import InventoryItem


class InventoryRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(
        self,
        user_id: int,
        name: str,
        quantity: int,
        unit: str,
        expiry_days: int
    ) -> InventoryItem:
        item = InventoryItem(
            user_id=user_id,
            name=name,
            quantity=quantity,
            unit=unit,
            expiry_days=expiry_days
        )
        self.db.add(item)
        self.db.commit()
        self.db.refresh(item)
        return item

    def get_by_user_id(self, user_id: int) -> list[InventoryItem]:
        return (
            self.db.query(InventoryItem)
            .filter(InventoryItem.user_id == user_id)
            .order_by(InventoryItem.created_at.desc())
            .all()
        )

    def get_by_id(self, user_id: int, item_id: int) -> InventoryItem | None:
        return (
            self.db.query(InventoryItem)
            .filter(InventoryItem.id == item_id, InventoryItem.user_id == user_id)
            .first()
        )

    def delete_by_id(self, user_id: int, item_id: int) -> bool:
        item = self.get_by_id(user_id, item_id)
        if item is None:
            return False
        self.db.delete(item)
        self.db.commit()
        return True
