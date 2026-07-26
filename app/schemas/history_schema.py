from datetime import datetime
from pydantic import BaseModel


class HistoryItemResponse(BaseModel):
    id: int
    user_id: int
    scan_result: str
    created_at: datetime
