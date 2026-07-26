from __future__ import annotations

import argparse
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_DATA_YAML = ROOT_DIR / "yolo_dataset" / "data.yaml"


def main() -> None:
    args = parse_args()

    try:
        from ultralytics import YOLO
    except ModuleNotFoundError as exc:
        raise SystemExit(
            "Ultralytics belum terpasang. Jalankan: "
            "venv\\Scripts\\python.exe -m pip install ultralytics"
        ) from exc

    model = YOLO(args.base_model)
    results = model.train(
        data=str(args.data),
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch=args.batch,
        project=str(ROOT_DIR / "runs" / "yolo"),
        name="nofte_detect",
    )

    best_model = Path(results.save_dir) / "weights" / "best.pt"
    print(f"YOLO best model: {best_model}")

    if args.export_tflite:
        exported = YOLO(best_model).export(format="tflite", imgsz=args.imgsz)
        print(f"YOLO exported model: {exported}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train NoFTe YOLO detector.")
    parser.add_argument("--data", type=Path, default=DEFAULT_DATA_YAML)
    parser.add_argument("--base-model", default="yolo26n.pt")
    parser.add_argument("--epochs", type=int, default=100)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--batch", type=int, default=8)
    parser.add_argument("--export-tflite", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    main()
