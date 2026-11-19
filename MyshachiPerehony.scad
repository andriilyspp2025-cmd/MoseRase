// Mouse race chassis. All dimensions are in millimetres.
// In OpenSCAD, choose part, press F6, then File > Export > Export as STL.

/* [Model] */
part = "assembly_l298"; // [assembly_l298,assembly_drv8833,chassis,sensor_arm,l298_mount,drv8833_mount,skid]
wheel_diameter = 60;
wheel_setup = "two"; // [two,four_coaxial]
skid_tape_thickness = 0.4;

/* [Mounting adjustments] */
// Measure the green Makerfabs PCB. These defaults are estimated from a photo.
l298_pitch_x = 38.5;
l298_pitch_y = 33.5;
// The two inner holes on the BFD-style sensor, measured across the PCB.
sensor_inner_hole_pitch = 74;
sensor_travel_position = 0; // [-4.5:0.5:4.5]

/* [Hidden] */
$fn = 48;
eps = 0.02;
deck = 3.2;
adapter_t = 3.2;
four_wheels = wheel_setup == "four_coaxial";
motor_shift = four_wheels ? 9 : 0;
front_shift = four_wheels ? 18 : 0;
motor_x = 39.2 + motor_shift;
motor_w = 18.8;
motor_h = 22.3;
motor_rear = 53.22;
motor_front = 11.28;
motor_axis_z = deck + motor_h/2;
floor_z = motor_axis_z - wheel_diameter/2;
driver_y = -48;
driver_anchor = 22;
driver_spacer = 6;
sensor_x = 30;
sensor_y = four_wheels ? 52 : 43;
sensor_anchor = 9.5;
sensor_travel = 4.5;
skid_y = 27;
skid_h = -floor_z - skid_tape_thickness;
sensor_washer = 1.5;
battery_y = 18;
esp_x = 37;
esp_y = 42 + front_shift;

module round_rect(w, l, r) {
    hull() {
        for (x = [-w/2+r, w/2-r], y = [-l/2+r, l/2-r])
            translate([x,y]) circle(r=r);
    }
}

module slot(a, b, d) {
    hull() {
        for (p = [a,b]) translate(p) circle(d=d);
    }
}

module relief(w, l, r, x, y) {
    translate([x,y]) round_rect(w,l,r);
}

module cut_through(h) {
    translate([0,0,-eps]) linear_extrude(height=h+2*eps) children();
}

module chassis_outline() {
    offset(r=2.8) offset(delta=-2.8)
    polygon([
        [-23,-75], [23,-75], [49+motor_shift,-56], [49+motor_shift,32],
        [53,40], [53,64+front_shift], [45,72+front_shift],
        [-45,72+front_shift], [-53,64+front_shift], [-53,40],
        [-49-motor_shift,32], [-49-motor_shift,-56]
    ]);
}

module chassis_plate() {
    linear_extrude(height=deck) difference() {
        chassis_outline();

        relief(47, 32, 5, 0, -48);
        relief(32, 18, 4, 0, -10);
        relief(30, 13, 4, 0, 10);
        relief(31, 12.5, 4, 0, 43);
        relief(35, 11, 4, 0, 62);

        for (side = [-1,1]) {
            relief(12, 20, 4, side*40, 41+front_shift);
            if (four_wheels)
                relief(10.1,64.6,2.3,side*31.55,0);
            for (y = [-30,-8]) {
                if (four_wheels)
                    relief(3.5,6.2,1.5,side*(y == -30 ? 36.65 : 36.6),y);
                else
                    relief(3.5,6.2,1.5,side*(y == -30 ? 27.08 : 27),y);
                relief(3,6.6,1.4,side*(49.8+motor_shift),y);
            }
            for (y = [3,43])
                relief(4.2, 10.8, 1.6, side*23, y);
            for (p = [[26,21],[46,21],[26.1,61],[49,61]])
                relief(3.5,5.4,1.4,side*p[0],p[1]+front_shift);
            for (y = [sensor_y-sensor_anchor, sensor_y+sensor_anchor])
                translate([side*sensor_x,y]) circle(d=3.4);
            translate([side*7.35,skid_y]) circle(d=2.4);
        }
        for (y = [driver_y-driver_anchor, driver_y+driver_anchor])
            translate([0,y]) circle(d=3.4);
        translate([0,skid_y]) circle(d=3.5);
    }
}

module pad(x,y,w,l,h,r=1.1) {
    translate([x,y,deck-eps])
        linear_extrude(height=h+eps) round_rect(w,l,r);
}

module chassis() {
    union() {
        chassis_plate();
        for (side = [-1,1]) {
            // Short guides touch the flat gearbox side. The inner shaft stays free.
            for (y = [-44,-18])
                if (four_wheels)
                    pad(side*(y == -44 ? 37.96 : 38.04),y,1.15,8,4.4,0.35);
                else
                    pad(side*(y == -44 ? 28.22 : 28.3),y,2.6,8,4.4);
            pad(side*motor_x,12.75,13,2.5,4.5);

            // These pads leave the controller's underside and pin rows clear.
            for (y = [25,57])
                pad(side*esp_x,y+front_shift,12,7,3.0);
        }
    }
}

module sensor_anchor_sinks() {
    for (y = [-sensor_anchor,sensor_anchor]) hull() {
        for (end = [-sensor_travel,sensor_travel])
            translate([0,y+end,-eps])
                cylinder(h=1.42,d1=6.3,d2=3.45);
    }
}

module sensor_arm() {
    difference() {
        linear_extrude(height=adapter_t) hull() {
            for (y = [-15,15]) translate([0,y]) circle(r=4.8);
            translate([16.2,0]) circle(r=5.1);
        }
        cut_through(adapter_t) {
            for (y = [-sensor_anchor,sensor_anchor])
                slot([0,y-sensor_travel],[0,y+sensor_travel],3.4);
            slot([4,0],[14,0],3.4);
        }
        // Screw heads go underneath, flush with the underside next to the sensor.
        sensor_anchor_sinks();
    }
}

module driver_spine() {
    slot([0,-driver_anchor],[0,driver_anchor],10);
}

module driver_attachment_holes() {
    for (y = [-driver_anchor,driver_anchor])
        translate([0,y]) circle(d=3.4);
}

module l298_mount() {
    assert(l298_pitch_x >= 29 && l298_pitch_x <= 46);
    assert(l298_pitch_y >= 26 && l298_pitch_y <= 41);
    linear_extrude(height=adapter_t) difference() {
        union() {
            driver_spine();
            for (side = [-1,1])
                relief(l298_pitch_x+13,13.4,2,
                       0,side*l298_pitch_y/2);
        }
        driver_attachment_holes();
        for (side_x = [-1,1], side_y = [-1,1])
            relief(7.6,7.6,1.25,side_x*l298_pitch_x/2,side_y*l298_pitch_y/2);
    }
}

module drv8833_mount() {
    linear_extrude(height=adapter_t) difference() {
        union() {
            driver_spine();
            round_rect(33,33,3);
        }
        driver_attachment_holes();
        for (side = [-1,1], y = [-7.5,7.5])
            relief(3.5,5.4,1.4,side*13,y);
    }
}

module skid() {
    assert(skid_h > 9);
    rotate_extrude() polygon([
        [1.75,0], [9,0], [9,2],
        [7.8,skid_h-4.2], [6.5,skid_h-1.0], [5.5,skid_h],
        [3.55,skid_h], [3.55,6.4], [1.75,6.4]
    ]);
}

module centred_box(w,l,h,x,y,z,r=1) {
    translate([x,y,z]) linear_extrude(height=h) round_rect(w,l,r);
}

// Assembly envelopes for layout and clearance. They are preview geometry.
module motor_reference(side) {
    color("#e9ae24")
        centred_box(motor_w,44,22.3,side*motor_x,motor_front-22,deck,2.3);
    color("#c0c6ca")
        translate([side*motor_x,-motor_rear,deck+motor_h/2])
        rotate([-90,0,0]) cylinder(d=18.2,h=22);
    color("#e5dfce")
        translate([side*(motor_x-motor_w/2-9.1),0,motor_axis_z])
        rotate([0,side*90,0]) cylinder(d=5.4,h=37);
}

module wheel_reference(side, inner=false) {
    direction = inner ? -side : side;
    x = side*motor_x + direction*(motor_w/2+3.4);
    width = four_wheels ? 8 : 12;
    color("#343d49") translate([x,0,motor_axis_z])
        rotate([0,direction*90,0])
        difference() {
            cylinder(d=wheel_diameter,h=width);
            translate([0,0,-eps]) cylinder(d=wheel_diameter-7,h=width+2*eps);
        }
    color("#aab6bd") translate([x+direction*1.2,0,motor_axis_z])
        rotate([0,direction*90,0]) cylinder(d=wheel_diameter-6.8,h=width-2.4);
}

module board_reference(is_l298) {
    z = deck + driver_spacer + adapter_t;
    if (is_l298) {
        color("#2a7b55") centred_box(l298_pitch_x+10,l298_pitch_y+9,1.6,
                                      0,driver_y,z+6,3.2);
        color("#282d35") centred_box(13,26,15,18,driver_y,z+7.6,1.5);
        color("#376aa2") {
            centred_box(7,15,8,-19,driver_y,z+7.6);
            for (y = [-16,16])
                centred_box(10,7,8,-10,driver_y+y,z+7.6);
        }
    } else {
        color("#202f4b") centred_box(12.7,20.3,1.6,0,driver_y,z+1.0);
        color("#33353d") centred_box(5,5,1.6,0,driver_y,z+2.6);
    }
}

module sensor_reference() {
    y = sensor_y+sensor_travel_position;
    z = -adapter_t-sensor_washer-1.6;
    color("#285c92") difference() {
        union() {
            centred_box(128,15,1.6,0,y+4.7,z,1.25);
            translate([0,y,z]) linear_extrude(height=1.6)
                polygon([[-22,9],[22,9],[11,28],[-11,28]]);
        }
        for (side = [-1,1])
            translate([side*sensor_inner_hole_pitch/2,y,z-eps])
                cylinder(d=3.2,h=1.6+2*eps);
    }
    color("#252b34") {
        for (x = [-54,-28,28,54])
            centred_box(7,7,5.8,x,y+5,z-5.8,1);
        centred_box(7,7,5.8,0,y+19,z-5.8,1);
    }
}

module assembly(is_l298) {
    assert(abs(sensor_travel_position) <= sensor_travel);
    assert(sensor_inner_hole_pitch >= 2*(sensor_x+4)
           && sensor_inner_hole_pitch <= 2*(sensor_x+14));
    color("#e5e9ec") chassis();
    color("#a7aeb4") translate([0,skid_y,0]) rotate([180,0,0]) skid();
    for (side = [-1,1]) {
        motor_reference(side);
        wheel_reference(side);
        if (four_wheels) wheel_reference(side,true);
        color("#31a896")
            translate([side*sensor_x,sensor_y+sensor_travel_position,-adapter_t])
                rotate([0,0,side==1 ? 0 : 180]) sensor_arm();
    }
    for (offset_y = [-driver_anchor,driver_anchor])
        color("#a7aeb4") translate([0,driver_y+offset_y,deck])
            cylinder(d=6,h=driver_spacer);
    color(is_l298 ? "#e9a06e" : "#9b9de1")
        translate([0,driver_y,deck+driver_spacer])
            if (is_l298) l298_mount(); else drv8833_mount();
    board_reference(is_l298);
    color("#454b57")
        centred_box(43,76,8,0,battery_y,deck+4,2.5);
    for (x = [-10.1,10.1])
        color("#6993b8") translate([x,battery_y-32.5,deck+14.5])
            rotate([-90,0,0]) cylinder(d=18.4,h=65);
    color("#252d3b")
        centred_box(28,55,1.6,esp_x,esp_y,deck+3,1.3);
    color("#98a6ad")
        centred_box(8,6,3,esp_x,esp_y+25.8,deck+4.6,0.8);
    color("#4d535d")
        centred_box(15,21,6,-38,56+front_shift,deck+3,1.5);
    if (!is_l298)
        color("#318c74") centred_box(21,27,8,-38,30+front_shift,deck+3,1.5);
    sensor_reference();
}

if (part == "chassis") chassis();
else if (part == "sensor_arm") sensor_arm();
else if (part == "l298_mount") l298_mount();
else if (part == "drv8833_mount") drv8833_mount();
else if (part == "skid") skid();
else if (part == "assembly_l298") assembly(true);
else if (part == "assembly_drv8833") assembly(false);
else assert(false, "Choose a supported part in the Customizer.");

assert(wheel_setup == "two" || wheel_setup == "four_coaxial");
assert(wheel_diameter <= 60 || !four_wheels,
       "Four-wheel slots are designed for 60 mm tires.");
