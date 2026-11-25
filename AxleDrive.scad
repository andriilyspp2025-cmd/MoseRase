// MoseRase with one double-output TT per axle and articulated steering.
// Units are mm. Track surface is Z=0, front is +Y, steering pin is X=Y=0.
use <MyshachiPerehony.scad>
use <Drive.scad>

/* [Model] */
axle_part = "assembled"; // [assembled,bare,front,rear,battery_plate,controls_plate,coupler]
driver = "L298"; // [L298,DRV8833]
steering_angle = 0; // [-22:1:22]
tt_fit = 0.15; // [0:0.05:0.35]
shaft_fit = 0.15; // [0:0.05:0.35]

/* [Hidden] */
$fn = 48;
e = 0.02;
half_base = 48;
floor_z = 7;
floor_top = 10.2;
shaft_z = 30;
carrier_x = 32;
wheel_face = 62.3;
plate_z = 43;
plate_t = 3.2;
panel_ys = [-15,43];
servo_axis = [-23,-23];
horn_r = 11;
link_l = 37;
link_z = 35;
front_eye = [-12,14];

module axle_floor(is_front) {
    plate_at(floor_z,floor_top-floor_z) difference() {
        union() {
            rr(96,34,4,0,0);
            rr(27,68,4,0,13);
            for (s=[-1,1]) {
                rr(12,65,3,s*24,15);
                hull() {
                    rr(12,12,3,s*40,9);
                    rr(12,12,3,s*24,25);
                }
            }
            if (is_front) {
                hull() {
                    rr(18,17,4,0,-48);
                    rr(33,12,4,0,-19);
                    rr(15,14,3,-12,-34);
                }
                for (s=[-1,1]) hull() {
                    rr(12,12,3,s*37,62);
                    rr(12,12,3,s*24,40);
                }
            } else {
                hull() {
                    rr(22,12,3,0,-22);
                    rr(26,10,3,0,-13);
                }
                hull() {
                    rr(12,13,3,23,-34);
                    rr(14,13,3,24,-12);
                }
            }
        }
        for (s=[-1,1], y=[-10.5,10.5])
            translate([s*40,y]) circle(d=3.5);
        if (is_front) translate([0,-48]) circle(d=5.4);
        for (s=[-1,1],y=[0,29]) rr(3.5,9,1.6,s*18,y);
    }
}

module pivot_top() {
    difference() {
        union() {
            hull() {
                box(20,11,1,0,-22,floor_top-e,3);
                box(20,11,1,0,-31,11.2,3);
            }
            hull() {
                box(20,11,4.2,0,-31,11.2,3);
                box(20,17,4.2,0,-48,11.2,4);
            }
        }
        translate([0,-48,11.2-e]) cylinder(d=5.4,h=4.2+2*e);
    }
}

module servo_shelf() {
    // Micro servo body nominal 23 x 12.5. Slots let the mounting ears shift.
    difference() {
        union() {
            box(20,41,3.2,23,-20,24,3);
            for (y=[-5,-35])
                box(13,8,14,23,y,floor_top-e,1.7);
        }
        box(13.5,24,3.2+2*e,23,-20,24-e,1);
        plate_at(24-e,3.2+2*e)
            for (y=[-6,-34]) rr(2.5,4,1.1,23,y);
        for (y=[-6,-34])
            translate([23,y,19.5]) cylinder(d=1.65,h=4.7);
    }
}

module axle_frame(is_front) {
    difference() {
        union() {
            axle_floor(is_front);
            translate([-49,-70,0]) motor_tower();
            box(13,10,8.65+e,0,10.2,floor_top-e,1.1);
            for (s=[-1,1],y=panel_ys)
                box(8,9,plate_z-floor_top+e,s*24,y,floor_top-e,1.5);
            if (is_front) {
                box(9,10,23.3+e,-12,-34,floor_top-e,1.6);
                for (s=[-1,1])
                    box(10,12,5.45+e,s*37,62,floor_top-e,2);
                hull() for (s=[-1,1])
                    box(10,12,3.2+e,s*37,62,15.65-e,2);
            } else {
                pivot_top();
                servo_shelf();
            }
        }
        for (s=[-1,1], y=panel_ys)
            translate([s*24,y,plate_z-6]) cylinder(d=4.15,h=6+e);
        if (is_front) {
            translate([-12,-34,26.5]) cylinder(d=2.6,h=7.1);
            for (s=[-1,1])
                translate([s*37,62,15.65-e]) cylinder(d=3.4,h=3.2+2*e);
        }
    }
}

module panel_mounts() {
    for (s=[-1,1],y=panel_ys) translate([s*24,y]) circle(d=3.4);
}

module panel(for_battery) {
    linear_extrude(height=plate_t) difference() {
        if (for_battery) rr(54,80,4,0,14);
        else {
            rr(54,67,4,0,14);
            rr(30,58,3,35,14);
            rr(18,33,3,-33,14);
        }
        panel_mounts();
        if (for_battery) {
            for (s=[-1,1], y=[0,29]) rr(3.5,11,1.6,s*22,y);
            for (y=[0,29]) rr(24,12,3,0,y);
        } else {
            for (s=[-1,1], t=[-1,1])
                translate([s*16.75,14+t*19.25]) circle(d=3.4);
            for (x=[-7,7,23.5,47],y=[0,28]) rr(3.3,8,1.4,x,y);
            for (y=[4,24]) rr(10,3.3,1.3,-33,y);
            for (y=[0,29]) rr(11,7,2,0,y);
        }
    }
}

module coupler() {
    // Two opposed blind sockets. The steel shaft is retained by an M3 screw.
    difference() {
        rotate_extrude() polygon([
            [0,0],[7.1,0],[8,0.9],[8,19.6],[7.2,20.4],[0,20.4]
        ]);
        drive_cut(-e,9.6) drive_tt_profile(tt_fit);
        drive_cut(12.35,8.05+e) drive_d5_profile(shaft_fit);
        drive_clamp_cut(16.3,3.8,20.4,8);
    }
}

module axle_hardware() {
    color("#dee7ed") for (s=[-1,1])
        outward(s,carrier_x,0,shaft_z) rear_carrier();
}

module axle_rotation_parts() {
    translate([-49,-70,0]) motor_reference(1);
    for (s=[-1,1]) {
        color("#4b7279") outward(s,10.1,0,shaft_z) coupler();
        color("#bac3c9") outward(s,22.6,0,shaft_z) cylinder(d=5,h=40);
        for (p=[[30.5,1.5,8],[32,5,16],[43,5,16],[48,4.3,8]])
            color("#9aabb4") outward(s,p[0],0,shaft_z)
                difference() {
                    cylinder(d=p[2],h=p[1]);
                    translate([0,0,-e]) cylinder(d=5.04,h=p[1]+2*e);
                }
        inward(s,wheel_face,0,shaft_z) {
            color("#18656a") wheel_5mm(shaft_fit);
            color("#232c35") tire_tpu();
        }
    }
}

module section(is_front, full) {
    color("#dee7ed") axle_frame(is_front);
    axle_hardware();
    translate([0,0,plate_z]) color(is_front ? "#36a097" : "#60a9a5") panel(!is_front);
    if (full) {
        axle_rotation_parts();
        if (is_front) {
            translate([0,62-104,0]) sensor_reference();
            translate([0,14-110,plate_z+plate_t-18.85]) driver_reference(driver=="L298");
            color("#63478b") box(28,55,1.6,35.8,14,plate_z+plate_t+2.5,1.4);
            color("#474d5a") box(15,21,6,-33,14,plate_z+plate_t,1.5);
        } else translate([0,14-33,plate_z+plate_t-10.2]) battery_reference();
    }
}

module rod_between(a,b,z,d) {
    delta=b-a;
    translate([a.x,a.y,z]) rotate([0,90,atan2(delta.y,delta.x)])
        cylinder(d=d,h=norm(delta));
}

module steering_reference(angle) {
    eye = [front_eye.x*cos(angle)-front_eye.y*sin(angle),
           front_eye.x*sin(angle)+front_eye.y*cos(angle)];
    delta = eye-servo_axis;
    dist = norm(delta);
    assert(abs(link_l-horn_r)<dist && dist<link_l+horn_r);
    horn_angle = atan2(delta.y,delta.x) -
                 acos((dist*dist+horn_r*horn_r-link_l*link_l)/(2*dist*horn_r));
    horn_end = servo_axis+horn_r*[cos(horn_angle),sin(horn_angle)];
    color("#aab4be") translate([0,0,5.5]) cylinder(d=5,h=13.5);
    color("#435063") box(12.5,23,15,servo_axis.x,-28,11.7,1);
    color("#536681") box(12.5,32,2.2,servo_axis.x,-28,27.2,1.2);
    color("#435063") box(12.5,23,3,servo_axis.x,-28,29.4,1);
    color("#d4d9dd") translate([servo_axis.x,servo_axis.y,32.3])
        cylinder(d=5,h=3.8);
    color("#d4d9dd") rod_between(servo_axis,horn_end,link_z,4);
    color("#d4d9dd") rod_between(horn_end,eye,link_z,2);
}

assert(abs(steering_angle)<=22);
if (axle_part=="assembled" || axle_part=="bare") {
    full = axle_part=="assembled";
    rotate([0,0,steering_angle]) translate([0,half_base,0]) section(true,full);
    rotate([0,0,180]) translate([0,half_base,0]) section(false,full);
    if (full) steering_reference(steering_angle);
}
else if (axle_part=="front" || axle_part=="rear")
    translate([0,0,-floor_z]) axle_frame(axle_part=="front");
else if (axle_part=="battery_plate" || axle_part=="controls_plate")
    panel(axle_part=="battery_plate");
else if (axle_part=="coupler") coupler();
else assert(false,"Choose an axle-drive part.");
