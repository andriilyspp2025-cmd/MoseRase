// MoseRase, four wheel belt drive. Dimensions are in mm.
// Assembly coordinates: track Z=0, +Y forward, fixed TT axle at Y=70.
use <Drive.scad>

/* [Model] */
part = "assembly_l298"; // [assembly_l298,assembly_drv8833,bare,chassis,nose,rear_carrier,pulley_tt,pulley_5mm,wheel_tt,wheel_5mm,tire_tpu,drive_fit_gauge]
rear_axle_y = 0; // [-2:0.25:2]
battery_center_y = 33; // [30:0.5:36]
sensor_y_offset = 0; // [-2:0.5:2]
sensor_spacer = 4.7; // [3:0.1:6]
bearing_seat_d = 16.18; // [16:0.02:16.5]
tt_hub_clearance = 0.15; // [0:0.05:0.35]
steel_hub_clearance = 0.15; // [0:0.05:0.35]

/* [Board dimensions] */
l298_pitch_x = 38.5;
l298_pitch_y = 33.5;
sensor_inner_hole_pitch = 74;

/* [Hidden] */
$fn = 40;
eps = 0.03;
floor_clearance = 7;
floor_t = 3.2;
floor_top = floor_clearance+floor_t;
front_y = 70;
shaft_z = 30;
motor_x = 49;
motor_w = 18.8;
motor_inner_x = motor_x-motor_w/2;
motor_hole_y = front_y+20.47;
motor_bottom = shaft_z-22.3/2;
tower_t = 6;
rear_carrier_inner_x = 41.5;
carrier_w = 16;
carrier_z0 = floor_top-shaft_z;
carrier_bolt_a = 10.5;
rear_carrier_x = rear_carrier_inner_x+carrier_w/2;
wheel_outer_x = 71.8;
pulley_outer_x = 39;
belt_x = pulley_outer_x-4.4;
belt_pitch_r = 20*2/(2*PI);
nose_seat = 15.65;
nose_t = 3.2;
nose_x = 24;
nose_anchor_ys = [80,95];
sensor_y = 104;
driver_y = 110;
esp_x = 46;
esp_y = 47;

module round_rect(w,l,r) {
    hull() for (x=[-w/2+r,w/2-r], y=[-l/2+r,l/2-r])
        translate([x,y]) circle(r=r);
}

module rr(w,l,r,x,y) {
    translate([x,y]) round_rect(w,l,r);
}

module box(w,l,h,x,y,z,r=1) {
    translate([x,y,z]) linear_extrude(height=h) round_rect(w,l,r);
}

module slot(a,b,d) {
    hull() for (p=[a,b]) translate(p) circle(d=d);
}

module holes(points,d) {
    for (p=points) translate(p) circle(d=d);
}

module plate_at(z,h) {
    translate([0,0,z]) linear_extrude(height=h) children();
}

module nose_anchors() {
    holes([for (s=[-1,1],y=nose_anchor_ys) [s*nose_x,y]],3.4);
}

module floor_outline() {
    union() {
        offset(r=2) offset(delta=-2) polygon([
            [-25,-11.5],[25,-11.5],[27,-9],[27,36],[27.7,39],
            [27.7,49],[26.9,52],[26.9,74.4],[24.5,77.5],
            [-24.5,77.5],[-26.9,74.4],[-26.9,52],[-27.7,49],
            [-27.7,39],[-27,36],[-27,-9]
        ]);
        for (s=[-1,1]) {
            rr(20,112,4,s*47.5,41);
            hull() {
                rr(15,10,3,s*37,58);
                rr(20,11,3,s*43,93.1);
            }
        }
        rr(95,10,4,0,-5);
        rr(96,11,4,0,43);
        rr(98,9,3,0,88);
        rr(63,8,3,0,94.5);
    }
}

module frame_floor(fan_ready=false) {
    plate_at(floor_clearance,floor_t) difference() {
        union() {
            floor_outline();
            if (fan_ready) {
                rr(91,6,2,0,-30.3);
                for (side=[-1,1]) {
                    rr(18,24,2,side*36,-20);
                    rr(11,11,2,side*35.8,80.55);
                    for (y=[23,58]) rr(11,10,2,side*39.4,y);
                }
            }
        }
        if (fan_ready)
            rr(55,105,1.5,0,23.5);
        rr(23,15,4,0,12);
        rr(24,16,4,0,35);
        rr(23,15,4,0,59);
        for (s=[-1,1]) {
            rr(8.5,16,3,s*47,27);
            rr(8,15,2.8,s*47.4,52);
            if (!fan_ready)
                for (y=[17,61]) rr(3.5,9.4,1.5,s*24,y);
            for (y=[carrier_bolt_a,-carrier_bolt_a])
                slot([s*rear_carrier_x,y-2.3],[s*rear_carrier_x,y+2.3],y<0 ? 3.5 : 3.56);
            for (p=[[40,8],[54,10],[39.7,46],[54.15,47]])
                rr(3,5.1,1.35,s*p[0],p[1]);
            for (x=[37.7,55.2]) rr(2.8,6,1.25,s*x,92);
        }
        nose_anchors();
    }
}

module motor_hole(z) {
    multmatrix([
        [0,0,1,motor_inner_x-tower_t-8],
        [1,0,0,motor_hole_y],
        [0,1,0,z],
        [0,0,0,1]
    ]) linear_extrude(height=tower_t+10) hull() {
        circle(d=3.4);
        translate([0,1.7*sqrt(2)]) circle(d=0.04,$fn=12);
    }
}

module motor_tower() {
    difference() {
        union() {
            box(tower_t,15,33,motor_inner_x-tower_t/2,motor_hole_y,floor_top-eps,0.8);
            hull() {
                box(9,15,0.8,motor_inner_x-4.5,motor_hole_y,floor_top-eps,0.8);
                box(6,15,0.8,motor_inner_x-3,motor_hole_y,19,0.8);
            }
        }
        for (dz=[-8.65,8.65]) motor_hole(shaft_z+dz);
    }
}

module chassis(fan_ready=false) {
    difference() {
        union() {
            frame_floor(fan_ready);
            for (s=[-1,1]) {
                if (!fan_ready)
                    box(2.2,83,4,s*25.7,33,floor_top-eps,0.7);
                if (fan_ready)
                    for (p=[[34,-20.5,8],[35.8,80.55,6.6]])
                        translate([s*p[0],p[1],floor_top-eps])
                            cylinder(d=p[2],h=15+eps);
                box(13,10,motor_bottom-floor_top+eps,s*motor_x,80.2,
                    floor_top-eps,1.1);
                for (y=s==1 ? [22,58] : [24,44])
                    box(11,5,2.5,s*(y<30 ? 46 : 46.14),y,floor_top-eps,0.8);
                for (y=nose_anchor_ys)
                    box(7.7,7.2,nose_seat-floor_top+eps,s*nose_x,y,
                        floor_top-eps,0.85);
            }
            if (!fan_ready)
                for (y=[-9,75])
                    box(26,1.8,2.4,0,y,floor_top-eps,0.55);
            motor_tower();
            mirror([1,0,0]) motor_tower();
        }
        plate_at(floor_top-eps,nose_seat-floor_top+2*eps) nose_anchors();
        if (fan_ready)
            for (side=[-1,1]) {
                for (p=[[34,-20.5],[35.8,80.55]])
                    translate([side*p[0],p[1],floor_top+15-7])
                        cylinder(d=4.15,h=7+eps);
                // Leave tool and bolt-head clearance above the front post.
                translate([side*35.8,80.55,floor_top+15])
                    cylinder(d=8,h=8);
                for (y=[23,58])
                    translate([side*39.4,y,floor_clearance])
                        rotate_extrude() polygon([
                            [0,-eps],[1.7,-eps],[1.7,floor_t-1.65],
                            [3.25,floor_t-0.1],[3.25,floor_t+eps],[0,floor_t+eps]
                        ]);
            }
    }
}

module rear_carrier() {
    difference() {
        linear_extrude(height=carrier_w) union() {
            circle(d=22.6);
            hull() {
                circle(d=17);
                rr(30,8.6,2,0,carrier_z0+4.3);
            }
        }
        r=bearing_seat_d/2;
        rotate_extrude() polygon([
            [0,-eps],[r,-eps],[r,5.10],[5.12,8.30],
            [5.12,8.5],[r,10.9],[r,carrier_w+eps],[0,carrier_w+eps]
        ]);
        for (a=[-carrier_bolt_a,carrier_bolt_a]) {
            translate([a,14,carrier_w/2])
                rotate([90,0,0]) cylinder(d=3.5,h=14+shaft_z-floor_top+eps);
            translate([a,14,carrier_w/2])
                rotate([90,0,0]) cylinder(d=6.4,h=26.3);
        }
    }
}

module nose_outline() {
    union() {
        rr(19,52,4,0,108.7);
        for (s=[-1,1]) {
            hull() {
                rr(11,10,2.9,s*nose_x,80);
                rr(13,12,3,s*23.5,95);
                rr(15,13,2.2,s*37,sensor_y);
            }
            hull() {
                rr(12,12,2.7,s*22,95);
                rr(14,12,3,s*l298_pitch_y/2,driver_y+l298_pitch_x/2);
            }
        }
        for (s=[-1,1]) rr(l298_pitch_y+12,12,3,0,driver_y+s*l298_pitch_x/2);
    }
}

module nose() {
    linear_extrude(height=nose_t) difference() {
        nose_outline();
        nose_anchors();
        for (s=[-1,1]) rr(9.6,7.5,1.65,s*37,sensor_y);
        for (sx=[-1,1],sy=[-1,1])
            rr(7,7,1.4,sx*l298_pitch_y/2,driver_y+sy*l298_pitch_x/2);
        for (sx=[-1,1],dy=[-7,7])
            rr(3.3,4.5,1.3,sx*6.5,driver_y+dy);
        for (s=[-1,1]) rr(5.5,12,2.2,s*15,driver_y);
    }
}

// Transform the bearing carrier and other shaft parts from print Z into X.
module outward(s,x,y,z) {
    multmatrix([[0,0,s,s*x],[1,0,0,y],[0,1,0,z],[0,0,0,1]]) children();
}

module inward(s,x,y,z) {
    multmatrix([[0,0,-s,s*x],[1,0,0,y],[0,1,0,z],[0,0,0,1]]) children();
}

module motor_reference(s) {
    color("#f0b437")
        box(motor_w,44,22.3,s*motor_x,front_y+10.72,motor_bottom,2.3);
    color("#a9b7c2") translate([s*motor_x,front_y+31.2,shaft_z])
        rotate([-90,0,0]) cylinder(d=18.2,h=22);
    color("#ece3d5") outward(s,motor_inner_x-9.1,front_y,shaft_z)
        cylinder(d=5.3,h=37);
    for (dz=[-8.65,8.65]) color("#98a2a8") {
        outward(s,motor_x+motor_w/2,motor_hole_y,shaft_z+dz)
            cylinder(d=5.6,h=1.65);
        inward(s,motor_inner_x-tower_t,motor_hole_y,shaft_z+dz)
            cylinder(d=6.35,h=2.4,$fn=6);
    }
}

module rear_carrier_reference(s) {
    outward(s,rear_carrier_inner_x,rear_axle_y,shaft_z) rear_carrier();
}

module rear_spindle_reference(s) {
    color("#adb9bd") outward(s,22,rear_axle_y,shaft_z) cylinder(d=5,h=50);
    for (dx=[0,11])
        color("#9aabb4") outward(s,rear_carrier_inner_x+dx,rear_axle_y,shaft_z)
            difference() {
                cylinder(d=16,h=5);
                translate([0,0,-eps]) cylinder(d=5,h=5+2*eps);
            }
    for (p=[[39,2.5],[57.5,4.3]])
        color("#b6b5a9") outward(s,p[0],rear_axle_y,shaft_z)
            difference() {
                cylinder(d=8,h=p[1]);
                translate([0,0,-eps]) cylinder(d=5,h=p[1]+2*eps);
            }
}

module belt_reference(s) {
    outward(s,belt_x-3,0,shaft_z) color("#3c444b")
        linear_extrude(height=6) difference() {
            slot([rear_axle_y,0],[front_y,0],2*(belt_pitch_r+0.65));
            slot([rear_axle_y,0],[front_y,0],2*(belt_pitch_r-0.68));
        }
}

module wheel_reference(s,y,is_tt) {
    inward(s,wheel_outer_x,y,shaft_z) {
        color("#18656a") if (is_tt) wheel_tt(tt_hub_clearance); else wheel_5mm(steel_hub_clearance);
        color("#232c35") tire_tpu();
    }
}

module wheels_and_drive() {
    for (s=[-1,1]) {
        motor_reference(s);
        rear_spindle_reference(s);
        color("#d19545") {
            inward(s,pulley_outer_x,front_y,shaft_z) pulley_tt(tt_hub_clearance);
            inward(s,pulley_outer_x,rear_axle_y,shaft_z) pulley_5mm(steel_hub_clearance);
        }
        belt_reference(s);
        wheel_reference(s,front_y,true);
        wheel_reference(s,rear_axle_y,false);
    }
}

module controller_reference(use_l298) {
    color("#63478b") box(28,55,1.6,esp_x,esp_y,floor_top+2.5,1.4);
    color("#bcc3c8") box(8,6,3,esp_x,esp_y-25.8,floor_top+4.1,0.8);
    color("#474d5a") box(15,21,6,-47,60,floor_top+0.3,1.5);
    if (!use_l298)
        color("#27836c") box(21,27,8,-47,33.5,floor_top+2.5,1.5);
}

module battery_reference() {
    color("#3d4b5a") box(43,76,5,0,battery_center_y,floor_top,2.2);
    for (x=[-10.1,10.1])
        color("#7a9bc8") translate([x,battery_center_y-32.5,floor_top+10.5])
            rotate([-90,0,0]) cylinder(d=18.4,h=65);
}

module driver_reference(use_l298) {
    pcb_z=nose_seat+nose_t+2.5;
    translate([0,driver_y,pcb_z]) rotate([0,0,90]) {
        if (use_l298) {
            color("#27845b") box(l298_pitch_x+10,l298_pitch_y+9,1.6,0,0,0,3.2);
            color("#30343b") box(13,26,15,18,0,1.6,1.5);
            color("#3672ab") {
                box(7,15,8,-19,0,1.6,1.5);
                for (dy=[-16,16]) box(10,7,8,-10,dy,1.6,1.5);
            }
        } else {
            color("#203755") box(12.7,20.3,1.6,0,0,-1.5,1);
            color("#292e38") box(5,5,1.6,0,0,0.1,1);
        }
    }
}

module sensor_reference() {
    y=sensor_y+sensor_y_offset;
    z=nose_seat-sensor_spacer-1.6;
    color("#326699") difference() {
        union() {
            box(128,15,1.6,0,y+4.7,z,1.25);
            plate_at(z,1.6) translate([0,y])
                polygon([[-22,9],[22,9],[11,28],[-11,28]]);
        }
        plate_at(z-eps,1.6+2*eps)
            holes([[-sensor_inner_hole_pitch/2,y],[sensor_inner_hole_pitch/2,y]],3.2);
    }
    color("#1e2934") {
        for (x=[-54,-28,28,54]) box(7,7,5.8,x,y+5,z-5.8,1);
        box(7,7,5.8,0,y+19,z-5.8,1);
    }
}

module bare(fan_ready=false) {
    color("#dee7ed") chassis(fan_ready);
    color("#32a295") translate([0,0,nose_seat]) nose();
    color("#dee7ed") for (s=[-1,1]) rear_carrier_reference(s);
}

module assembly(use_l298,fan_ready=false) {
    bare(fan_ready);
    wheels_and_drive();
    if (!fan_ready) battery_reference();
    controller_reference(use_l298);
    driver_reference(use_l298);
    sensor_reference();
}

assert(abs(rear_axle_y)<=2);
assert(battery_center_y>=30 && battery_center_y<=36);
assert(abs(sensor_y_offset)<=2);
assert(sensor_inner_hole_pitch>=68 && sensor_inner_hole_pitch<=80);
assert(l298_pitch_x>=36 && l298_pitch_x<=40);
assert(l298_pitch_y>=31 && l298_pitch_y<=36);

if (part=="chassis") translate([0,0,-floor_clearance]) chassis();
else if (part=="nose") nose();
else if (part=="rear_carrier") rear_carrier();
else if (part=="pulley_tt") pulley_tt(tt_hub_clearance);
else if (part=="pulley_5mm") pulley_5mm(steel_hub_clearance);
else if (part=="wheel_tt") wheel_tt(tt_hub_clearance);
else if (part=="wheel_5mm") wheel_5mm(steel_hub_clearance);
else if (part=="tire_tpu") tire_tpu();
else if (part=="drive_fit_gauge") drive_fit_gauge();
else if (part=="bare") bare();
else if (part=="assembly_l298") assembly(true);
else if (part=="assembly_drv8833") assembly(false);
else assert(false,"Choose a part from the Model section.");
