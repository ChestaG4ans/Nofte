from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.core.security import get_current_user, get_db
from app.schemas.history_schema import HistoryItemResponse
from app.schemas.scan_schema import ScanResponse
from app.services.history_service import HistoryService
from app.services.scan_app_service import ScanAppService

router = APIRouter(tags=["scan"])


@router.post(
    "/scan",
    response_model=ScanResponse
)
async def scan_food(
    request: Request,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    image_bytes = await request.body()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="Kirim foto sebagai raw binary body."
        )

    history_service = HistoryService(db)
    scan_app_service = ScanAppService(history_service=history_service)
    foods = scan_app_service.process_scan(
        user_id=current_user.id,
        image_bytes=image_bytes
    )

    return {
        "foods": foods
    }


@router.get("/history", response_model=list[HistoryItemResponse])
def get_history(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    history_service = HistoryService(db)
    return history_service.get_user_history(current_user.id)
