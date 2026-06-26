import argparse
from pathlib import Path

from PIL import Image

from tm_model import TeachableMachineModel


def main():
    parser = argparse.ArgumentParser(description="Predict one image with a Teachable Machine model.")
    parser.add_argument("image", help="Path to a test image.")
    parser.add_argument("--model-dir", default="model", help="Folder containing model files.")
    args = parser.parse_args()

    image_path = Path(args.image)
    if not image_path.exists():
        raise FileNotFoundError(f"Missing image: {image_path}")

    model = TeachableMachineModel(args.model_dir)
    label, confidence, _ = model.predict_image(Image.open(image_path))

    print(f"{label}: {confidence:.1%}")


if __name__ == "__main__":
    main()
