from __future__ import annotations

import argparse
import random
import shutil
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_DIR = ROOT_DIR / "dataset_selected"
DEFAULT_OUTPUT_DIR = ROOT_DIR / "yolo_dataset"
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def main() -> None:
    args = parse_args()
    source_dir = Path(args.source_dir)
    output_dir = Path(args.output_dir)
    class_names = sorted(path.name for path in source_dir.iterdir() if path.is_dir())

    if not class_names:
        raise SystemExit(f"Tidak ada kelas di {source_dir}")

    image_paths = collect_images(source_dir)
    random.Random(args.seed).shuffle(image_paths)

    split_index = int(len(image_paths) * args.train_ratio)
    train_paths = image_paths[:split_index]
    val_paths = image_paths[split_index:]

    for split, paths in {"train": train_paths, "val": val_paths}.items():
        write_split(
            paths=paths,
            source_dir=source_dir,
            output_dir=output_dir,
            class_names=class_names,
            split=split,
            box_scale=args.box_scale,
        )

    write_data_yaml(output_dir, class_names)
    print(f"YOLO dataset dibuat di: {output_dir}")
    print(f"Train images: {len(train_paths)}")
    print(f"Val images: {len(val_paths)}")
    print(f"Classes: {', '.join(class_names)}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Prepare NoFTe YOLO prototype dataset.")
    parser.add_argument("--source-dir", default=str(DEFAULT_SOURCE_DIR))
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR))
    parser.add_argument("--train-ratio", type=float, default=0.8)
    parser.add_argument("--box-scale", type=float, default=0.9)
    parser.add_argument("--seed", type=int, default=42)
    return parser.parse_args()


def collect_images(source_dir: Path) -> list[Path]:
    return [
        path
        for path in source_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    ]


def write_split(
    paths: list[Path],
    source_dir: Path,
    output_dir: Path,
    class_names: list[str],
    split: str,
    box_scale: float,
) -> None:
    images_dir = output_dir / "images" / split
    labels_dir = output_dir / "labels" / split
    images_dir.mkdir(parents=True, exist_ok=True)
    labels_dir.mkdir(parents=True, exist_ok=True)

    for path in paths:
        class_name = path.relative_to(source_dir).parts[0]
        class_id = class_names.index(class_name)
        filename = make_unique_filename(path, source_dir)
        image_output = images_dir / filename
        label_output = labels_dir / f"{Path(filename).stem}.txt"

        shutil.copy2(path, image_output)
        label_output.write_text(f"{class_id} 0.5 0.5 {box_scale} {box_scale}\n")


def make_unique_filename(path: Path, source_dir: Path) -> str:
    relative = path.relative_to(source_dir)
    stem = "__".join(relative.with_suffix("").parts)
    return f"{stem}{path.suffix.lower()}"


def write_data_yaml(output_dir: Path, class_names: list[str]) -> None:
    names = "\n".join(f"  {index}: {name}" for index, name in enumerate(class_names))
    content = (
        f"path: {output_dir.as_posix()}\n"
        "train: images/train\n"
        "val: images/val\n"
        f"names:\n{names}\n"
    )
    (output_dir / "data.yaml").write_text(content)


if __name__ == "__main__":
    main()
