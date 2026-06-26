from pathlib import Path

import numpy as np
from PIL import Image


IMAGE_SIZE = (224, 224)


class TeachableMachineModel:
    def __init__(self, model_dir):
        self.model_dir = Path(model_dir)
        self.labels = self._load_labels()
        self.kind = None
        self.model = None
        self.interpreter = None
        self.input_details = None
        self.output_details = None
        self._load_model()

    def _load_labels(self):
        labels_path = self.model_dir / "labels.txt"
        if not labels_path.exists():
            raise FileNotFoundError(f"Missing labels file: {labels_path}")

        labels = []
        for line in labels_path.read_text().splitlines():
            label = line.strip()
            if not label:
                continue
            parts = label.split(maxsplit=1)
            labels.append(parts[1] if len(parts) == 2 and parts[0].isdigit() else label)
        return labels

    def _load_model(self):
        keras_path = self.model_dir / "keras_model.h5"
        tflite_path = self.model_dir / "model.tflite"

        if keras_path.exists():
            import tensorflow as tf

            self.kind = "keras"
            self.model = tf.keras.models.load_model(keras_path, compile=False)
            return

        if tflite_path.exists():
            import tensorflow as tf

            self.kind = "tflite"
            self.interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
            self.interpreter.allocate_tensors()
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()
            return

        raise FileNotFoundError(
            "Put keras_model.h5 or model.tflite in the model folder."
        )

    def predict_image(self, image):
        data = preprocess_image(image)

        if self.kind == "keras":
            prediction = self.model.predict(data, verbose=0)[0]
        else:
            self.interpreter.set_tensor(self.input_details[0]["index"], data)
            self.interpreter.invoke()
            prediction = self.interpreter.get_tensor(self.output_details[0]["index"])[0]

        best_index = int(np.argmax(prediction))
        label = self.labels[best_index] if best_index < len(self.labels) else str(best_index)
        confidence = float(prediction[best_index])
        return label, confidence, prediction


def preprocess_image(image):
    if not isinstance(image, Image.Image):
        image = Image.fromarray(image)

    image = image.convert("RGB").resize(IMAGE_SIZE)
    image_array = np.asarray(image, dtype=np.float32)
    image_array = (image_array / 127.5) - 1
    return np.expand_dims(image_array, axis=0)
