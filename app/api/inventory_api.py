from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.security import get_current_user, get_db
from app.schemas.inventory_schema import (
    AddScanToInventoryRequest,
    InventoryCreateRequest,
    InventoryItemResponse,
)
from app.services.inventory_service import InventoryService

router = APIRouter(tags=["inventory"])


@router.get("/inventory", response_model=list[InventoryItemResponse])
def get_inventory(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    inventory_service = InventoryService(db)
    return inventory_service.get_user_inventory(current_user.id)


@router.post("/inventory", response_model=InventoryItemResponse)
def add_inventory(
    payload: InventoryCreateRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    inventory_service = InventoryService(db)
    return inventory_service.add_inventory_item(current_user.id, payload)


@router.post("/inventory/from-scan", response_model=InventoryItemResponse)
def add_inventory_from_scan(
    payload: AddScanToInventoryRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Add food item to inventory directly from scan result.
    expiry_days is automatically set from scan result's shelf_life.
    """
    inventory_service = InventoryService(db)
    return inventory_service.add_inventory_item(
        user_id=current_user.id,
        payload=None,
        name=payload.name,
        quantity=payload.quantity,
        unit=payload.unit,
        expiry_days=payload.expiry_days
    )


@router.delete("/inventory/{item_id}")
def delete_inventory_item(
    item_id: int,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete an inventory item."""
    inventory_service = InventoryService(db)
    success = inventory_service.delete_item(current_user.id, item_id)
    if not success:
        raise HTTPException(status_code=404, detail="Item tidak ditemukan")
    return {"message": "Item berhasil dihapus"}
