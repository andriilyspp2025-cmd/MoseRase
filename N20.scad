// Four independent GA12-N20 motors. Millimetres; ground at Z=0, front +Y.
use <MyshachiPerehony.scad>
use <Drive.scad>
part="assembly"; // [assembly,bare,chassis,adapter,wheel,gauge]
removable=false;
driver="L298"; // [L298,dual_DRV8833]
use_plate=removable || driver=="dual_DRV8833";
l298_x=33.5;
l298_y=38.5;
sensor_shift=0; // [-4:1:4]
shaft_allowance=0.12;
motor_pitch_y=6;
motor_pitch_z=9;
$fn=48;
e=0.025;
floor_z=7;
floor_t=3;
axles=[-35,35];
driver_y=69;
module driver_holes(d) {
    for (s=[-1,1],t=[-1,1]) translate([s*l298_x/2,driver_y+t*l298_y/2]) circle(d=d);
}
module footprint(mount_plate=false) {
    difference() {
        union() {
            rr(47,86,4,0,0);
            for(s=[-1,1]) {
                rr(32,83,4,s*38,0);
                for(y=axles) rr(18,16,3,s*47,y);
                hull() {
                    rr(18,12,3,s*34,34);
                    rr(16,10,3,s*20,91);
                    rr(10,13,3,s*37,104);
                }
            }
            for(y=[50,88]) rr(52,10,3,0,y);
        }
        for(y=[-25,0,25]) rr(25,14,3,0,y);
        for(s=[-1,1],y=[-16,16]) rr(3.5,9,1.4,s*22,y);
        for(s=[-1,1],x=[29,49],y=[-16,16]) rr(3.3,7,1,s*x,y);
        for(s=[-1,1]) rr(10,12,2,s*39,0);
        if(mount_plate) for(s=[-1,1]) translate([s*23,69]) circle(d=3.4);
    }
}
module frame(modular) {
    difference() {
        union() {
            plate_at(floor_z,floor_t) intersection() {
                footprint(modular);
                translate([-64,-48]) square([128,140]);
            }
            for(y=[-40,40]) box(24,2,3,0,y,9.97,0.7);
            for(y=[-19,19]) box(20,4,2.04,39,y,9.96,1);
            for(s=[-1,1]) {
                for(y=axles) {
                    box(3,15,28,s*53.5,y,9.97,1);
                    // Gearbox rests on a saddle; strap is optional.
                    box(9,9,14.02,s*47,y,9.98,1);
                }
                for(y=[-32,32]) box(2,11,3,s*23,y,9.97,0.7);
                hull() {
                    box(10,6,3,s*23,89,9.95,1.5);
                    box(10,8,3,s*37,99,15.65,1.5);
                }
                box(10,18,3,s*37,104,15.65,1.8);
                if(modular) hull() {
                    box(9,10,3,s*23,69,7,2);
                    box(9,10,3,s*30,65,7,2);
                }
            }
            if(!modular) plate_at(9.96,3.54) driver_holes(7);
        }
        for(s=[-1,1],y=axles) outward(s,51.8,y,30) {
            cylinder(d=4.5,h=3.5);
            for(t=[-1,1],u=[-1,1]) translate([t*motor_pitch_y/2,u*motor_pitch_z/2,0])
                cylinder(d=1.85,h=3.5);
        }
        for(s=[-1,1]) plate_at(6.9,12)
            translate([s*37,104]) round_rect(3.5,11.5,1.7);
        if(modular) for(s=[-1,1]) translate([s*23,69,6.9]) cylinder(d=3.4,h=3.3);
        if(!modular) plate_at(6.9,6.8) driver_holes(3.4);
    }
}
module adapter() {
    difference() {
        union() {
            linear_extrude(height=2.4) difference() {
                union() {
                    for(s=[-1,1]) hull() {
                        translate([s*23,69]) circle(d=9);
                        for(t=[-1,1]) translate([s*l298_x/2,69+t*l298_y/2]) circle(d=8);
                    }
                    rr(49,7,2,0,69);
                }
                for(s=[-1,1]) translate([s*23,69]) circle(d=3.4);
            }
            plate_at(2.37,3.53) driver_holes(7);
        }
        plate_at(-e,6) driver_holes(2.6);
    }
}
// Two 12.7 x 20.3 mm carriers, retained individually with insulating ties.
module drv_adapter() {
    linear_extrude(height=2.4) difference() {
        union() {
            rr(42,27,3,0,driver_y);
            rr(55,9,4,0,driver_y);
        }
        for(s=[-1,1]) {
            translate([23*s,driver_y]) circle(d=3.4);
            for(dx=[-8,8],dy=[-5,5])
                rr(2.2,3.8,0.7,s*10+dx,driver_y+dy);
        }
    }
    for(s=[-1,1],dy=[-7,7])
        box(6,4,3.53,s*10,driver_y+dy,2.37,0.7);
}
module selected_adapter() {
    if(driver=="dual_DRV8833") drv_adapter(); else adapter();
}
module drv_pair() {
    for(s=[-1,1]) {
        color("#284d78") box(12.7,20.3,1.6,s*10,driver_y,15.9,0.7);
        color("#30343b") box(5,5,1.3,s*10,driver_y,17.5,0.4);
    }
}
module socket() {
    r=(3+shaft_allowance)/2;
    intersection() {circle(r=r); translate([-r,-r]) square([r+1+shaft_allowance/2,2*r]);}
}
module wheel() {
    difference() {
        drive_wheel_body();
        drive_cut(-e,10.1) socket();
        drive_clamp_cut(7.2,3.8,10,10.5);
        translate([0.85,0,7.2]) rotate([0,90,0]) cylinder(d=3.25,h=8);
    }
}
module mock_motor(s,y) {
    color("#ba9753") outward(s,43,y,30) translate([-5,-6,0]) cube([10,12,9]);
    color("#adb7c1") outward(s,26,y,30) translate([-5,-6,0]) cube([10,12,17]);
    color("#c6b899") outward(s,52,y,30) cylinder(d=3,h=9.27);
}
module scene(full) {
    color("#c9dae1") frame(use_plate);
    if(use_plate) color("#278f86") translate([0,0,10]) selected_adapter();
    if(full) {
        for(s=[-1,1],y=axles) {
            mock_motor(s,y);
            inward(s,67.4,y,30) {
                color("#18656a") wheel();
                color("#252c32") tire_tpu();
            }
        }
        translate([0,-33,-0.2]) battery_reference();
        color("#654d8c") box(28,55,1.6,39,0,12,1);
        color("#454f58") box(15,21,6,-39,13,10,1.5);
        color("#527966") box(18,22,6,-39,-13,10,1.5);
        if(driver=="dual_DRV8833") drv_pair();
        else translate([0,driver_y-110,(removable ? 15.9 : 13.5)-21.35]) driver_reference(true);
        translate([0,sensor_shift,0]) sensor_reference();
    }
}
if(part=="chassis") translate([0,0,-7]) frame(use_plate);
else if(part=="adapter") selected_adapter();
else if(part=="wheel") wheel();
else if(part=="gauge") difference(){cylinder(d=12,h=4);drive_cut(-e,4.1) socket();}
else scene(part=="assembly");
