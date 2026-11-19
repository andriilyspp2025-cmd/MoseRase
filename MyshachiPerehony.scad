// MoseRase, in millimetres. Assembly: +Y forward, Z=0 at the track.
// Printable parts are automatically placed flat on Z=0.

/* [Model] */
part = "assembly_l298"; // [assembly_l298,assembly_drv8833,chassis,nose,l298_mount,drv8833_mount,skid,anti_wheelie]
front_support = "skid"; // [skid,pololu_952]
battery_center_y = 30; // [24:0.5:44]
sensor_y_adjustment = 0; // [-2:0.5:2]
sensor_spacer = 4.7; // [3:0.1:6]
skid_tape_thickness = 0.4;

/* [PCB mounting] */
l298_pitch_x = 38.5;
l298_pitch_y = 33.5;
sensor_inner_hole_pitch = 74;

/* [Hidden] */
$fn = 40;
eps = 0.03;
floor_clearance = 7;
floor_t = 3.2;
floor_top = floor_clearance + floor_t;
tray_width = 43;
tray_length = 76;
motor_x = 44;
motor_w = 18.8;
motor_h = 22.3;
motor_shaft_z = 30;
motor_bottom = motor_shaft_z-motor_h/2;
motor_hole_y = 20.47;
motor_hole_spacing = 17.3;
motor_inner_x = motor_x-motor_w/2;
tower_t = 6;
wheel_gap = 3.4;
wheel_w = 12;
wheel_d = 60;
driver_y = 105.6;
driver_anchor_x = 31.4;
driver_anchor_dy = 10.9;
adapter_t = 3.2;
driver_pcb_gap = 2.5;
esp_x = 41.5;
esp_y = 83.5;
nose_seat = 15.65;
nose_screw_x = 30;
nose_screw_ys = [124,134];
support_y = 132;
sensor_mount_y = 147;
rear_screw_y = -23;
rear_gap = 3;

module round_rect(w,l,r) {
    hull() for (x=[-w/2+r,w/2-r], y=[-l/2+r,l/2-r])
        translate([x,y]) circle(r=r);
}

module relief(w,l,r,x,y) {
    translate([x,y]) round_rect(w,l,r);
}

module box(w,l,h,x,y,z,r=1) {
    translate([x,y,z]) linear_extrude(height=h) round_rect(w,l,r);
}

module holes(points,d) {
    for (p=points) translate(p) circle(d=d);
}

module extrude_at(z,h) {
    translate([0,0,z]) linear_extrude(height=h) children();
}

module nose_mount_holes() {
    holes([for (s=[-1,1],y=nose_screw_ys) [s*nose_screw_x,y]],3.4);
}

module driver_anchors() {
    holes([[-driver_anchor_x,driver_anchor_dy],[driver_anchor_x,driver_anchor_dy]],3.4);
}

module chassis_outline() {
    union() {
        relief(55,100,3,0,34);
        relief(31,15,4,0,-21.5);
        for (side=[-1,1]) {
            relief(20,71,4,side*42,23);
            relief(25,91,5,side*40,93.5);
        }
        relief(103,10,4,0,-8);
        relief(103,16,4,0,motor_hole_y);
        relief(103,11,4,0,51);
        relief(12,53,3,0,105);
        relief(83,9,3,0,133);
    }
}

module chassis_floor() {
    extrude_at(floor_clearance,floor_t) difference() {
        chassis_outline();
        for (s=[-1,1]) {
            relief(10,25,3,s*42,78);
            relief(9,13,2,s*43,116);
            for (p=[[30,67],[49,67],[30.1,105],[49.12,105]])
                relief(2.8,5.2,1.25,s*p[0],p[1]);
            for (y=[9,59]) relief(3.5,10.6,1.5,s*24,y);
            for (x=[32,49.5]) relief(2.8,6.2,1.25,s*x,43);
        }
        nose_mount_holes();
        relief(23.5,21,3,0,support_y);
        holes([[-6,rear_screw_y],[6,rear_screw_y]],3.4);
    }
}

module motor_hole_profile() {
    hull() {
        circle(d=3.4);
        translate([0,1.7*sqrt(2)]) circle(d=0.04,$fn=12);
    }
}

module motor_hole(z) {
    multmatrix([
        [0,0,1,motor_inner_x-tower_t-8],
        [1,0,0,motor_hole_y],
        [0,1,0,z],
        [0,0,0,1]
    ]) linear_extrude(height=tower_t+10) motor_hole_profile();
}

module right_motor_tower() {
    difference() {
        union() {
            box(tower_t,15,33,motor_inner_x-tower_t/2,motor_hole_y,
                floor_top-eps,0.8);
            // The root widens toward the floor. The upper end of each screw
            // and its nut keep a clear corridor alongside the battery.
            hull() {
                box(9,15,0.8,motor_inner_x-4.5,motor_hole_y,floor_top-eps,0.8);
                box(6,15,0.8,motor_inner_x-3,motor_hole_y,19,0.8);
            }
        }
        for (s=[-1,1]) motor_hole(motor_shaft_z+s*motor_hole_spacing/2);
    }
}

module countersink_from_floor(x,y) {
    translate([x,y,floor_clearance]) rotate_extrude()
        polygon([[0,-eps],[3.25,-eps],[1.7,1.55],
                 [1.7,floor_t+eps],[0,floor_t+eps]]);
}

module chassis() {
    difference() {
        union() {
            chassis_floor();
            for (s=[-1,1]) {
                // Tray rails and shelf faces are printed with the frame.
                box(2.3,95,4.0,s*26,34,floor_top-eps,0.75);
                for (y=[6,34])
                    box(13,9,motor_bottom-floor_top+eps,s*motor_x,y,
                        floor_top-eps,1.1);
                for (y=[63,109])
                    box(10,5,2,s*(y==63 ? esp_x-0.12 : esp_x),y,floor_top-eps,0.8);
                for (y=nose_screw_ys)
                    box(7.7,7.7,nose_seat-floor_top+eps,s*nose_screw_x,y,
                        floor_top-eps,1);
            }
            for (y=[-15,83])
                box(29,1.8,2.5,0,y,floor_top-eps,0.65);
            right_motor_tower();
            mirror([1,0,0]) right_motor_tower();
        }
        extrude_at(floor_top-eps,nose_seat-floor_top+2*eps) nose_mount_holes();
        for (s=[-1,1])
            countersink_from_floor(s*driver_anchor_x,driver_y+driver_anchor_dy);
    }
}

module nose_outline() {
    union() {
        relief(70,8,1.8,0,support_y);
        for (s=[-1,1]) hull() {
            relief(10,8,2,s*nose_screw_x,124);
            relief(15,13,2,s*37,sensor_mount_y+0.4);
        }
    }
}

module nose() {
    linear_extrude(height=adapter_t) difference() {
        nose_outline();
        nose_mount_holes();
        holes([[0,support_y]],3.5);
        holes([[-7.35,support_y],[7.35,support_y]],2.4);
        for (s=[-1,1]) relief(9.6,7.4,1.65,s*37,sensor_mount_y);
    }
}

module driver_spine() {
    union() {
        relief(10,43,4,0,-1.5);
        for (s=[-1,1]) hull() {
            relief(9,9,2,0,8);
            translate([s*driver_anchor_x,driver_anchor_dy]) circle(r=4.6);
        }
    }
}

module l298_mount() {
    linear_extrude(height=adapter_t) difference() {
        union() {
            driver_spine();
            for (s=[-1,1])
                relief(l298_pitch_x+13,13.4,2,0,s*l298_pitch_y/2);
        }
        driver_anchors();
        relief(23.5,21,3,0,support_y-driver_y);
        relief(46,16,1,0,74.6-driver_y);
        for (sx=[-1,1],sy=[-1,1])
            relief(7.6,7.6,1.25,sx*l298_pitch_x/2,sy*l298_pitch_y/2);
    }
}

module drv8833_mount() {
    linear_extrude(height=adapter_t) difference() {
        union() {
            driver_spine();
            round_rect(32,30,3);
        }
        driver_anchors();
        for (s=[-1,1],y=[-7.5,7.5]) relief(3.5,5.4,1.4,s*12.5,y);
    }
}

module skid() {
    h = nose_seat-skid_tape_thickness;
    rotate_extrude() polygon([
        [1.75,0],[9,0],[9,2],[7.8,h-4.2],[6.5,h-1],[5.5,h],
        [3.55,h],[3.55,6.4],[1.75,6.4]
    ]);
}

module anti_wheelie() {
    h = floor_clearance-rear_gap;
    difference() {
        hull() {
            box(26,11,0.8,0,0,0,2.5);
            box(22,9.2,0.4,0,1,h-0.4,2.2);
        }
        for (x=[-6,6]) translate([x,0,0]) rotate_extrude()
            polygon([[0,-eps],[1.7,-eps],[1.7,h-1.55],
                     [3.25,h+eps],[0,h+eps]]);
    }
}

module motor_reference(s) {
    color("#e9ae24")
        box(motor_w,44,motor_h,s*motor_x,22-11.28,motor_bottom,2.3);
    color("#c0c6ca") translate([s*motor_x,31.2,motor_shaft_z])
        rotate([-90,0,0]) cylinder(d=18.2,h=22);
    color("#e5dfce") translate([s*(motor_inner_x-9.1),0,motor_shaft_z])
        rotate([0,s*90,0]) cylinder(d=5.4,h=37);
}

module wheel_reference(s) {
    x = s*(motor_x+motor_w/2+wheel_gap);
    color("#343d49") translate([x,0,motor_shaft_z]) rotate([0,s*90,0])
        difference() {
            cylinder(d=wheel_d,h=wheel_w);
            translate([0,0,-eps]) cylinder(d=wheel_d-7,h=wheel_w+2*eps);
        }
    color("#aab6bd") translate([x+s*1.2,0,motor_shaft_z]) rotate([0,s*90,0])
        cylinder(d=wheel_d-6.8,h=wheel_w-2.4);
}

module battery_reference() {
    color("#454b57") box(tray_width,tray_length,5,0,battery_center_y,floor_top,2.2);
    for (x=[-10.1,10.1]) color("#6993b8")
        translate([x,battery_center_y-32.5,floor_top+10.5])
            rotate([-90,0,0]) cylinder(d=18.4,h=65);
}

module driver_reference(is_l298) {
    z = floor_top+adapter_t+driver_pcb_gap;
    color(is_l298 ? "#e9a06e" : "#9b9de1") translate([0,driver_y,floor_top])
        if (is_l298) l298_mount(); else drv8833_mount();
    if (is_l298) {
        color("#2a7b55") box(l298_pitch_x+10,l298_pitch_y+9,1.6,0,driver_y,z,3.2);
        color("#282d35") box(13,26,15,18,driver_y,z+1.6,1.5);
        color("#376aa2") {
            box(7,15,8,-19,driver_y,z+1.6);
            for (dy=[-16,16]) box(10,7,8,-10,driver_y+dy,z+1.6);
        }
    } else {
        color("#202f4b") box(12.7,20.3,1.6,0,driver_y,z,1);
        color("#33353d") box(5,5,1.6,0,driver_y,z+1.6,1);
    }
}

module sensor_reference() {
    y = sensor_mount_y+sensor_y_adjustment;
    z = nose_seat-sensor_spacer-1.6;
    color("#285c92") difference() {
        union() {
            box(128,15,1.6,0,y+4.7,z,1.25);
            extrude_at(z,1.6) translate([0,y])
                polygon([[-22,9],[22,9],[11,28],[-11,28]]);
        }
        extrude_at(z-eps,1.6+2*eps)
            holes([[-sensor_inner_hole_pitch/2,y],[sensor_inner_hole_pitch/2,y]],3.2);
    }
    color("#252b34") {
        for (x=[-54,-28,28,54]) box(7,7,5.8,x,y+5,z-5.8,1);
        box(7,7,5.8,0,y+19,z-5.8,1);
    }
}

module controller_reference() {
    color("#252d3b") box(28,55,1.6,esp_x,esp_y,floor_top+2,1.3);
    color("#98a6ad") box(8,6,3,esp_x,esp_y+25.8,floor_top+3.6,0.8);
}

module support_reference() {
    if (front_support=="skid")
        color("#a7aeb4") translate([0,support_y,nose_seat]) rotate([180,0,0]) skid();
    else {
        color("#353b42") box(20.3,15.2,8,0,support_y,5.5,3.5);
        color("#cacdd1") translate([0,support_y,6.35]) sphere(d=12.7);
        color("#c6c1b6") box(20.3,15.2,nose_seat-13.5,0,support_y,13.5,3.5);
    }
}

module assembly(is_l298) {
    color("#e5e9ec") chassis();
    color("#31a896") translate([0,0,nose_seat]) nose();
    color("#a7aeb4") translate([0,rear_screw_y,floor_clearance])
        rotate([180,0,0]) anti_wheelie();
    for (s=[-1,1]) {
        motor_reference(s);
        wheel_reference(s);
    }
    battery_reference();
    driver_reference(is_l298);
    controller_reference();
    color("#4d535d") box(15,21,6,-38,101,floor_top+2,1.5);
    if (!is_l298) color("#318c74") box(21,27,8,-38,72,floor_top+2,1.5);
    support_reference();
    sensor_reference();
}

assert(battery_center_y>=24 && battery_center_y<=44);
assert(abs(sensor_y_adjustment)<=2);
assert(sensor_inner_hole_pitch>=68 && sensor_inner_hole_pitch<=80);
assert(l298_pitch_x>=34 && l298_pitch_x<=41);
assert(l298_pitch_y>=29 && l298_pitch_y<=35);

if (part=="chassis") translate([0,0,-floor_clearance]) chassis();
else if (part=="nose") nose();
else if (part=="l298_mount") l298_mount();
else if (part=="drv8833_mount") drv8833_mount();
else if (part=="skid") skid();
else if (part=="anti_wheelie") anti_wheelie();
else if (part=="assembly_l298") assembly(true);
else if (part=="assembly_drv8833") assembly(false);
else assert(false,"Choose a part from the Model section.");
