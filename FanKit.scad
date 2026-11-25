// MoseRase lower-mount suction module. Dimensions are in mm.
use <MyshachiPerehony.scad>

/* [Model] */
fan_part = "assembled"; // [assembled,bare,chassis,battery_deck,pan]
fan_count = 1; // [1,2]
driver = "L298"; // [L298,DRV8833]
inlet_d = 28; // [26:0.5:34]

/* [Hidden] */
$fn = 48;
fan_e = 0.03;
pan_center_y = 24;
pan_l = fan_count==1 ? 72 : 106;
fan_ys = fan_count==1 ? [24] : [-2,50];
floor_z = 7;
pan_z = 2.3;
pan_seat_z = 6.3;
pan_h = pan_seat_z-pan_z;
roof_t = 1.8;
tray_z = 25.2;
tray_t = 3.2;
fan_z = pan_seat_z+0.4;

module pan_mounts() {
    for (s=[-1,1],y=[23,58])
        translate([s*39.4,y]) children();
}

module tray_mounts() {
    for (s=[-1,1],p=[[34,-20.5],[35.8,80.55]])
        translate([s*p[0],p[1]]) children();
}

module fan_tie_slots() {
    for (y=fan_ys,s=[-1,1],dy=[-11,11])
        translate([s*32.7,y+dy]) children();
}

// World-related XY, Z=0 at the lower edge. Exported upside down.
module pan() {
    difference() {
        union() {
            plate_at(0,pan_h) difference() {
                rr(61,pan_l,3,0,pan_center_y);
                rr(57.6,pan_l-3.4,2.3,0,pan_center_y);
            }
            plate_at(pan_h-roof_t,roof_t) union() {
                rr(61,pan_l,3,0,pan_center_y);
                for (s=[-1,1], y=[23,58])
                    rr(22,10,2,s*34,y);
                fan_tie_slots() round_rect(11.5,8,1.5);
            }
        }
        pan_mounts() translate([0,0,pan_h-roof_t])
            rotate_extrude() polygon([
                [0,-fan_e],[3.18,-fan_e],[1.7,1.6],
                [1.7,roof_t+fan_e],[0,roof_t+fan_e]
            ]);
        plate_at(-fan_e,pan_h+2*fan_e) {
            for (y=fan_ys) translate([0,y]) circle(d=inlet_d);
            fan_tie_slots() round_rect(3.2,5,0.8);
        }
    }
}

module tray_outline() {
    union() {
        rr(51,89,3,0,33);
        for (s=[-1,1]) {
            hull() {
                rr(10,9,2,s*20,-9);
                translate([s*34,-20.5]) circle(d=10);
            }
            hull() {
                rr(10,9,2,s*20.2,76.5);
                rr(6.6,8.5,2,s*35.8,80.55);
            }
        }
    }
}

module battery_deck() {
    union() {
        linear_extrude(height=tray_t) difference() {
            tray_outline();
            for (y=[16,39,57]) rr(25,11,2.3,0,y);
            for (s=[-1,1]) {
                translate([s>0 ? 29.9 : -45,60]) square([15.1,18.01]);
                translate([s>0 ? 33.45 : -45,82.84]) square([11.55,20]);
                translate([s>0 ? 23.3 : -40,-10.7]) square([16.7,21.4]);
                for (y=[17,65]) rr(3.5,10,1.4,s*23.3,y);
            }
            tray_mounts() circle(d=3.4);
        }
        for (s=[-1,1])
            box(2.2,55,2.6,s*24.2,44,tray_t-fan_e,0.7);
        for (y=[-9,75])
            box(24,1.8,2.1,0,y,tray_t-fan_e,0.6);
    }
}

// Envelope with a closed top, underside intake, and a side exhaust opening.
module fan_reference(y,s) {
    color("#343d46") difference() {
        box(50,50,15,0,y,fan_z,4);
        translate([0,y,fan_z-fan_e]) cylinder(d=31,h=14.4);
        translate([s>0 ? 14 : -26,y-13,fan_z+2])
            cube([12,19,11]);
    }
    color("#76838d") translate([0,y,fan_z+7]) cylinder(d=16,h=2);
}

module lower_module() {
    color("#428c85") translate([0,0,pan_z]) pan();
    color("#61aa9e") translate([0,0,tray_z]) battery_deck();
}

assert(fan_count==1 || fan_count==2);
assert(inlet_d>=26 && inlet_d<=34);
if (fan_part=="chassis") translate([0,0,-floor_z]) chassis(true);
else if (fan_part=="pan") translate([0,0,pan_h]) rotate([0,180,0]) pan();
else if (fan_part=="battery_deck") battery_deck();
else if (fan_part=="bare") { bare(true); lower_module(); }
else if (fan_part=="assembled") {
    assembly(driver=="L298",true);
    lower_module();
    translate([0,0,tray_z+tray_t-10.2]) battery_reference();
    for (i=[0:len(fan_ys)-1]) fan_reference(fan_ys[i],i==0 ? 1 : -1);
}
else assert(false,"Choose a fan kit part.");
