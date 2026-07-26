import json
from sqlalchemy.orm import Session

from app.models.user import ScanHistory
from app.repositories.history_repository import HistoryRepository


class HistoryService:
    def __init__(self, db: Session):
        self.db = db
        self.history_repository = HistoryRepository(db)

    def save_scan_result(self, user_id: int, foods: list[dict]) -> ScanHistory:
        return self.history_repository.create(
            user_id=user_id,
            scan_result=json.dumps({"foods": foods})
        )

    def get_user_history(self, user_id: int) -> list[ScanHistory]:
        return self.history_repository.get_by_user_id(user_id)
