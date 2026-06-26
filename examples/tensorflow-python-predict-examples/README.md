# TensorFlow Python Predict Examples

These examples use a Teachable Machine **Image Project** from Python. This example is about spotting everyday objects, so it feels different from the browser voice game.

## What to Train

Make four classes:

- `pencil`
- `cup`
- `book`
- `background`

For each object class, show the camera the real object. Use the same kind of camera, lighting, distance, and background that you want to use in the Python game.

For `background`, collect examples with no object, your hand moving, the table, the room, and any messy normal view. This stops the model from guessing an object all the time.

You can swap the objects if you want. Pick three things that look different from each other and are easy for kids to hold up.

Good starter target: 30 to 50 examples per class. More is useful if the room lighting changes.

## Export

Use one of these:

- TensorFlow/Keras download, if Teachable Machine offers it for your project.
- TensorFlow Lite download, if that is the available Python-friendly export.

Put the exported files in this folder:

```text
examples/tensorflow-python-predict-examples/model/
```

The examples look for:

- `model/keras_model.h5` plus `model/labels.txt`, or
- `model/model.tflite` plus `model/labels.txt`.

## Install

```bash
cd examples/tensorflow-python-predict-examples
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run a Still Image

Put a test image in `sample_images/`, then run:

```bash
python3 predict_image.py sample_images/pencil-test.jpg
```

## Run the Webcam Game

```bash
python3 object_quest_game.py
```

Hold up the object shown on screen. Press `q` to quit.
