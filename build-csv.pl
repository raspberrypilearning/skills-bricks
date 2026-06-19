#!/usr/bin/env perl
# Extracts the copy from every skill-brick card into skill-bricks-content.csv.
# Prose + code only (HTML stripped, entities decoded); image files are NOT
# embedded — instead each image a card uses is given as a GitHub blob URL.
# Run:  perl build-csv.pl
use strict;
use warnings;

my $BASE = "https://github.com/raspberrypilearning/skills-bricks/blob/master/";

sub dent {
  my $s = shift // '';
  $s =~ s/&nbsp;/ /g;
  $s =~ s/&rarr;/chr(0x2192)/ge;
  $s =~ s/&larr;/chr(0x2190)/ge;
  $s =~ s/&minus;/chr(0x2212)/ge;
  $s =~ s/&ndash;/chr(0x2013)/ge;
  $s =~ s/&mdash;/chr(0x2014)/ge;
  $s =~ s/&deg;/chr(0xB0)/ge;
  $s =~ s/&sup2;/chr(0xB2)/ge;
  $s =~ s/&times;/chr(0xD7)/ge;
  $s =~ s/&#x([0-9a-fA-F]+);/chr(hex($1))/ge;
  $s =~ s/&#(\d+);/chr($1)/ge;
  $s =~ s/&lt;/</g; $s =~ s/&gt;/>/g;
  $s =~ s/&quot;/chr(34)/ge; $s =~ s/&#39;/chr(39)/ge;
  $s =~ s/&amp;/&/g;
  return $s;
}
sub prose {
  my $s = shift // '';
  $s =~ s/<[^>]+>/ /g; $s = dent($s);
  $s =~ s/\s+/ /g; $s =~ s/^\s+|\s+$//g;
  return $s;
}
sub cq { my $s = shift // ''; $s =~ s/"/""/g; return "\"$s\""; }

# resolve a relative img path against the card's folder -> repo path
sub resolve {
  my ($dir, $ref) = @_;
  my @parts = split m{/}, "$dir/$ref";
  my @out;
  for my $p (@parts) { next if $p eq '' || $p eq '.'; $p eq '..' ? pop @out : push @out, $p; }
  return join("/", @out);
}
# turn the img/image refs found in an HTML fragment into GitHub URLs (existing files only)
sub img_urls {
  my ($dir, $frag) = @_;
  my @refs = ($frag =~ /<img[^>]+src="([^"]+)"/g, $frag =~ /<image[^>]+href="([^"]+)"/g);
  my @urls;
  for my $r (@refs) {
    next if $r =~ /^https?:/;
    my $p = resolve($dir, $r);
    push @urls, $BASE . $p if -f $p;
  }
  return join(" | ", @urls);
}

my @cols = qw(platform set component tags description
  use1_title use1_detect use1_decide use1_do use1_image_url
  use2_title use2_detect use2_decide use2_do use2_image_url
  parts component_image_url
  code1_label code1 code2_label code2 code3_label code3
  note wiring wiring_image_url quick_reference github_url);

my @files = (
  glob("microbit/*/*.html"), glob("arduino/*/*.html"), glob("*-Pete/*.html"),
  "LED/led-skill-brick.html", "UDS/ultrasonic-distance-sensor.html",
  "LDR/ldr-skill-brick.html", "PIR/pir-skill-brick.html",
  "Piezo_Buzzer/piezo-buzzer-skill-brick.html",
);

open my $out, '>:encoding(UTF-8)', 'skill-bricks-content.csv' or die "csv: $!";
print $out join(",", @cols), "\n";
my $n = 0;

for my $f (sort @files) {
  next unless -f $f;
  (my $dir = $f) =~ s{/[^/]+$}{};
  open my $fh, '<:encoding(UTF-8)', $f or next; local $/; my $h = <$fh>; close $fh;

  my ($plat, $set);
  if    ($f =~ m{^microbit/}) { $plat = "micro:bit"; $set = ""; }
  elsif ($f =~ m{^arduino/})  { $plat = "Arduino";   $set = ""; }
  else { $plat = "Raspberry Pi / Pico"; $set = ($f =~ /-Pete\//) ? "Pete" : "MrC"; }
  $set = "Pete (example)" if $f =~ m{^Skills_Brick_Example-Pete/};

  my ($title) = $h =~ /<h1>(.*?)<\/h1>/s; $title = prose($title);

  my $tags = "";
  if ($h =~ /<div class="tags"[^>]*>(.*?)<\/div>/s) {
    my @tg = $1 =~ /<span class="tag">(.*?)<\/span>/gs; $tags = join(", ", map { prose($_) } @tg);
  }

  my $desc = "";
  if ($h =~ /<section class="description">(.*?)<\/section>/s) {
    my @p = $1 =~ /<p>(.*?)<\/p>/gs; $desc = join("\n", map { prose($_) } @p);
  }

  my @uses;
  while ($h =~ /<article class="use-card">(.*?)<\/article>/gs) {
    my $u = $1;
    my ($ut) = $u =~ /<div class="use-title">(.*?)<\/div>/s;
    my @fs = $u =~ /<div class="flow-step[^"]*"><strong>[^<]*<\/strong>(.*?)<\/div>/gs;
    @fs = map { prose($_) } @fs;
    push @uses, [prose($ut), $fs[0]//'', $fs[1]//'', $fs[2]//'', img_urls($dir, $u)];
  }
  my @u1 = @{ $uses[0] // ['','','','',''] };
  my @u2 = @{ $uses[1] // ['','','','',''] };

  my @pb = $h =~ /<div class="(?:part|pin)"><strong>(.*?)<\/strong><span>(.*?)<\/span><\/div>/gs;
  my @pp; for (my $i=0; $i+1<=$#pb; $i+=2) { push @pp, prose($pb[$i]).": ".prose($pb[$i+1]); }
  my $parts = join("; ", @pp);

  my $comp_img = ($h =~ /<aside class="panel (?:component-panel|sensor-panel)">(.*?)<\/aside>/s) ? img_urls($dir, $1) : "";
  my $wir_img  = ($h =~ /<aside class="panel wiring-panel">(.*?)<\/aside>/s) ? img_urls($dir, $1) : "";

  my @code;
  while ($h =~ /<h2>([^<]+)<\/h2>\s*<pre><code>(.*?)<\/code><\/pre>/gs) { push @code, [prose($1), dent($2)]; }
  my @c1=@{$code[0]//['','']}; my @c2=@{$code[1]//['','']}; my @c3=@{$code[2]//['','']};

  my ($note) = $h =~ /<div class="note">(.*?)<\/div>/s; $note = prose($note);
  my @pn = $h =~ /<div class="pin-note">(.*?)<\/div>/gs; my $wiring = join(" | ", map { prose($_) } @pn);
  my @ri = $h =~ /<div class="ref-item"><strong>(.*?)<\/strong><span>(.*?)<\/span><\/div>/gs;
  my @rr; for (my $i=0; $i+1<=$#ri; $i+=2) { push @rr, prose($ri[$i]).": ".prose($ri[$i+1]); }
  my $qr = join("; ", @rr);

  my @row = ($plat, $set, $title, $tags, $desc,
    @u1, @u2, $parts, $comp_img,
    $c1[0],$c1[1], $c2[0],$c2[1], $c3[0],$c3[1],
    $note, $wiring, $wir_img, $qr, $BASE.$f);
  print $out join(",", map { cq($_) } @row), "\n";
  $n++;
}
close $out;
print "wrote skill-bricks-content.csv with $n rows\n";
