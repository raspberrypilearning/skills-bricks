let classifier;
let label = "listening...";

let soundModel = "https://teachablemachine.withgoogle.com/models/8Mlr-KHPh/";

let colours = {
  red: {
    text: "#c62828",
    light: "#fff1f1",
    dark: "#ff6b6b",
  },
  green: {
    text: "#1b8f3a",
    light: "#effff3",
    dark: "#5ad67d",
  },
  blue: {
    text: "#1565c0",
    light: "#eef6ff",
    dark: "#5da9ff",
  },
  "background noise": {
    text: "#5f6071",
    light: "#f2f3f5",
    dark: "#b9bdc7",
  },
  background_noise: {
    text: "#5f6071",
    light: "#f2f3f5",
    dark: "#b9bdc7",
  },
  "_background_noise_": {
    text: "#5f6071",
    light: "#f2f3f5",
    dark: "#b9bdc7",
  },
  "listening...": {
    text: "#5f6071",
    light: "#f2f3f5",
    dark: "#b9bdc7",
  },
};

function preload() {
  classifier = ml5.soundClassifier(soundModel + "model.json");
}

function setup() {
  let canvas = createCanvas(650, 450);
  canvas.parent("sketch-holder");
  classifier.classify(gotResult);
}

function drawGradient(colour) {
  let gradient = drawingContext.createLinearGradient(0, 0, width, height);
  gradient.addColorStop(0, colour.light);
  gradient.addColorStop(1, colour.dark);

  drawingContext.fillStyle = gradient;
  drawingContext.fillRect(0, 0, width, height);
}

function draw() {
  let colour = colours[label] || colours["background noise"];

  drawGradient(colour);

  fill(55);
  textAlign(CENTER, CENTER);
  textSize(28);
  text("Say red, green, or blue", width / 2, 70);

  fill(colour.text);
  textSize(72);
  text(label, width / 2, height / 2);
}

function gotResult(error, results) {
  if (error) {
    console.error(error);
    return;
  }

  console.log(results[0]);
  label = results[0].label.toLowerCase();
}
