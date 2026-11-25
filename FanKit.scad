// Removable negative-pressure chamber for MoseRase v3. All dimensions in mm.
use <MyshachiPerehony.scad>

/* [Model] */
fan_part = "assembled"; // [assembled,bare,chassis,pan,duct,collector,lid]
fan_count = 1; // [1,2]
driver = "L298"; // [L298,DRV8833]
inlet_d = 28; // [26:0.5:34]

/* [Hidden] */
$fn = 48;
fan_e = 0.03;
kit_center_y = 37;
duct_x = 26.3;
floor_bottom_z = 7;
floor_top_z = 10.2;
collector_z = 39;
pan_z = 2.6;
pan_h = floor_bottom_z-pan_z;
pan_roof = 1.55;
duct_h = collector_z-floor_top_z;
cup_h = 8.6;
cup_floor = 2;
lid_t = 2.4;
cup_width = 61;
cup_l = fan_count==1 ? 60 : 111;
fan_ys = fan_count==1 ? [kit_center_y] : [kit_center_y-26,kit_center_y+26];
ear_x = 33;
ear_dy = fan_count==1 ? 24 : 33;

module stack_holes() {
    holes([for (s=[-1,1], y=[17.5,56.5]) [s*duct_x,y]],3.4);
}

module inlets_from_ducts() {
    for (s=[-1,1]) rr(6,27,1,s*duct_x,kit_center_y);
}

module pan() {
    difference() {
        union() {
            plate_at(0,pan_h) difference() {
                rr(66,52,3,0,kit_center_y);
                rr(62.6,48.6,2.4,0,kit_center_y);
            }
            plate_at(pan_h-pan_roof,pan_roof) rr(66,52,3,0,kit_center_y);
            for (s=[-1,1], y=[17.5,56.5])
                box(7.2,7.2,pan_roof+0.55,s*duct_x,y,pan_h-pan_roof-0.55,1);
        }
        plate_at(-fan_e,pan_h+2*fan_e) {
            stack_holes();
            inlets_from_ducts();
        }
    }
}

// One model for both side risers. The long end holes are open through the print Z.
module duct() {
    linear_extrude(height=duct_h) difference() {
        round_rect(8.4,46,1.4);
        round_rect(6,27,1);
        holes([[0,-19.5],[0,19.5]],3.4);
    }
}

module lid_mount_points() {
    for (s=[-1,1],t=[-1,1])
        translate([s*ear_x,kit_center_y+t*ear_dy]) children();
}

module cup_ears() {
    lid_mount_points() circle(d=9);
}

module collector() {
    difference() {
        union() {
            plate_at(0,cup_h) difference() {
                rr(cup_width,cup_l,4,0,kit_center_y);
                rr(cup_width-3,cup_l-3,3,0,kit_center_y);
            }
            plate_at(0,cup_floor) rr(cup_width,cup_l,4,0,kit_center_y);
            plate_at(0,cup_h) cup_ears();
        }
        plate_at(-fan_e,cup_floor+2*fan_e) {
            stack_holes();
            inlets_from_ducts();
        }
        plate_at(-fan_e,cup_h+2*fan_e)
            lid_mount_points() circle(d=3.4);
    }
}

module lid() {
    linear_extrude(height=lid_t) difference() {
        union() {
            rr(cup_width,cup_l,4,0,kit_center_y);
            cup_ears();
            for (y=fan_ys,s=[-1,1],dy=[-13,13])
                rr(12,8,2,s*31.5,y+dy);
        }
        for (y=fan_ys) translate([0,y]) circle(d=inlet_d);
        lid_mount_points() circle(d=3.4);
        for (y=fan_ys,s=[-1,1],dy=[-13,13])
            rr(3.4,5,1,s*34.4,y+dy);
    }
}

module fan_reference(y) {
    z=collector_z+cup_h+lid_t+1;
    color("#313840") difference() {
        box(50,50,15,0,y,z,4);
        translate([0,y,z-fan_e]) cylinder(d=31,h=14.4);
    }
    color("#465360") box(13,20,12,23,y+13,z+1,1.2);
    color("#71838f") translate([0,y,z+7]) cylinder(d=16,h=2);
}

module kit() {
    color("#3c8e86") translate([0,0,pan_z]) pan();
    for (s=[-1,1])
        color("#3c8e86") translate([s*duct_x,kit_center_y,floor_top_z]) duct();
    color("#52a6a0") translate([0,0,collector_z]) collector();
    color("#6ac0b7") translate([0,0,collector_z+cup_h]) lid();
}

assert(fan_count==1 || fan_count==2);
assert(inlet_d>=26 && inlet_d<=34);
if (fan_part=="chassis") translate([0,0,-floor_bottom_z]) chassis(true);
else if (fan_part=="pan") translate([0,0,pan_h]) rotate([0,180,0]) pan();
else if (fan_part=="duct") duct();
else if (fan_part=="collector") collector();
else if (fan_part=="lid") lid();
else if (fan_part=="bare") { bare(true); kit(); }
else if (fan_part=="assembled") {
    assembly(driver=="L298",true);
    kit();
    for (y=fan_ys) fan_reference(y);
}
else assert(false,"Choose a fan kit part.");
