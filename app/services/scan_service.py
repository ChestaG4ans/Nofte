from __future__ import annotations

import json
from pathlib import Path

import tensorflow as tf

from app.services.nutrition_service import NutritionService


ROOT_DIR = Path(__file__).resolve().parents[2]
MODEL_PATH = ROOT_DIR / "models" / "cnn_food_classifier.keras"
CLASS_NAMES_PATH = ROOT_DIR / "models" / "class_names.json"
YOLO_MODEL_PATH = ROOT_DIR / "runs" / "yolo" / "nofte_detect" / "weights" / "best.pt"
IMAGE_SIZE = (224, 224)

SHELF_LIFE_DAYS = {
    "Apple": 21,
    "Cabbage": 14,
    "Carrot": 14,
    "Cucumber": 7,
    "Eggplant": 5,
    "Pear": 7,
    "Zucchini": 5,
    "Unknown": 0,
}

FOOD_KEYWORDS = {
    "apple": "Apple",
    "cabbage": "Cabbage",
    "carrot": "Carrot",
    "cucumber": "Cucumber",
    "eggplant": "Eggplant",
    "pear": "Pear",
    "zucchini": "Zucchini",
}


class ScanService:
    _model = None
    _yolo_model = None
    _class_names: list[str] | None = None

    @staticmethod
    def analyze_food(image_bytes: bytes | None = None):
        if not image_bytes:
            return [ScanService._fallback_result("Tidak ada gambar")]

        try:
            model = ScanService._load_model()
            class_names = ScanService._load_class_names()

            if model is None or not class_names:
                return [ScanService._fallback_result("Model belum tersedia")]

            image_array = ScanService._decode_image(image_bytes)
            yolo_detections = ScanService._detect_with_yolo(image_array)

            if yolo_detections:
                return [
                    ScanService._classify_detection(model, class_names, image_array, detection)
                    for detection in yolo_detections[:3]
                ]

            image = ScanService._preprocess_array(image_array)
            predictions = model.predict(image, verbose=0)[0]
            confidence = float(tf.reduce_max(predictions).numpy())
            label_index = int(tf.argmax(predictions).numpy())
            detected_label = class_names[label_index]
            food_name = ScanService._food_name_from_label(detected_label)
            freshness = ScanService._freshness_from_label(detected_label)
            shelf_life = ScanService._estimate_shelf_life(food_name, freshness)

            return [
                {
                    "name": food_name,
                    "freshness": freshness,
                    "shelf_life": shelf_life,
                    "confidence": round(confidence, 4),
                    "detected_label": detected_label,
                    "yolo_label": None,
                    "yolo_confidence": None,
                    "decision_source": "cnn",
                    "bbox": None,
                    "nutrition": NutritionService.get_for_food(food_name),
                }
            ]
        except Exception as e:
            print(f"Error analyzing food: {e}")
            return [ScanService._fallback_result(f"Error: {str(e)}")]

    @staticmethod
    def _load_model():
        if ScanService._model is not None:
            return ScanService._model

        if not MODEL_PATH.exists():
            return None

        try:
            ScanService._model = tf.keras.models.load_model(MODEL_PATH)
            return ScanService._model
        except Exception as e:
            print(f"Error loading CNN model: {e}")
            return None

    @staticmethod
    def _load_yolo_model():
        if ScanService._yolo_model is not None:
            return ScanService._yolo_model

        if not YOLO_MODEL_PATH.exists():
            return None

        from ultralytics import YOLO

        ScanService._yolo_model = YOLO(YOLO_MODEL_PATH)
        return ScanService._yolo_model

    @staticmethod
    def _load_class_names() -> list[str]:
        if ScanService._class_names is not None:
            return ScanService._class_names

        if not CLASS_NAMES_PATH.exists():
            return []

        ScanService._class_names = json.loads(CLASS_NAMES_PATH.read_text())
        return ScanService._class_names

    @staticmethod
    def _decode_image(image_bytes: bytes):
        image = tf.io.decode_image(image_bytes, channels=3, expand_animations=False)
        return image.numpy()

    @staticmethod
    def _preprocess_array(image_array):
        image = tf.convert_to_tensor(image_array, dtype=tf.float32)
        image = tf.image.resize(image, IMAGE_SIZE)
        return tf.expand_dims(image, axis=0)

    @staticmethod
    def _detect_with_yolo(image_array) -> list[dict]:
        yolo_model = ScanService._load_yolo_model()
        if yolo_model is None:
            return []

        results = yolo_model.predict(
            source=image_array,
            imgsz=320,
            conf=0.25,
            verbose=False,
        )
        if not results:
            return []

        result = results[0]
        detections = []
        for box in result.boxes:
            class_id = int(box.cls[0].item())
            confidence = float(box.conf[0].item())
            x1, y1, x2, y2 = [float(value) for value in box.xyxy[0].tolist()]
            detections.append(
                {
                    "label": result.names[class_id],
                    "confidence": confidence,
                    "bbox": {
                        "x1": x1,
                        "y1": y1,
                        "x2": x2,
                        "y2": y2,
                    },
                }
            )

        return sorted(detections, key=lambda item: item["confidence"], reverse=True)

    @staticmethod
    def _classify_detection(model, class_names: list[str], image_array, detection: dict):
        crop = ScanService._crop_image(image_array, detection["bbox"])
        image = ScanService._preprocess_array(crop)
        predictions = model.predict(image, verbose=0)[0]
        cnn_confidence = float(tf.reduce_max(predictions).numpy())
        label_index = int(tf.argmax(predictions).numpy())
        detected_label = class_names[label_index]
        cnn_food_name = ScanService._food_name_from_label(detected_label)
        yolo_food_name = ScanService._food_name_from_label(detection["label"])
        food_name, confidence, decision_source = ScanService._choose_food_name(
            cnn_food_name=cnn_food_name,
            cnn_confidence=cnn_confidence,
            yolo_food_name=yolo_food_name,
            yolo_confidence=detection["confidence"],
        )
        freshness_label = detected_label if decision_source == "cnn" else detection["label"]
        freshness = ScanService._freshness_from_label(freshness_label)
        shelf_life = ScanService._estimate_shelf_life(food_name, freshness)

        return {
            "name": food_name,
            "freshness": freshness,
            "shelf_life": shelf_life,
            "confidence": round(confidence, 4),
            "detected_label": detected_label,
            "yolo_label": detection["label"],
            "yolo_confidence": round(detection["confidence"], 4),
            "decision_source": decision_source,
            "bbox": detection["bbox"],
            "nutrition": NutritionService.get_for_food(food_name),
        }

    @staticmethod
    def _crop_image(image_array, bbox: dict):
        height, width = image_array.shape[:2]
        x1 = max(0, min(width - 1, int(bbox["x1"])))
        y1 = max(0, min(height - 1, int(bbox["y1"])))
        x2 = max(x1 + 1, min(width, int(bbox["x2"])))
        y2 = max(y1 + 1, min(height, int(bbox["y2"])))
        return image_array[y1:y2, x1:x2]

    @staticmethod
    def _food_name_from_label(label: str) -> str:
        normalized = label.lower()
        for keyword, food_name in FOOD_KEYWORDS.items():
            if keyword in normalized:
                return food_name
        return label.replace("_", " ").title()

    @staticmethod
    def _freshness_from_label(label: str) -> str:
        normalized = label.lower()
        if "rotten" in normalized or "defect" in normalized:
            return "Tidak segar"
        if "dark" in normalized:
            return "Perlu dicek"
        return "Segar"

    @staticmethod
    def _estimate_shelf_life(food_name: str, freshness: str) -> int:
        base_days = SHELF_LIFE_DAYS.get(food_name, 3)
        if freshness == "Tidak segar":
            return 0
        if freshness == "Perlu dicek":
            return max(1, base_days // 3)
        return base_days

    @staticmethod
    def _choose_food_name(
        cnn_food_name: str,
        cnn_confidence: float,
        yolo_food_name: str,
        yolo_confidence: float,
    ) -> tuple[str, float, str]:
        if cnn_food_name == yolo_food_name:
            return cnn_food_name, max(cnn_confidence, yolo_confidence), "cnn+yolo"

        if yolo_confidence >= 0.85 and cnn_confidence < 0.8:
            return yolo_food_name, yolo_confidence, "yolo"

        return cnn_food_name, cnn_confidence, "cnn"

    @staticmethod
    def _fallback_result(reason: str):
        return {
            "name": "Unknown",
            "freshness": reason,
            "shelf_life": 0,
            "confidence": 0,
            "detected_label": None,
            "yolo_label": None,
            "yolo_confidence": None,
            "decision_source": None,
            "bbox": None,
            "nutrition": None,
        }
