// One-piece chassis. Only the front motor bogie rotates.
use <AxleDrive.scad>
use <MyshachiPerehony.scad>
part = "assembly"; // [assembly,bare,chassis,bogie]
angle = 0; // [-22:1:22]
driver = "L298"; // [L298,DRV8833]
$fn=48;

module front_bogie() {
    difference() {
        intersection() {
            axle_frame(true);
            translate([-60,-60,0]) cube([120,90,55]);
        }
        for(s=[-1,1])
            translate([s*24-4.2,-20,10.2]) cube([8.4,11,37]);
    }
}

module frame_body() {
    union() {
        rotate(180) translate([0,48,0]) axle_frame(false);
        // Join both rear deck towers below their removable battery shelf.
        for(s=[-1,1]) hull() {
            box(7,6,4,s*24,-33,38.5,1);
            box(13,7,5,0,-16,44,1);
        }
        box(14,144,5,0,53,44,2);
        for(s=[-1,1]) {
            hull() {
                box(14,8,5,0,114,44,2);
                box(10,9,5,s*37,124,44,2);
            }
            difference() {
                box(10,9,30,s*37,124,15.65,2);
                translate([s*37,124,15.62]) cylinder(d=2.6,h=9);
            }
        }
        // Controls sit above the tyre sweep on the fixed spine.
        box(13,8,13.1,0,34,48.9,1);
        box(12.6,8,13.1,0,70,48.9,1);
        translate([0,38,61.9]) panel(false);
    }
}

module backbone() {
    difference() {
        frame_body();
        for(s=[-1,1]) translate([s*24,-33,37]) cylinder(d=4.15,h=6.1);
    }
}

module assembly(full) {
    color("#dce4e7") backbone();
    rotate(180) translate([0,48,0]) {
        axle_hardware();
        color("#60a9a5") translate([0,0,43]) panel(true);
        if(full) {
            axle_rotation_parts();
            translate([0,-19,36]) battery_reference();
        }
    }
    rotate(angle) translate([0,48,0]) {
        color("#dda442") front_bogie();
        axle_hardware();
        if(full) axle_rotation_parts();
    }
    if(full) {
        steering_reference(angle);
        translate([0,20,0]) sensor_reference();
        translate([0,52-110,65.1-18.85]) driver_reference(driver=="L298");
        color("#63478b") box(28,55,1.6,35.8,52,67.6,1.4);
        color("#474d5a") box(15,21,6,-33,52,65.1,1.5);
    }
}

assert(abs(angle)<=22);
if(part=="chassis") translate([0,0,-7]) backbone();
else if(part=="bogie") translate([0,0,-7]) front_bogie();
else assembly(part=="assembly");
