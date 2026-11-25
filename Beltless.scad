// MoseRase beltless, two front TT motors and two independent rear idlers.
// World coordinates use the same wheelbase, track and BFD mount as v3.
use <MyshachiPerehony.scad>

/* [Model] */
beltless_part = "assembled"; // [assembled,bare,chassis]
driver = "L298"; // [L298,DRV8833]

/* [Hidden] */
$fn = 40;
beltless_floor_z = 7;
beltless_nose_z = 15.65;
beltless_front_y = 70;
beltless_rear_y = 0;
beltless_axle_z = 30;
shaft_start_x = 36;
shaft_length = 36;
carrier_inboard_x = 41.5;
bearing_width = 5;
carrier_width = 16;
collar_width = 4.5;
bearing_clearance = 0.03;

module shaft_ring_reference(s, x, width, diameter, finish="#b6b5a9") {
    color(finish) outward(s,x,beltless_rear_y,beltless_axle_z)
        difference() {
            cylinder(d=diameter,h=width);
            translate([0,0,-bearing_clearance])
                cylinder(d=5.1,h=width+2*bearing_clearance);
        }
}

module idler_spindle_reference(s) {
    color("#adb9bd")
        outward(s,shaft_start_x,beltless_rear_y,beltless_axle_z)
            cylinder(d=5,h=shaft_length);
    for (x=[carrier_inboard_x,carrier_inboard_x+carrier_width-bearing_width])
        shaft_ring_reference(s,x,bearing_width,16,"#9aabb4");
    shaft_ring_reference(s,shaft_start_x,collar_width,10);
    shaft_ring_reference(s,shaft_start_x+collar_width,1,8);
    shaft_ring_reference(s,carrier_inboard_x+carrier_width,4.3,8);
}

module beltless_bare() {
    color("#dee7ed") chassis(false,true);
    color("#32a295") translate([0,0,beltless_nose_z]) nose();
    color("#dee7ed") for (s=[-1,1]) rear_carrier_reference(s);
}

module beltless_assembly(use_l298) {
    beltless_bare();
    for (s=[-1,1]) {
        motor_reference(s);
        idler_spindle_reference(s);
        wheel_reference(s,beltless_front_y,true);
        wheel_reference(s,beltless_rear_y,false);
    }
    battery_reference();
    controller_reference(use_l298);
    driver_reference(use_l298);
    sensor_reference();
}

if (beltless_part=="assembled") beltless_assembly(driver=="L298");
else if (beltless_part=="bare") beltless_bare();
else if (beltless_part=="chassis")
    translate([0,0,-beltless_floor_z]) chassis(false,true);
else assert(false,"Choose a beltless part.");
