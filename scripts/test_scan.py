from __future__ import annotations

import argparse
import json
from pathlib import Path

from app.services.scan_service import ScanService


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_IMAGE = ROOT_DIR / "dataset_selected" / "Carrot" / "carrot_1" / "r0_0.jpg"


def main() -> None:
    args = parse_args()
    image_path = Path(args.image)

    if not image_path.exists():
        raise SystemExit(f"Gambar tidak ditemukan: {image_path}")

    foods = ScanService.analyze_food(image_path.read_bytes())
    print(json.dumps({"foods": foods}, indent=2))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Test NoFTe scan pipeline.")
    parser.add_argument("--image", default=str(DEFAULT_IMAGE))
    return parser.parse_args()


if __name__ == "__main__":
    main()
