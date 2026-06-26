import random
import time
from dataclasses import dataclass

import cv2
from PIL import Image

from tm_model import TeachableMachineModel


OBJECTS = {
    "pencil": (70, 170, 245),
    "cup": (90, 185, 95),
    "book": (220, 110, 170),
    "background": (150, 150, 150),
}

TARGETS = ("pencil", "cup", "book")


@dataclass
class GameState:
    target: str = "pencil"
    score: int = 0
    streak: int = 0
    best_streak: int = 0
    lives: int = 5
    round_started_at: float = 0.0
    round_duration: float = 4.0
    message: str = "Ready"
    message_until: float = 0.0
    cooldown_until: float = 0.0
    game_over: bool = False


def choose_next_target(current):
    choices = [name for name in TARGETS if name != current]
    return random.choice(choices)


def start_round(state):
    state.target = choose_next_target(state.target)
    state.round_started_at = time.time()
    state.round_duration = max(2.0, 4.0 - state.score * 0.0015)


def reset_game():
    state = GameState()
    start_round(state)
    return state


def score_hit(state):
    elapsed = time.time() - state.round_started_at
    speed_bonus = max(0, int((state.round_duration - elapsed) * 35))
    points = 100 + state.streak * 25 + speed_bonus
    state.score += points
    state.streak += 1
    state.best_streak = max(state.best_streak, state.streak)
    state.message = f"+{points}"
    state.message_until = time.time() + 0.75
    state.cooldown_until = time.time() + 0.65
    start_round(state)


def score_miss(state, label):
    state.lives -= 1
    state.streak = 0
    state.message = f"{label}?"
    state.message_until = time.time() + 0.9
    state.cooldown_until = time.time() + 0.75

    if state.lives <= 0:
        state.game_over = True
        state.message = f"Final score {state.score}"
    else:
        start_round(state)


def draw_panel(frame, state, label, confidence):
    height, width = frame.shape[:2]
    accent = OBJECTS.get(state.target, OBJECTS["background"])

    cv2.rectangle(frame, (0, 0), (width, 118), (255, 255, 255), -1)
    cv2.putText(frame, f"Score {state.score}", (24, 38), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (55, 56, 77), 2)
    cv2.putText(frame, f"Streak {state.streak}", (24, 78), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (55, 56, 77), 2)
    cv2.putText(frame, f"Lives {state.lives}", (width - 150, 38), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (55, 56, 77), 2)
    cv2.putText(frame, f"Best {state.best_streak}", (width - 150, 78), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (55, 56, 77), 2)

    cv2.rectangle(frame, (width // 2 - 170, 165), (width // 2 + 170, 335), accent, -1)
    cv2.rectangle(frame, (width // 2 - 155, 180), (width // 2 + 155, 320), (255, 255, 255), -1)
    cv2.putText(frame, "SHOW ME", (width // 2 - 110, 225), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (55, 56, 77), 3)
    cv2.putText(frame, state.target.upper(), (width // 2 - 120, 285), cv2.FONT_HERSHEY_SIMPLEX, 1.7, accent, 4)

    remaining = max(0, 1 - (time.time() - state.round_started_at) / state.round_duration)
    bar_width = int((width - 160) * remaining)
    cv2.rectangle(frame, (80, height - 86), (width - 80, height - 66), (235, 235, 235), -1)
    cv2.rectangle(frame, (80, height - 86), (80 + bar_width, height - 66), (55, 56, 77), -1)

    heard_accent = OBJECTS.get(label, OBJECTS["background"])
    cv2.rectangle(frame, (80, height - 58), (width - 80, height - 18), (255, 255, 255), -1)
    cv2.putText(
        frame,
        f"Saw {label}  {confidence:.0%}",
        (98, height - 30),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        heard_accent,
        2,
    )

    if time.time() < state.message_until or state.game_over:
        cv2.putText(frame, state.message, (width // 2 - 120, 150), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (55, 56, 77), 3)

    if state.game_over:
        cv2.rectangle(frame, (120, 170), (width - 120, height - 130), (255, 255, 255), -1)
        cv2.putText(frame, "Quest complete", (width // 2 - 150, 250), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (55, 56, 77), 3)
        cv2.putText(frame, "Press r to restart or q to quit", (width // 2 - 210, 310), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (55, 56, 77), 2)


def main():
    model = TeachableMachineModel("model")
    camera = cv2.VideoCapture(0)

    if not camera.isOpened():
        raise RuntimeError("Could not open the camera.")

    state = reset_game()
    label = "background"
    confidence = 0.0

    while True:
        ok, frame = camera.read()
        if not ok:
            break

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        label, confidence, _ = model.predict_image(Image.fromarray(rgb_frame))
        label = label.strip().lower()

        now = time.time()
        if not state.game_over and now - state.round_started_at > state.round_duration:
            score_miss(state, "slow")

        if not state.game_over and now >= state.cooldown_until and confidence >= 0.72:
            if label == state.target:
                score_hit(state)
            elif label in TARGETS:
                score_miss(state, label)

        draw_panel(frame, state, label, confidence)
        cv2.imshow("Object Quest - TensorFlow Python", frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord("q"):
            break
        if key == ord("r"):
            state = reset_game()

    camera.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
