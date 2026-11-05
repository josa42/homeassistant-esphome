// Enclosure for the Waveshare ESP32-S3-Touch-LCD-1.28 (shot-timer.yaml),
// sticking out sideways on the left of a Quick Mill Orione 03000, display
// facing forward. Idea from the "Espresso Coffee Shot Timer RP2040" by
// DaniilKrant on MakerWorld, but clamped instead of magnetic, because the
// stainless steel housing isn't magnetic.
//
// Two parts:
// - stand: display ring, arm, leg and clip in one piece. The clip is a U that
//   slides down onto the rim of the cup tray: the leg lies flat against the
//   outside of the side wall, the inner flank clamps the rim from the inside.
//   The leg keeps the clip from tilting under the weight. The arm is a closed
//   channel for the USB-C plug and cable. At its end it passes through the
//   leg, where a slot leads the cable to the back. Printed front down, so the
//   display bezel, arm and leg lie flat on the bed, the U of the clip stands
//   upright and the back wall of the channel is bridged. Inside the leg the
//   channel narrows towards the slot at 45°, so nothing overhangs freely.
// - cover: back cover, snaps in with a bead around its collar and pushes the
//   board forward with three pegs. Printed back down.
//
// The board sits rotated by 90°, USB-C points towards the machine. The
// firmware rotates the image to match.
//
// Assembly: thread the plug from the wall side through the leg and the arm
// until it comes out in the ring, plug it into the board, insert the board
// from the back, press the cable into the slot in the leg, snap on the cover.
//
// Coordinates as mounted: y up, z backwards, x points left as seen from the
// front. The machine is at -x, so everything on its side (arm, leg, clip) is
// mirrored with side() and built with positive distances there. Display front
// at z = 0, display centre at x = y = 0. Board dimensions from the Waveshare
// drawing (ESP32-S3-Touch-LCD-1.28.dxf).

// The print plate is the default, so a plain export is ready to print.
part = "print"; // [print, assembly, stand, cover]

/* [Position, measure on the machine] */
// display centre to the outside of the side wall
arm_len = 55;
// thickness of the cup tray rim, found with test clips (2.3 sits tight)
rim_d = 2.3;
// the U is printed this much narrower than rim_d so it clamps
rim_squeeze = 0.2;
// height of the top of the rim above the display centre
rim_above = 35;
// inner flank of the U, measured below the centre of its rounding
rim_inner = 6;
// On the first print the leg stood about 3 mm off the wall at the bottom of
// the arm. The U is tilted against the leg so the leg touches the wall at the
// bottom, plus some preload so nothing wobbles.
rim_gap = 3;
rim_preload = 0.5;
// The rim has a slight bead on top: the rounding of the U is this much larger,
// below it the U clamps with its normal width again
rim_bead = 0.3;
// length of the plug housing plus strain relief of the USB cable
plug_len = 28;
// width of the cable slot in the leg, a bit less than the cable clamps it
cable_w = 4;
// clear height for threading the plug through the leg, from the front
plug_h = 8.5;

/* [Board] */
lens_d = 38.51;        // lens = board outline
view_d = 35.0;         // display opening, the active area is 33.4
usb_bottom = 21.78;    // outer edge of USB-C from the display centre
tab_w = 14.8;          // board tab carrying USB-C
tab_bottom = 19.4;
stack = 8.4;           // lens front to the tallest part on the back
pcb_back = 5.0;        // lens front to the back of the board
board_rot = -90;       // USB-C (bottom in the datasheet) points to the machine

/* [Housing] */
clr = 0.3;             // clearance around the board
wall = 2;
lip = 1.2;             // thickness of the front bezel
cover_t = 2;
cover_lip_h = 1.5;     // how deep the cover's collar reaches into the ring
cover_lip_w = 1.2;
press = 0.1;           // collar this much smaller than the ring's inside
// Bead around the cover's collar that snaps into a groove in the ring,
// 0 = press fit only. Minus the 0.1 mm gap to the ring it engages 0.3 mm. Ring
// and collar are open at the cable channel, so both give way while snapping,
// within the layer plane where the print is strong.
snap = 0.4;
ring_lead = 0.4;       // chamfer inside the back edge of the ring for the bead
pry = [6, 1];          // notch in the cover edge to pry it off (width, depth)

/* [Arm and clip] */
ch_h = 13.5;           // clear height of the cable channel, fits plug housings up to ~13 mm
ch_front = 2;          // front wall of the channel
ch_wall = 2;
leg_t = 4.5;           // leg against the side wall
hook_t = 3.5;          // wall of the rounding and the inner flank
lead_in = 0.8;         // chamfer at the bottom of the inner flank for sliding on

/* [Shape] */
arm_root = 26;         // arm height at the ring, tapers towards the leg
fillet = 6;            // fillets between ring, arm and leg
round = 1;             // rounding of outer corners in the profile
edge = 0.8;            // 45° chamfer on front and back edges, prints without support

$fa = 4;
$fs = 0.4;

inner_d = lip + stack + 0.5 + cover_lip_h; // inner depth of the ring
cover_z = inner_d;
ch_d = cover_z + cover_t;                   // back wall of the channel flush with the cover
// Leg and clip are deeper than the arm, so above the passage for the plug
// there's room for the 45° slopes towards the cable slot
pass_top = ch_front + plug_h;
leg_w = max(ch_d, pass_top + (ch_h - cable_w) / 2 + 2);
leg_x = arm_len - leg_t;
rim_w = rim_d - rim_squeeze;                // clear width of the U
rim_r = rim_w / 2;
rim_x = arm_len + rim_r;                    // centre of the rounding, the wall is flat
rim_y = rim_above - rim_r;
// tilt of the U against the leg, rotated around its top edge at the wall
rim_tilt = atan((rim_gap + rim_preload) / (rim_above - (-ch_h / 2 - ch_wall)));
rim_pivot = [arm_len, rim_above];
// peak of the snap bead, close to the bottom of the collar, so above it a full
// wall stays between the groove and the lead-in chamfer
snap_z = cover_z - cover_lip_h + 0.4;
ch_bottom = -ch_h / 2 - ch_wall;

assert(rim_y - rim_inner > ch_h / 2 + ch_wall, "rim too low for the arm, increase rim_above");
assert(snap_z + 0.5 < inner_d - ring_lead, "snap groove runs into the lead-in chamfer");
if (usb_bottom + plug_len > leg_x)
  echo(str("WARNING: plug reaches x = ", usb_bottom + plug_len, ", the leg starts at x = ",
    leg_x, ". Increase arm_len or use an angled plug."));

// board outline with the tab for USB-C, as a convex hull
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

// mirrors onto the machine side
module side() {
  mirror([1, 0, 0]) children();
}

// Cable channel from just before the socket to the leg. It reaches back to
// the cover, so inside the ring it's open to the back and the plug can be
// inserted together with the board. Also cuts the cover's collar.
module channel() {
  x0 = usb_bottom - 3;
  side() translate([x0, -ch_h / 2, ch_front]) cube([leg_x + 0.01 - x0, ch_h, cover_z - ch_front]);
}

// Passage through the leg: tall enough at the bottom for the plug, above that
// narrowing at 45° to the cable slot, which is open to the back. In print the
// slopes are 45° overhangs, not free tongues.
module cable_slot() {
  side() translate([leg_x, 0, 0]) rotate([90, 0, 90]) linear_extrude(leg_t + 1)
    polygon([
      [-ch_h / 2, ch_front], [ch_h / 2, ch_front], [ch_h / 2, pass_top],
      [cable_w / 2, pass_top + (ch_h - cable_w) / 2], [cable_w / 2, leg_w + 1],
      [-cable_w / 2, leg_w + 1], [-cable_w / 2, pass_top + (ch_h - cable_w) / 2],
      [-ch_h / 2, pass_top],
    ]);
}

// rotates the U around its top edge at the wall, see rim_tilt
module rim_rotate() {
  translate(rim_pivot) rotate(-rim_tilt) translate(-rim_pivot) children();
}

// Outline of the whole stand from the front: ring, tapering arm and leg blend
// into each other with fillets. On top the U sits over the rim, with a round
// cap from the leg over the inner flank. The U is tilted by rim_tilt against
// the leg, which leaves a shallow recess on the wall side at the top.
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
        // inner flank
        translate([arm_len + rim_w, rim_y - rim_inner]) square([hook_t, rim_inner]);
      }
    }
    side() rim_rotate() {
      // clear width of the U, open at the bottom to just below the inner flank
      translate([rim_x, rim_y]) circle(r = rim_r);
      // room for the bead, the apex stays at the same height
      translate([rim_x, rim_y - rim_bead]) circle(r = rim_r + rim_bead);
      translate([arm_len, rim_y - rim_inner - 1]) square([rim_w, rim_inner + 1]);
      // lead-in chamfer
      translate([arm_len + rim_w, rim_y - rim_inner])
        polygon([[0, -0.01], [lead_in, -0.01], [0, lead_in]]);
    }
  }
}

// Extrudes with a 45° chamfer on the front and back edge, in steps of
// edge / 4, which is about one print layer
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
      // leg and clip are deeper
      edge_extrude(leg_w) intersection() {
        profile2d();
        side() translate([leg_x, -100]) square(200);
      }
    }
    // the cover sits behind the ring
    translate([0, 0, inner_d]) linear_extrude(ch_d) offset(r = 0.01) outline2d();
    translate([0, 0, lip]) linear_extrude(inner_d) cavity2d();
    // display opening with a 45° chamfer towards the front
    translate([0, 0, -0.01]) cylinder(d1 = view_d + 2 * lip, d2 = view_d, h = lip + 0.02);
    channel();
    cable_slot();
    // groove for the cover's snap bead
    if (snap > 0)
      translate([0, 0, snap_z - 0.5]) linear_extrude(1) cavity2d(snap + 0.15);
    // lead-in chamfer for the cover
    hull() {
      translate([0, 0, inner_d - ring_lead]) linear_extrude(0.01) cavity2d();
      translate([0, 0, inner_d]) linear_extrude(0.01) cavity2d(ring_lead);
    }
  }
}

peg_angles = [90, 210, 330];

module cover() {
  difference() {
    union() {
      translate([0, 0, cover_z]) edge_extrude(cover_t, front = false) outline2d();
      // collar
      translate([0, 0, cover_z - cover_lip_h]) linear_extrude(cover_lip_h + 0.01) difference() {
        cavity2d(-press);
        cavity2d(-press - cover_lip_w);
      }
      if (snap > 0) snap_bead();
      // Pegs push on the board edge, away from the buttons (~50°/130°), the
      // battery connector (~10°) and USB-C (270°), angles on the board
      for (a = peg_angles)
        rotate(board_rot + a) intersection() {
          translate([0, 0, lip + pcb_back + 0.05])
            linear_extrude(cover_z - lip - pcb_back) difference() {
              cavity2d(-press);
              circle(r = lens_d / 2 - 1.4);
            }
          translate([0, -1.5, 0]) cube([30, 3, 30]);
        }
    }
    channel();
    // notch for prying the cover off, opposite the arm
    translate([0, 0, cover_z + cover_t - pry[1]]) linear_extrude(pry[1] + 0.01) intersection() {
      difference() {
        offset(r = 0.01) outline2d();
        offset(r = -pry[1]) outline2d();
      }
      translate([0, -pry[0] / 2]) square([50, pry[0]]);
    }
  }
}

// Bead around the outside of the collar: a ramp towards the front for snapping
// in, a 45° flank towards the back that holds and still lets go when pried
module snap_bead() {
  steps = [[-0.4, 0.25], [0, 1], [0.4, 0]];
  difference() {
    for (i = [0 : len(steps) - 2])
      hull() for (st = [steps[i], steps[i + 1]])
        translate([0, 0, snap_z + st[0]]) linear_extrude(0.01) cavity2d(-press + snap * st[1]);
    translate([0, 0, snap_z - 1]) linear_extrude(2) cavity2d(-press - cover_lip_w);
  }
}

module cover_print() {
  translate([0, 0, cover_z + cover_t]) rotate([180, 0, 0]) cover();
}

if (part == "assembly") {
  color("dimgray") stand();
  color("silver") cover();
  // cup tray wall and board for orientation
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
