// MoseRase drive parts, dimensions in millimetres.
// Print the selected part with Z=0 against the bed.

/* [Part] */
drive_part = "fit_gauge"; // [fit_gauge,pulley_tt,pulley_5mm,wheel_tt,wheel_5mm,tire_tpu]
tt_fit = 0.15; // [0:0.05:0.35]
shaft_fit = 0.15; // [0:0.05:0.35]

/* [Hidden] */
drive_eps = 0.02;
drive_pitch = 2;
drive_teeth = 20;
drive_pitch_r = drive_teeth * drive_pitch / (2 * PI);
drive_tooth_r = drive_pitch_r - 0.254;
drive_flange_r = 7.8;
drive_pulley_h = 8.8;
drive_axle_pulley_h = 14.8;
drive_wheel_w = 10;
drive_rim_inner_r = 24.4;
drive_rim_r = 27.6;
drive_bead_r = 28.3;
drive_hub_r = 10.5;
drive_spoke_h = 5.6;
drive_tt_boss_h = 2;
drive_trap_width = 5.8;
drive_trap_depth = 2.65;
tt_shaft_width = 5.3;
tt_shaft_flats = 3.7;
d5_shaft_flat = 1.9;

// Two flats on the TT moulded shaft and one flat on the steel axle.
module drive_tt_profile(fit) {
    intersection() {
        circle(d=tt_shaft_width + fit, $fn=72);
        square([tt_shaft_width + fit + 0.2, tt_shaft_flats + fit], center=true);
    }
}

module drive_d5_profile(fit) {
    radius = (5 + fit) / 2;
    limit = d5_shaft_flat + fit / 2;
    intersection() {
        circle(r=radius, $fn=72);
        translate([-radius-drive_eps, -radius-drive_eps])
            square([radius+limit+drive_eps, 2*(radius+drive_eps)]);
    }
}

module drive_cut(z, h) {
    translate([0,0,z]) linear_extrude(height=h) children();
}

// Rounded 2GT groove approximation. The circumference and 0.254 pitch-line
// offset follow 20T pulley tables. Published root diameter is about 10.72 mm.
// https://grobinc.com/gt/
// Check fit with the purchased 2GT/GT2 belt before loading the printed pulley.
module drive_tooth_space() {
    mouth = 0.755;
    shoulder = 0.625;
    lead_in = 0.08;
    depth = 0.76;
    curve = [for (a=[0:7.5:90])
        [shoulder*cos(a), -lead_in-(depth-lead_in)*sin(a)]];
    polygon(concat(
        [[-mouth,0.5],[mouth,0.5],[mouth,0]],
        curve,
        [for (i=[len(curve)-2:-1:0]) [-curve[i][0],curve[i][1]]],
        [[-mouth,0]]
    ));
}

module drive_pulley_body() {
    difference() {
        union() {
            cylinder(r=drive_flange_r,h=1.02,$fn=96);
            translate([0,0,0.98])
                cylinder(r=drive_tooth_r,h=6.75,$fn=480);
            // The upper bevel starts inside the straight section, above
            // the grooves. Its sloped face supports the lip during printing.
            translate([0,0,7.61])
                cylinder(r1=drive_tooth_r-0.38,r2=drive_flange_r,h=1.0,$fn=96);
            translate([0,0,8.59])
                cylinder(r=drive_flange_r,h=drive_pulley_h-8.59,$fn=96);
        }
        drive_cut(1.04,6.50)
            for (i=[0:drive_teeth-1])
                rotate(360*i/drive_teeth)
                    translate([0,drive_tooth_r]) drive_tooth_space();
    }
}

// Z=0 faces the gearbox, with a gap before the first flange. The axial
// washer bears on the outer flat face to retain the keyed pulley.
module pulley_tt(fit=tt_fit) {
    difference() {
        drive_pulley_body();
        drive_cut(-drive_eps,drive_pulley_h+2*drive_eps)
            drive_tt_profile(fit);
        translate([0,0,-drive_eps]) cylinder(d=6.9, h=1.0+drive_eps, $fn=72);
    }
}

// A hex nut slots in axially. Its flat sides react M3 screw torque.
// The radial screw bears on the flat face of the steel shaft.
module drive_clamp_cut(screw_z, trap_x, top_z, tool_radius) {
    hex_outer_r = 3.22;
    translate([trap_x, -drive_trap_width/2, screw_z-hex_outer_r])
        cube([drive_trap_depth, drive_trap_width, top_z-screw_z+hex_outer_r+drive_eps]);
    translate([d5_shaft_flat-0.15, 0, screw_z])
        rotate([0,90,0])
            cylinder(d=3.25, h=tool_radius-d5_shaft_flat+0.25, $fn=42);
}

// Fit an M3×6 grub screw and M3 hex nut. Z=0 faces the bearing carrier.
module pulley_5mm(fit=shaft_fit) {
    difference() {
        union() {
            drive_pulley_body();
            translate([0,0,drive_pulley_h-drive_eps])
                cylinder(r=7.6,h=drive_axle_pulley_h-drive_pulley_h+drive_eps,$fn=96);
        }
        drive_cut(-drive_eps,drive_axle_pulley_h+2*drive_eps)
            drive_d5_profile(fit);
        drive_clamp_cut(11.45,3.85,drive_axle_pulley_h,7.6);
    }
}

module drive_rim_with_beads() {
    rotate_extrude($fn=144)
        polygon([
            [drive_rim_inner_r,0], [drive_bead_r,0],
            [drive_bead_r,0.65], [drive_rim_r,1.35],
            [drive_rim_r,drive_wheel_w-1.35], [drive_bead_r,drive_wheel_w-0.65],
            [drive_bead_r,drive_wheel_w], [drive_rim_inner_r,drive_wheel_w]
        ]);
}

module drive_tire_keys(clearance=0) {
    for (a=[0:45:315])
        rotate([0,0,a])
            translate([27.4-clearance,-1.4-clearance,1.2-clearance])
                cube([0.99+2*clearance,2.8+2*clearance,7.6+2*clearance]);
}

module drive_spoke_profile() {
    // The open sector at +X is the path for a ball-end key on the D5 hub.
    for (a=[30:60:330])
        rotate(a)
            hull() {
                translate([9.6,0]) circle(r=2.55,$fn=36);
                translate([24.25,0]) circle(r=2.2,$fn=36);
            }
}

module drive_wheel_body() {
    union() {
        drive_rim_with_beads();
        drive_tire_keys();
        cylinder(r=drive_hub_r, h=drive_wheel_w, $fn=96);
        linear_extrude(height=drive_spoke_h) drive_spoke_profile();
    }
}

// Z=0 is the exposed wheel face. The inner 2 mm boss increases keyed length
// while the tire remains 3.4 mm clear of the gearbox.
module wheel_tt(fit=tt_fit) {
    retainer_seat_z = 4.0;
    height = drive_wheel_w + drive_tt_boss_h;
    difference() {
        union() {
            drive_wheel_body();
            translate([0,0,drive_wheel_w-drive_eps])
                cylinder(d=13,h=drive_tt_boss_h+drive_eps,$fn=96);
        }
        drive_cut(-drive_eps,height+2*drive_eps) drive_tt_profile(fit);
        translate([0,0,-drive_eps]) cylinder(d=8.4,h=retainer_seat_z+drive_eps,$fn=72);
    }
}

// Fit an M3×8 grub screw and M3 hex nut. Load the nut from the inner face.
// A ball-end key reaches the screw via the open spoke from the outer face.
module wheel_5mm(fit=shaft_fit) {
    difference() {
        drive_wheel_body();
        drive_cut(-drive_eps,drive_wheel_w+2*drive_eps) drive_d5_profile(fit);
        drive_clamp_cut(5.0,5.1,drive_wheel_w,drive_hub_r);
    }
}

module tire_tpu() {
    difference() {
        rotate_extrude($fn=144)
            polygon([
                [28.42,0], [29.6,0], [30,0.55], [30,9.45], [29.6,10],
                [28.42,10], [28.42,9.32], [27.54,8.43],
                [27.54,1.57], [28.42,0.68]
            ]);
        drive_tire_keys(0.2);
    }
}

// TT holes beside the single-marker row, D5 holes beside the double marker.
// Columns left-to-right add 0.05, 0.15 and 0.25 mm to marked dimensions.
module drive_fit_gauge() {
    difference() {
        linear_extrude(height=4)
            hull() for (x=[-12.5,12.5],y=[-8,8])
                translate([x,y]) circle(r=2.5,$fn=40);
        drive_cut(-drive_eps,4+2*drive_eps)
            for (i=[0:2]) {
                fit = 0.05+0.10*i;
                translate([(i-1)*8,4]) drive_tt_profile(fit);
                translate([(i-1)*8,-4]) drive_d5_profile(fit);
            }
        for (p=[[-12.5,4],[-12.5,-3.2],[-12.5,-4.8]])
            translate([p[0],p[1],3.45]) cylinder(d=1,h=0.6,$fn=24);
    }
}

// Smooth belt envelope for assembly checks. The local axes run along +Y,
// with teeth inward and 6 mm width parallel to Z.
module drive_belt_preview(center_distance=70) {
    linear_extrude(height=6)
        difference() {
            hull() for (y=[0,center_distance])
                translate([0,y]) circle(r=drive_pitch_r+0.64,$fn=72);
            hull() for (y=[0,center_distance])
                translate([0,y]) circle(r=drive_pitch_r-0.7,$fn=72);
        }
}

if (drive_part=="fit_gauge") drive_fit_gauge();
else if (drive_part=="pulley_tt") pulley_tt();
else if (drive_part=="pulley_5mm") pulley_5mm();
else if (drive_part=="wheel_tt") wheel_tt();
else if (drive_part=="wheel_5mm") wheel_5mm();
else if (drive_part=="tire_tpu") tire_tpu();
