from pydantic import BaseModel

class NutritionInfo(BaseModel):
    serving: str | None = None
    calories: float | None = None
    total_fat_g: float | None = None
    sodium_mg: float | None = None
    potassium_mg: float | None = None
    carbohydrates_g: float | None = None
    fiber_g: float | None = None
    sugars_g: float | None = None
    protein_g: float | None = None

class BoundingBox(BaseModel):
    x1: float
    y1: float
    x2: float
    y2: float

class FoodItem(BaseModel):
    name: str
    freshness: str
    shelf_life: int
    confidence: float | None = None
    detected_label: str | None = None
    yolo_label: str | None = None
    yolo_confidence: float | None = None
    decision_source: str | None = None
    bbox: BoundingBox | None = None
    nutrition: NutritionInfo | None = None

class ScanResponse(BaseModel):
    foods: list[FoodItem]
