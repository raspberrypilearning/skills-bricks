let classifier;
let soundModel = "https://teachablemachine.withgoogle.com/models/8Mlr-KHPh/";

let palette = {
  red: {
    name: "red",
    label: "RED",
    fill: "#e53935",
    dark: "#981b1e",
    light: "#ffe1e1",
  },
  green: {
    name: "green",
    label: "GREEN",
    fill: "#2dbb63",
    dark: "#146c37",
    light: "#e4ffed",
  },
  blue: {
    name: "blue",
    label: "BLUE",
    fill: "#1e88e5",
    dark: "#0f4a90",
    light: "#e2f2ff",
  },
  noise: {
    name: "noise",
    label: "NOISE",
    fill: "#8a909c",
    dark: "#4d5260",
    light: "#f1f2f4",
  },
};

let colourNames = ["red", "green", "blue"];
let target = "red";
let heard = "listening...";
let confidence = 0;
let score = 0;
let streak = 0;
let bestStreak = 0;
let lives = 5;
let roundStartedAt = 0;
let roundDuration = 3600;
let inputCooldownUntil = 0;
let message = "READY";
let messageUntil = 0;
let gameState = "title";
let particles = [];
let pulse = 0;
let shake = 0;

function preload() {
  classifier = ml5.soundClassifier(soundModel + "model.json");
}

function setup() {
  let canvas = createCanvas(920, 600);
  canvas.parent("game-holder");
  textFont("Arial");
  classifier.classify(gotResult);
  resetGame();
}

function resetGame() {
  score = 0;
  streak = 0;
  bestStreak = 0;
  lives = 5;
  heard = "listening...";
  confidence = 0;
  message = "READY";
  messageUntil = millis() + 1200;
  particles = [];
  gameState = "playing";
  nextTarget();
}

function nextTarget() {
  let options = colourNames.filter((name) => name !== target);
  target = random(options);
  roundStartedAt = millis();
  roundDuration = max(1700, 3600 - score * 1.5);
}

function gotResult(error, results) {
  if (error) {
    console.error(error);
    return;
  }

  if (!results || !results.length) return;

  heard = normaliseLabel(results[0].label);
  confidence = results[0].confidence || results[0].probability || 0;

  if (gameState !== "playing") return;
  if (millis() < inputCooldownUntil) return;
  if (!colourNames.includes(heard)) return;
  if (confidence < 0.68) return;

  inputCooldownUntil = millis() + 650;

  if (heard === target) {
    scoreHit();
  } else {
    scoreMiss(heard.toUpperCase());
  }
}

function normaliseLabel(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/^_+|_+$/g, "")
    .replace(/_/g, " ");
}

function scoreHit() {
  let timeLeft = max(0, 1 - (millis() - roundStartedAt) / roundDuration);
  let points = 100 + streak * 25 + floor(timeLeft * 90);
  score += points;
  streak += 1;
  bestStreak = max(bestStreak, streak);
  pulse = 1;
  message = "+" + points;
  messageUntil = millis() + 650;
  burst(palette[target].fill, 34);
  nextTarget();
}

function scoreMiss(label) {
  lives -= 1;
  streak = 0;
  shake = 14;
  message = label + "?";
  messageUntil = millis() + 750;
  burst("#5f6071", 16);

  if (lives <= 0) {
    gameState = "gameover";
    message = "FINAL " + score;
    messageUntil = millis() + 999999;
  } else {
    nextTarget();
  }
}

function scoreTimeout() {
  lives -= 1;
  streak = 0;
  shake = 10;
  message = "TOO SLOW";
  messageUntil = millis() + 750;
  burst("#5f6071", 12);

  if (lives <= 0) {
    gameState = "gameover";
    message = "FINAL " + score;
    messageUntil = millis() + 999999;
  } else {
    nextTarget();
  }
}

function draw() {
  updateGame();
  drawScene();
}

function updateGame() {
  if (gameState === "playing" && millis() - roundStartedAt > roundDuration) {
    scoreTimeout();
  }

  pulse *= 0.88;
  shake *= 0.78;

  for (let i = particles.length - 1; i >= 0; i--) {
    particles[i].update();
    if (particles[i].life <= 0) particles.splice(i, 1);
  }
}

function drawScene() {
  let colour = palette[target];
  let offsetX = random(-shake, shake);
  let offsetY = random(-shake, shake);

  drawBackdrop(colour);

  push();
  translate(offsetX, offsetY);
  drawHud();
  drawTarget(colour);
  drawTimer();
  drawVoicePanel();
  drawParticles();
  drawMessage();
  drawGameOver();
  pop();
}

function drawBackdrop(colour) {
  let gradient = drawingContext.createLinearGradient(0, 0, width, height);
  gradient.addColorStop(0, colour.light);
  gradient.addColorStop(0.58, "#ffffff");
  gradient.addColorStop(1, colour.fill);
  drawingContext.fillStyle = gradient;
  drawingContext.fillRect(0, 0, width, height);

  noStroke();
  fill(255, 255, 255, 120);
  for (let i = 0; i < 10; i++) {
    let x = (i * 137 + frameCount * 0.35) % (width + 160) - 80;
    let y = 88 + (i % 5) * 96;
    ellipse(x, y, 84 + (i % 3) * 26, 84 + (i % 3) * 26);
  }
}

function drawHud() {
  fill(55, 56, 77);
  noStroke();
  textAlign(LEFT, CENTER);
  textSize(22);
  text("Score " + score, 34, 36);
  text("Streak " + streak, 34, 68);

  textAlign(RIGHT, CENTER);
  text("Lives " + "●".repeat(lives), width - 34, 36);
  text("Best " + bestStreak, width - 34, 68);
}

function drawTarget(colour) {
  let size = 210 + pulse * 52 + sin(frameCount * 0.08) * 5;

  noStroke();
  fill(255, 255, 255, 160);
  ellipse(width / 2, 255, size + 58, size + 58);
  fill(colour.fill);
  ellipse(width / 2, 255, size, size);
  fill(255, 255, 255, 65);
  arc(width / 2 - 24, 225, size * 0.62, size * 0.62, PI, TWO_PI);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(58);
  text(colour.label, width / 2, 255);
}

function drawTimer() {
  let progress = constrain(1 - (millis() - roundStartedAt) / roundDuration, 0, 1);
  let barWidth = 460;
  let x = width / 2 - barWidth / 2;
  let y = 438;

  noStroke();
  fill(255, 255, 255, 160);
  rect(x, y, barWidth, 16, 8);
  fill(55, 56, 77);
  rect(x, y, barWidth * progress, 16, 8);
}

function drawVoicePanel() {
  let heardColour = palette[heard] || palette.noise;
  let pct = floor(confidence * 100);

  fill(255, 255, 255, 178);
  stroke(216, 213, 242);
  strokeWeight(1);
  rect(width / 2 - 190, 474, 380, 72, 8);

  noStroke();
  fill(95, 96, 113);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("HEARD", width / 2 - 118, 495);

  fill(heardColour.fill);
  textSize(30);
  text(heard.toUpperCase(), width / 2, 518);

  fill(95, 96, 113);
  textSize(16);
  text(pct + "%", width / 2 + 136, 495);
}

function drawMessage() {
  if (millis() > messageUntil) return;

  fill(55, 56, 77, 230);
  textAlign(CENTER, CENTER);
  textSize(36 + pulse * 16);
  text(message, width / 2, 138);
}

function drawGameOver() {
  if (gameState !== "gameover") return;

  fill(255, 255, 255, 226);
  rect(240, 176, 440, 248, 8);

  fill(55, 56, 77);
  textAlign(CENTER, CENTER);
  textSize(42);
  text("Reactor cooled", width / 2, 238);
  textSize(28);
  text("Score " + score, width / 2, 298);
  textSize(18);
  text("Click to run again", width / 2, 354);
}

function drawParticles() {
  for (let particle of particles) {
    particle.draw();
  }
}

function burst(colour, count) {
  for (let i = 0; i < count; i++) {
    particles.push(new Spark(width / 2, 255, colour));
  }
}

function mousePressed() {
  if (gameState === "gameover") resetGame();
}

class Spark {
  constructor(x, y, colour) {
    this.x = x;
    this.y = y;
    this.vx = random(-5.5, 5.5);
    this.vy = random(-7, 3.5);
    this.size = random(5, 13);
    this.colour = colour;
    this.life = 1;
  }

  update() {
    this.x += this.vx;
    this.y += this.vy;
    this.vy += 0.18;
    this.life -= 0.025;
  }

  draw() {
    noStroke();
    let alpha = max(0, this.life) * 255;
    fill(red(this.colour), green(this.colour), blue(this.colour), alpha);
    rect(this.x, this.y, this.size, this.size, 2);
  }
}
