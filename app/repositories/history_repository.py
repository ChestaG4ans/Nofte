from sqlalchemy.orm import Session

from app.models.user import ScanHistory


class HistoryRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, user_id: int, scan_result: str) -> ScanHistory:
        history = ScanHistory(
            user_id=user_id,
            scan_result=scan_result
        )
        self.db.add(history)
        self.db.commit()
        self.db.refresh(history)
        return history

    def get_by_user_id(self, user_id: int) -> list[ScanHistory]:
        return (
            self.db.query(ScanHistory)
            .filter(ScanHistory.user_id == user_id)
            .order_by(ScanHistory.created_at.desc())
            .all()
        )
