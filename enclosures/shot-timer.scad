// Gehäuse für das Waveshare ESP32-S3-Touch-LCD-1.28 (shot-timer.yaml),
// links seitlich an einer Quick Mill Orione 03000, Front zeigt nach vorne.
// Idee wie beim "Espresso Coffee Shot Timer RP2040" von DaniilKrant auf
// MakerWorld, aber geklemmt statt Magnet, weil das Edelstahlgehäuse nicht
// magnetisch ist.
//
// Zwei Teile:
// - stand: Gehäusering, Arm, Stütze und Clip in einem Stück. Der Clip ist ein
//   U, das von oben auf den Rand der Tassenablage geschoben wird: die Stütze
//   liegt plan außen an der Seitenwand, der innere Schenkel klemmt den Rand von
//   innen. Die Stütze verhindert, dass der Clip unter dem Gewicht kippt. Der Arm ist ein geschlossener Kanal für USB-C-Stecker und Kabel.
//   Am Ende geht er durch die Stütze, dort führt ein Schlitz das Kabel nach
//   hinten. Gedruckt wird mit der Front nach unten, so liegen Display-Blende,
//   Arm und Stütze flach auf dem Bett, das U des Clips steht senkrecht und
//   die Rückwand des Kanals wird überbrückt. In der Stütze läuft der Kanal
//   oben unter 45° zum Schlitz zusammen, damit dort nichts frei überhängt.
// - cover: Rückdeckel, wird eingepresst und drückt das Board über drei Stege
//   nach vorne. Wird mit der Rückseite nach unten gedruckt.
//
// Das Board ist um 90° gedreht eingebaut, USB-C zeigt zur Maschine. Das Bild
// muss in der Firmware entsprechend gedreht werden.
//
// Zusammenbau: Stecker von der Seitenwand-Seite durch die Stütze und den Arm
// fädeln, bis er im Ring herauskommt, ins Board stecken, Board von hinten
// einlegen, Kabel in den Schlitz der Stütze drücken, Deckel einpressen.
//
// Koordinaten im eingebauten Zustand: y nach oben, z nach hinten, x zeigt
// von vorne gesehen nach links. Die Maschine liegt also bei -x, alles auf
// ihrer Seite (Arm, Stütze, Clip) wird mit side() gespiegelt und dort mit
// positiven Abständen gebaut. Displayfront bei z = 0, Displaymitte bei
// x = y = 0. Maße des Boards aus der Waveshare-Zeichnung
// (ESP32-S3-Touch-LCD-1.28.dxf).

// Standard ist die Druckplatte, damit ein Export direkt druckbar ist.
part = "print"; // [print, assembly, stand, cover]

/* [Position, bitte an der Maschine nachmessen] */
// Displaymitte bis Außenseite der Seitenwand
arm_len = 55;
// Dicke des Rands der Tassenablage, mit Probeklammern ermittelt (2,3 sitzt stramm)
rim_d = 2.3;
// Klemmung: so viel enger als rim_d wird das U gedruckt
rim_squeeze = 0.2;
// Höhe der Oberkante des Rands über der Displaymitte
rim_above = 35;
// innerer Schenkel des U, unter der Mitte der Rundung gemessen
rim_inner = 6;
// Beim ersten Druck stand die Stütze unten (Unterkante Arm) rund 3 mm von der
// Wand ab. Das U wird um so viel schräg gestellt, dass die Stütze unten anliegt,
// plus etwas Vorspannung, damit nichts wackelt.
rim_gap = 3;
rim_preload = 0.5;
// Oben hat der Rand einen leichten Wulst: die Rundung des U ist um so viel
// größer, darunter klemmt das U wieder mit der normalen Weite
rim_bead = 0.3;
// Länge von Steckergehäuse plus Knickschutz des USB-Kabels
plug_len = 28;
// Breite des Kabelschlitzes in der Stütze, etwas weniger als das Kabel klemmt es
cable_w = 4;
// lichte Höhe zum Durchfädeln des Steckers in der Stütze, nach vorne gemessen
plug_h = 8.5;

/* [Board] */
lens_d = 38.51;        // Linse = Platinenumriss
view_d = 35.0;         // Sichtöffnung, aktive Fläche ist Ø 33,4
usb_bottom = 21.78;    // Außenkante USB-C ab Displaymitte
tab_w = 14.8;          // Platinenzunge, auf der USB-C sitzt
tab_bottom = 19.4;
stack = 8.4;           // Linsenfront bis höchstes Bauteil hinten
pcb_back = 5.0;        // Linsenfront bis Platinenrückseite
board_rot = -90;       // USB-C (im Datenblatt unten) zeigt zur Maschine

/* [Gehäuse] */
clr = 0.3;             // Spiel rund ums Board
wall = 2;
lip = 1.2;             // Stärke der Frontblende
cover_t = 2;
cover_lip_h = 1.5;     // so tief steckt der Deckel im Gehäuse
cover_lip_w = 1.2;
// Rastnase an den Stegen des Deckels, 0 = nur Presssitz. Abzüglich 0,1 mm Luft
// zur Ringwand greift sie 0,5 mm in die Rille. Die Stege sind dafür dünn, damit
// sie beim Einrasten nur etwa 3 % gedehnt werden.
snap = 0.6;
snap_w = 4;            // Breite der Stege mit Rastnase
peg_t = 1;             // radiale Stärke der Stege
ring_lead = 0.6;       // Fase innen an der Hinterkante des Rings zum Einsetzen
pry = [6, 1];          // Kerbe am Deckelrand zum Aufhebeln (Breite, Tiefe)
press = 0.1;           // Übermaß weg vom Spiel für den Presssitz

/* [Arm und Clip] */
ch_h = 13.5;           // lichte Höhe des Kabelkanals, passt für Steckergehäuse bis ~13 mm
ch_front = 2;          // Vorderwand des Kanals
ch_wall = 2;
leg_t = 4.5;           // Stütze an der Seitenwand
hook_t = 3.5;          // Wand von Rundung und innerem Schenkel
lead_in = 0.8;         // Fase innen unten am inneren Schenkel zum Aufschieben

/* [Form] */
arm_root = 26;         // Höhe des Arms am Ring, verjüngt sich bis zur Stütze
fillet = 6;            // Hohlkehlen zwischen Ring, Arm und Stütze
round = 1;             // Rundung der Außenecken im Profil
edge = 0.8;            // Fase an Vorder- und Hinterkante, 45° und damit ohne Support druckbar

$fa = 4;
$fs = 0.4;

inner_d = lip + stack + 0.5 + cover_lip_h; // Innentiefe des Rings
cover_z = inner_d;
ch_d = cover_z + cover_t;                   // Rückwand des Kanals fluchtet mit dem Deckel
// Stütze und Clip sind tiefer als der Arm, damit über dem Durchgang für den
// Stecker Platz für die 45°-Schrägen zum Kabelschlitz bleibt
pass_top = ch_front + plug_h;
leg_w = max(ch_d, pass_top + (ch_h - cable_w) / 2 + 2);
leg_x = arm_len - leg_t;
rim_w = rim_d - rim_squeeze;                // lichte Weite des U
rim_r = rim_w / 2;
rim_x = arm_len + rim_r;                    // Mitte der Rundung, die Außenwand ist plan
rim_y = rim_above - rim_r;
// Neigung des U gegenüber der Stütze, gedreht um die Oberkante an der Wand
rim_tilt = atan((rim_gap + rim_preload) / (rim_above - (-ch_h / 2 - ch_wall)));
rim_pivot = [arm_len, rim_above];
// höchster Punkt der Rastnase, knapp hinter der Stegspitze (lip + pcb_back)
snap_z = lip + pcb_back + 0.6;
ch_bottom = -ch_h / 2 - ch_wall;

assert(rim_y - rim_inner > ch_h / 2 + ch_wall, "Rand zu niedrig für den Arm, rim_above vergrößern");
if (usb_bottom + plug_len > leg_x)
  echo(str("WARNUNG: Stecker reicht bis x = ", usb_bottom + plug_len, ", die Stütze beginnt bei x = ",
    leg_x, ". arm_len vergrößern oder einen Winkelstecker nehmen."));

// Board-Umriss mit Zunge für USB-C, als konvexe Hülle
module cavity2d(extra = 0) {
  offset(r = clr + extra) rotate(board_rot) hull() {
    circle(d = lens_d);
    translate([-tab_w / 2, -tab_bottom]) square([tab_w, 1]);
    translate([-4.6, -usb_bottom]) square([9.2, 1]);
  }
}

module outline2d() {
  offset(r = wall) cavity2d();
}

// Spiegelt auf die Maschinenseite
module side() {
  mirror([1, 0, 0]) children();
}

// Kabelkanal von kurz vor der Buchse bis zur Stütze. Er reicht hinten bis zum
// Deckel, im Ring ist er dadurch nach hinten offen und der Stecker lässt sich
// mit dem Board von hinten einlegen. Schneidet auch den Deckelrand.
module channel() {
  x0 = usb_bottom - 3;
  side() translate([x0, -ch_h / 2, ch_front]) cube([leg_x + 0.01 - x0, ch_h, cover_z - ch_front]);
}

// Schlitz in der Stütze, führt das Kabel aus dem Kanal nach hinten
// Durchgang durch die Stütze: unten so hoch, dass der Stecker durchpasst,
// darüber unter 45° zum Kabelschlitz verengt, der nach hinten offen ist. Im
// Druck sind die Schrägen 45°-Überhänge, keine freien Zungen.
module cable_slot() {
  side() translate([leg_x, 0, 0]) rotate([90, 0, 90]) linear_extrude(leg_t + 1)
    polygon([
      [-ch_h / 2, ch_front], [ch_h / 2, ch_front], [ch_h / 2, pass_top],
      [cable_w / 2, pass_top + (ch_h - cable_w) / 2], [cable_w / 2, leg_w + 1],
      [-cable_w / 2, leg_w + 1], [-cable_w / 2, pass_top + (ch_h - cable_w) / 2],
      [-ch_h / 2, pass_top],
    ]);
}

// Dreht das U um seine Oberkante an der Wand, siehe rim_tilt
module rim_rotate() {
  translate(rim_pivot) rotate(-rim_tilt) translate(-rim_pivot) children();
}

// Umriss des ganzen Stands von vorne: Ring, sich verjüngender Arm und Stütze
// gehen über Hohlkehlen ineinander über. Oben sitzt das U über dem Rand, mit
// runder Kappe von der Stütze bis über den inneren Schenkel. Das U ist um
// rim_tilt gegen die Stütze geneigt, an der Wandseite entsteht dadurch oben
// eine flache Aussparung.
module profile2d() {
  r_out = rim_r + hook_t;
  offset(r = 0.5) offset(r = -0.5) difference() {
    offset(r = round) offset(r = -round) union() {
      offset(r = -fillet) offset(r = fillet) union() {
        outline2d();
        side() polygon([[0, -arm_root / 2], [leg_x, ch_bottom], [leg_x, -ch_bottom], [0, arm_root / 2]]);
        side() translate([leg_x, ch_bottom]) square([leg_t, rim_y - ch_bottom]);
      }
      side() rim_rotate() {
        hull() {
          translate([leg_x + r_out, rim_y]) circle(r = r_out);
          translate([rim_x, rim_y]) circle(r = r_out);
        }
        // innerer Schenkel
        translate([arm_len + rim_w, rim_y - rim_inner]) square([hook_t, rim_inner]);
      }
    }
    side() rim_rotate() {
      // lichte Weite des U, unten offen bis knapp unter den inneren Schenkel
      translate([rim_x, rim_y]) circle(r = rim_r);
      // Platz für den Wulst, Scheitel bleibt auf gleicher Höhe
      translate([rim_x, rim_y - rim_bead]) circle(r = rim_r + rim_bead);
      translate([arm_len, rim_y - rim_inner - 1]) square([rim_w, rim_inner + 1]);
      // Einführschräge
      translate([arm_len + rim_w, rim_y - rim_inner])
        polygon([[0, -0.01], [lead_in, -0.01], [0, lead_in]]);
    }
  }
}

// Extrudiert mit einer 45°-Fase an Vorder- und Hinterkante, in Stufen von
// edge / 4, das ist etwa eine Druckschicht
module edge_extrude(h, front = true, back = true) {
  n = 4;
  for (i = [0 : n - 1]) {
    inset = edge * (n - i) / n;
    if (front)
      translate([0, 0, i * edge / n]) linear_extrude(edge / n + 0.01) offset(delta = -inset) children();
    if (back)
      translate([0, 0, h - (i + 1) * edge / n]) linear_extrude(edge / n + 0.01) offset(delta = -inset) children();
  }
  z0 = front ? edge : 0;
  translate([0, 0, z0]) linear_extrude(h - z0 - (back ? edge : 0) + 0.01) children();
}

module stand() {
  difference() {
    union() {
      edge_extrude(ch_d) profile2d();
      // Stütze und Clip tiefer
      edge_extrude(leg_w) intersection() {
        profile2d();
        side() translate([leg_x, -100]) square(200);
      }
    }
    // hinter dem Ring sitzt der Deckel
    translate([0, 0, inner_d]) linear_extrude(ch_d) offset(r = 0.01) outline2d();
    translate([0, 0, lip]) linear_extrude(inner_d) cavity2d();
    // Sichtöffnung mit 45°-Fase nach vorne
    translate([0, 0, -0.01]) cylinder(d1 = view_d + 2 * lip, d2 = view_d, h = lip + 0.02);
    channel();
    cable_slot();
    // Rille für die Rastnasen des Deckels
    if (snap > 0)
      translate([0, 0, snap_z - 0.65]) linear_extrude(1.15) cavity2d(snap + 0.15);
    // Einführfase für den Deckel
    hull() {
      translate([0, 0, inner_d - ring_lead]) linear_extrude(0.01) cavity2d();
      translate([0, 0, inner_d]) linear_extrude(0.01) cavity2d(ring_lead);
    }
  }
}

module cover() {
  difference() {
    union() {
      translate([0, 0, cover_z]) edge_extrude(cover_t, front = false) outline2d();
      // Presssitz-Kragen, an den Stegen ausgespart, damit sie bis zur
      // Deckelplatte frei federn
      translate([0, 0, cover_z - cover_lip_h]) linear_extrude(cover_lip_h + 0.01) difference() {
        cavity2d(-press);
        cavity2d(-press - cover_lip_w);
        for (a = peg_angles)
          rotate(board_rot + a) translate([0, -(snap_w / 2 + 0.6)]) square([30, snap_w + 1.2]);
      }
      // Stege drücken auf den Platinenrand, weg von Tastern (~50°/130°),
      // Akkustecker (~10°) und USB-C (270°), Winkel auf dem Board. Sie sind
      // zugleich Rastarme: außen eine Nase, die in die Rille im Ring greift.
      for (a = peg_angles)
        rotate(board_rot + a) intersection() {
          union() {
            translate([0, 0, lip + pcb_back + 0.05])
              linear_extrude(cover_z - lip - pcb_back) difference() {
                cavity2d(-press);
                cavity2d(-press - peg_t);
              }
            if (snap > 0) snap_nose();
          }
          translate([0, -snap_w / 2, 0]) cube([30, snap_w, 30]);
        }
    }
    channel();
    // Kerbe zum Aufhebeln, gegenüber vom Arm
    translate([0, 0, cover_z + cover_t - pry[1]]) linear_extrude(pry[1] + 0.01) intersection() {
      difference() {
        offset(r = 0.01) outline2d();
        offset(r = -pry[1]) outline2d();
      }
      translate([0, -pry[0] / 2]) square([50, pry[0]]);
    }
  }
}

peg_angles = [90, 210, 330];

// Rastnase außen am Steg: Rampe zur Spitze hin zum Einschieben, steilere Flanke
// (etwa 60°) nach hinten, die hält und sich mit dem Hebel noch lösen lässt
module snap_nose() {
  // beginnt an der Stegspitze, ragt nicht Richtung Platine
  steps = [[-0.55, 0], [-0.3, 0.45], [0, 1], [0.35, 0]];
  difference() {
    for (i = [0 : len(steps) - 2])
      hull() for (st = [steps[i], steps[i + 1]])
        translate([0, 0, snap_z + st[0]]) linear_extrude(0.01) cavity2d(-press + snap * st[1]);
    translate([0, 0, snap_z - 2]) linear_extrude(3) cavity2d(-press - peg_t);
  }
}

module cover_print() {
  translate([0, 0, cover_z + cover_t]) rotate([180, 0, 0]) cover();
}

if (part == "assembly") {
  color("dimgray") stand();
  color("silver") cover();
  // Wand der Tassenablage und Board zur Orientierung
  %side() translate([arm_len, -60, -60]) cube([rim_d, rim_above + 60, 120]);
  %translate([0, 0, 0.5]) cylinder(d = lens_d, h = stack - 0.5);
} else if (part == "stand") {
  stand();
} else if (part == "cover") {
  cover_print();
} else if (part == "print") {
  stand();
  translate([0, -50, 0]) cover_print();
}
