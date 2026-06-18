#!/usr/bin/env perl
# Regenerates app.html from the card data in index.html.
# Bakes in everything so a rebuild never loses features:
#   - platform picker with brand logos (app/logos/*.png)
#   - Code Club wallpaper (body class "app-bg")
#   - looping background music + mute button (app/workshop-song*.mp3)
# Card tiles are parsed from index.html so the two stay in sync.
# Run:  perl build-app.pl
use strict;
use warnings;

my %sec = (
  'current-bricks'   => ['pipico',   "Pete's Pi & Pico"],
  'compare-bricks'   => ['pipico',   "MrC's Pi & Pico"],
  'microbit-builtin' => ['microbit', "Built-in"],
  'microbit-addon'   => ['microbit', "Add-on components"],
  'microbit-connect' => ['microbit', "Connections & reference"],
  'arduino-sensors'  => ['arduino',  "Sensors & inputs"],
  'arduino-outputs'  => ['arduino',  "Outputs"],
  'arduino-connect'  => ['arduino',  "Connections & reference"],
);

open my $fh, '<', 'index.html' or die "open index.html: $!";
local $/;
my $html = <$fh>;
close $fh;

sub jsstr { my $s = shift // ''; $s =~ s/\\/\\\\/g; $s =~ s/"/\\"/g; return "\"$s\""; }

my @objs;
while ($html =~ m{<section class="index-section"[^>]*aria-labelledby="([^"]+)"[^>]*>(.*?)</section>}gs) {
  my ($id, $body) = ($1, $2);
  next unless exists $sec{$id};
  my ($platform, $group) = @{ $sec{$id} };
  while ($body =~ m{<a class="brick-card theme-(do|detect)" href="([^"]+)">(.*?)</a>}gs) {
    my ($theme, $href, $inner) = ($1, $2, $3);
    my ($hero)  = $inner =~ m{class="brick-hero(?: only)?" src="([^"]+)"};
    my ($scene) = $inner =~ m{class="brick-scene" src="([^"]+)"};
    my ($title) = $inner =~ m{<h2>(.*?)</h2>}s;
    my ($desc)  = $inner =~ m{<p>(.*?)</p>}s;
    my @tags    = $inner =~ m{<span class="tag">(.*?)</span>}gs;
    push @objs, sprintf(
      '  { platform:%s, group:%s, theme:%s, href:%s, hero:%s, scene:%s, title:%s, desc:%s, tag1:%s, tag2:%s }',
      jsstr($platform), jsstr($group), jsstr($theme), jsstr($href),
      jsstr($hero), jsstr($scene), jsstr($title), jsstr($desc),
      jsstr($tags[0]), jsstr($tags[1]));
  }
}
my $cards_js = "[\n" . join(",\n", @objs) . "\n]";

my $page = <<'HTML';
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Skill Bricks — choose your device</title>
  <link rel="stylesheet" href="skill-brick.css" />
</head>
<body class="theme-detect index-body app-bg">
  <button id="muteBtn" class="audio-toggle" type="button" aria-pressed="false" aria-label="Mute music" title="Mute music">🔊</button>
  <audio id="bgm" preload="auto"></audio>

  <main class="index-shell">
    <header class="index-header">
      <h1>Skill Bricks</h1>
      <p id="app-subtitle">Which device are you using?</p>
    </header>

    <div class="platform-picker" id="picker">
      <button class="platform-choice platform-pi" type="button" data-platform="pi">
        <img class="platform-logo" src="app/logos/raspberry-pi.png" alt="" />
        <span class="platform-name">Raspberry Pi</span>
        <span class="platform-sub">The full Raspberry Pi computer with GPIO pins.</span>
      </button>
      <button class="platform-choice platform-pico" type="button" data-platform="pico">
        <img class="platform-logo" src="app/logos/raspberry-pi.png" alt="" />
        <span class="platform-name">Raspberry Pi Pico</span>
        <span class="platform-sub">The tiny Pico microcontroller board.</span>
      </button>
      <button class="platform-choice platform-microbit" type="button" data-platform="microbit">
        <img class="platform-logo" src="app/logos/microbit.png" alt="" />
        <span class="platform-name">micro:bit</span>
        <span class="platform-sub">The BBC micro:bit with built-in sensors.</span>
      </button>
      <button class="platform-choice platform-arduino" type="button" data-platform="arduino">
        <img class="platform-logo" src="app/logos/arduino.png" alt="" />
        <span class="platform-name">Arduino</span>
        <span class="platform-sub">An Arduino board wired up with header pins.</span>
      </button>
    </div>

    <div id="results" hidden>
      <button id="changeBtn" class="change-platform" type="button">← Change device</button>
      <div id="sections"></div>
    </div>
  </main>

  <script>
    const CARDS = __CARDS__;
    const GROUP_ORDER = {
      pipico: ["Pete's Pi & Pico", "MrC's Pi & Pico"],
      microbit: ["Built-in", "Add-on components", "Connections & reference"],
      arduino: ["Sensors & inputs", "Outputs", "Connections & reference"]
    };
    const PLATFORM_LABEL = { pi: "Raspberry Pi", pico: "Raspberry Pi Pico", microbit: "micro:bit", arduino: "Arduino" };

    const picker = document.getElementById('picker');
    const results = document.getElementById('results');
    const sectionsEl = document.getElementById('sections');
    const subtitle = document.getElementById('app-subtitle');

    function cardHTML(c) {
      let v;
      if (c.hero && c.scene) {
        v = `<div class="brick-card-visual"><img class="brick-hero" src="${c.hero}" alt="" loading="lazy" /><img class="brick-scene" src="${c.scene}" alt="" loading="lazy" /></div>`;
      } else if (c.hero) {
        v = `<div class="brick-card-visual"><img class="brick-hero only" src="${c.hero}" alt="" loading="lazy" /></div>`;
      } else {
        v = `<div class="brick-card-visual" aria-hidden="true"></div>`;
      }
      return `<a class="brick-card theme-${c.theme}" href="${c.href}">${v}<div class="brick-card-content"><h2>${c.title}</h2><p>${c.desc}</p></div><div class="brick-card-footer"><span class="tag">${c.tag1}</span><span class="tag">${c.tag2}</span></div></a>`;
    }

    function show(platform) {
      const dp = (platform === 'pi' || platform === 'pico') ? 'pipico' : platform;
      let html = '';
      for (const g of GROUP_ORDER[dp]) {
        const cards = CARDS.filter(c => c.platform === dp && c.group === g);
        if (!cards.length) continue;
        html += `<section class="app-group"><h2 class="app-group-title">${g}</h2><div class="brick-grid">${cards.map(cardHTML).join('')}</div></section>`;
      }
      sectionsEl.innerHTML = html;
      subtitle.textContent = dp === 'pipico'
        ? `${PLATFORM_LABEL[platform]} bricks — each one includes both Pi and Pico code`
        : `${PLATFORM_LABEL[platform]} bricks`;
      picker.hidden = true;
      results.hidden = false;
      if (location.hash !== '#' + platform) location.hash = platform;
      window.scrollTo(0, 0);
    }

    function reset() {
      results.hidden = true;
      picker.hidden = false;
      subtitle.textContent = 'Which device are you using?';
      if (location.hash) history.replaceState(null, '', location.pathname);
      window.scrollTo(0, 0);
    }

    document.querySelectorAll('.platform-choice').forEach(function (b) {
      b.addEventListener('click', function () { show(b.dataset.platform); });
    });
    document.getElementById('changeBtn').addEventListener('click', reset);

    const initial = location.hash.replace('#', '');
    if (['pi', 'pico', 'microbit', 'arduino'].includes(initial)) show(initial);

    // ---- background music: two-track looping playlist + mute ----
    (function () {
      const tracks = ['app/workshop-song1.mp3', 'app/workshop-song2.mp3'];
      let t = 0;
      const audio = document.getElementById('bgm');
      const btn = document.getElementById('muteBtn');
      audio.src = tracks[t];
      audio.addEventListener('ended', function () {
        t = (t + 1) % tracks.length;
        audio.src = tracks[t];
        audio.play().catch(function () {});
      });
      audio.play().catch(function () {
        const start = function () {
          audio.play().catch(function () {});
          document.removeEventListener('pointerdown', start);
          document.removeEventListener('keydown', start);
        };
        document.addEventListener('pointerdown', start);
        document.addEventListener('keydown', start);
      });
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        audio.muted = !audio.muted;
        btn.textContent = audio.muted ? '🔇' : '🔊';
        btn.setAttribute('aria-pressed', String(audio.muted));
        btn.setAttribute('aria-label', audio.muted ? 'Unmute music' : 'Mute music');
        btn.setAttribute('title', audio.muted ? 'Unmute music' : 'Mute music');
        if (!audio.muted && audio.paused) audio.play().catch(function () {});
      });
    })();
  </script>
</body>
</html>
HTML

$page =~ s/__CARDS__/$cards_js/;

open my $out, '>', 'app.html' or die "write app.html: $!";
print $out $page;
close $out;
print "wrote app.html with " . scalar(@objs) . " cards (logos + wallpaper + music baked in)\n";
