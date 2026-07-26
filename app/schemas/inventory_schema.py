from datetime import datetime
from pydantic import BaseModel, Field


class InventoryCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    quantity: int = Field(ge=1)
    unit: str = Field(min_length=1, max_length=30)
    expiry_days: int = Field(ge=0, default=0)


class AddScanToInventoryRequest(BaseModel):
    """Request to add food from scan result to inventory."""
    name: str = Field(min_length=1, max_length=100)
    expiry_days: int = Field(ge=0, description="Days until expiry, from scan result")
    quantity: int = Field(ge=1, default=1)
    unit: str = Field(min_length=1, max_length=30, default="Item")


class InventoryItemResponse(BaseModel):
    id: int
    user_id: int
    name: str
    quantity: int
    unit: str
    expiry_days: int
    expiry_date: datetime | None = None
    created_at: datetime

    class Config:
        from_attributes = True
