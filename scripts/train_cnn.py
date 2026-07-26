from __future__ import annotations

import argparse
import json
from pathlib import Path

import tensorflow as tf


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_DATASET_DIR = ROOT_DIR / "dataset_selected"
DEFAULT_MODEL_DIR = ROOT_DIR / "models"
IMAGE_SIZE = (224, 224)


def main() -> None:
    args = parse_args()
    dataset_dir = Path(args.dataset_dir)
    model_dir = Path(args.model_dir)
    model_dir.mkdir(exist_ok=True)

    train_ds, val_ds, class_names = build_datasets(dataset_dir, args.batch_size)
    model = build_model(len(class_names))
    class_weight = build_class_weights(dataset_dir, class_names)

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_accuracy",
            patience=3,
            restore_best_weights=True,
        )
    ]

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        callbacks=callbacks,
        class_weight=class_weight,
    )

    model_path = model_dir / "cnn_food_classifier.keras"
    tflite_path = model_dir / "cnn_food_classifier.tflite"
    class_names_path = model_dir / "class_names.json"

    model.save(model_path)
    class_names_path.write_text(json.dumps(class_names, indent=2))
    export_tflite(model, tflite_path)

    print(f"Model saved to: {model_path}")
    print(f"TFLite model saved to: {tflite_path}")
    print(f"Class names saved to: {class_names_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train NoFTe CNN food classifier.")
    parser.add_argument("--dataset-dir", default=str(DEFAULT_DATASET_DIR))
    parser.add_argument("--model-dir", default=str(DEFAULT_MODEL_DIR))
    parser.add_argument("--epochs", type=int, default=50)
    parser.add_argument("--batch-size", type=int, default=32)
    return parser.parse_args()


def build_datasets(dataset_dir: Path, batch_size: int):
    train_ds = tf.keras.utils.image_dataset_from_directory(
        dataset_dir,
        validation_split=0.2,
        subset="training",
        seed=42,
        image_size=IMAGE_SIZE,
        batch_size=batch_size,
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        dataset_dir,
        validation_split=0.2,
        subset="validation",
        seed=42,
        image_size=IMAGE_SIZE,
        batch_size=batch_size,
    )

    class_names = train_ds.class_names
    augmentation = tf.keras.Sequential(
        [
            tf.keras.layers.RandomFlip("horizontal"),
            tf.keras.layers.RandomFlip("vertical"),
            tf.keras.layers.RandomRotation(0.3),
            tf.keras.layers.RandomZoom(0.2),
            tf.keras.layers.RandomContrast(0.2),
            tf.keras.layers.RandomBrightness(0.2),
        ]
    )

    autotune = tf.data.AUTOTUNE
    train_ds = train_ds.map(
        lambda images, labels: (augmentation(images, training=True), labels),
        num_parallel_calls=autotune,
    )
    train_ds = train_ds.shuffle(1000).prefetch(buffer_size=autotune)
    val_ds = val_ds.prefetch(buffer_size=autotune)

    return train_ds, val_ds, class_names


def build_model(num_classes: int) -> tf.keras.Model:
    # Using pretrained MobileNetV2 for better accuracy
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(*IMAGE_SIZE, 3),
        include_top=False,
        weights="imagenet",
    )
    base_model.trainable = False

    model = tf.keras.Sequential([
        base_model,
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dropout(0.5),
        tf.keras.layers.Dense(256, activation="relu"),
        tf.keras.layers.Dropout(0.4),
        tf.keras.layers.Dense(num_classes, activation="softmax"),
    ])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def build_class_weights(dataset_dir: Path, class_names: list[str]) -> dict[int, float]:
    counts = []
    for class_name in class_names:
        class_dir = dataset_dir / class_name
        image_count = sum(
            1
            for path in class_dir.rglob("*")
            if path.suffix.lower() in {".jpg", ".jpeg", ".png"}
        )
        counts.append(image_count)

    total = sum(counts)
    num_classes = len(class_names)
    return {
        index: total / (num_classes * count)
        for index, count in enumerate(counts)
        if count > 0
    }


def export_tflite(model: tf.keras.Model, output_path: Path) -> None:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    output_path.write_bytes(tflite_model)


if __name__ == "__main__":
    main()
