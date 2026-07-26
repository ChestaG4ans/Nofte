from app.services.history_service import HistoryService
from app.services.scan_service import ScanService


class ScanAppService:
    def __init__(self, history_service: HistoryService):
        self.history_service = history_service

    def process_scan(self, user_id: int, image_bytes: bytes) -> list[dict]:
        foods = ScanService.analyze_food(image_bytes)
        self.history_service.save_scan_result(user_id=user_id, foods=foods)
        return foods
