// LM8UU bushing holder derived from: http://www.thingiverse.com/thing:23041

include <util.scad>;
use <timing_belts.scad>;

m3_size = 3;
m3_nut_size = 5.5;
m3_head_size=5.5;
m3_head_height=3;
m3_nut_height = 2.54;
m6_nut_size = 10;
m6_size = 6;
m4_size = 4;
m8_nut_size = 13;
rod_size = 8;
rod_nut_size = 15; //12 for M6, 15 for M8
motor_shaft_size = 5;
bearing_size = 15; //12 for LM6UU, 15 for LM8UU,LM8SUU
bearing_length = 24; //19 for LM6UU, 17 for LM8SUU, 24 for LM8UU
motor_screw_spacing = 31; //26 for NEMA14, 31 for NEMA17
motor_shaft_bevel_diameter = 22;
motor_casing = 45; //38 for NEMA14, 45 for NEMA17
motor_wiggle=5;
x_rod_spacing = 55;
z_rod_spacing = 30 ;
belt_thickness=1.5;
belt_tooth_depth=0.5;
idler_pulley_size = 22; // 22 for 636/608 bearing
idler_pulley_width = 8; // 8 for 636/608
idler_pulley_axis_diameter = m4_size;
idler_pulley_nut_size = m6_nut_size; // m6 for 636 bearing
motor_pulley_size = 12;
pulley_radius_difference = (idler_pulley_size-motor_pulley_size)/2+belt_tooth_depth;

// ratio for converting diameter to apothem
da6 = 1 / cos(180 / 6) / 2;
da8 = 1 / cos(180 / 8) / 2;

module leadscrew_coupler() difference() {
	linear_extrude(height = 10 + rod_nut_size / 2 + 1, convexity = 5) difference() {
		circle(motor_screw_spacing / 2 - 1);
		polyhole(motor_shaft_size * da6, $fn = 6);
	}
	translate([0, 0, (m3_nut_size+0.5) / 2]) rotate([-90, 0, 90]) {
		cylinder(r = m3_size * da6, h = motor_screw_spacing / 2 + 1);
		%rotate(90) cylinder(r = (m3_nut_size+0.5) / 2, h = 5.5, $fn = 6);
		translate([0, 0, 12]) cylinder(r = m3_size * da6 * 2, h = motor_screw_spacing / 2);
		translate([-(m3_nut_size+0.5) / da6 / 4, -(m3_nut_size+0.5) / 2, 0]) cube([(m3_nut_size+0.5) / da6 / 2, (m3_nut_size+0.5) + 1, 5.7]);
	}
	translate([0, 0, 10]) cylinder(r = rod_nut_size / 2, h = rod_nut_size + 1, $fn = 6);
	//translate([0, 0, -1]) cube(100);
}

module lm8uu_retainer_x(thickness=6) {
    outer_size=bearing_size+2*thickness;
    length=3*bearing_length/4;
    screw_offset=(bearing_size+thickness)/2;
    base_offset=bearing_size/2-2;
    difference() {
        union() {
            cylinder(r=outer_size/2-thickness/2, h=length);
            translate([0, -outer_size/2, 0]) cube([bearing_size/2, outer_size, length]);
        }
        translate([0, 0, -1]) {
            #polyhole(d=bearing_size+0.25, h=length+2);
            translate([0, -bearing_size/2, 0]) cube([bearing_size/2, bearing_size, length+2]);
            translate([base_offset, -(outer_size/2+1), 0]) cube([outer_size, outer_size+2, length+2]);
        }
        for (i = [-1,1]) {
            #translate([base_offset, i*screw_offset, length/2]) rotate([0, 90, 0]) polyhole(d=m3_size+0.25, h=40, center=true);
            #translate([0, i*screw_offset, length/2]) cube([m3_nut_height+0.25, thickness+0.2, m3_nut_size+0.25], center=true);
        }
    }
}

module lm8uu_retainer_y(body_width=21, gap_width=10, body_height=18, body_length=25, plate_height=7, nut_wall_size=3) {
    ridge_distance=(17.5+17.5-2*1.1)/2;
    ridge_offset=ridge_distance/2;
    rotate([90,0,90]) difference() {
        union() {
            // base
            #translate([-body_width/2,-body_length/2,-(plate_height-2)])
                cube([body_width,body_length,plate_height+1]);
            // body
            translate([-body_width/2,-body_length/2,0])
                cube([body_width,body_length,body_height]);
        }
        translate([0,0,bearing_size/2+2]) {
        // lm8uu hole
            difference() {
                rotate([90,0,0]) polyhole(d=bearing_size+0.25, h=body_length+0.1, center=true);
                rotate([90,0,0]) for (i = [-ridge_offset, ridge_offset]) {
                    translate([0, 0, i]) rotate_extrude() translate([(bearing_size+0.25)/2, 0, 0]) circle(r=0.5, $fn=7);
                }
            }
            // top gap
            translate([0, 0, body_height/2]) cube([gap_width-1,body_length+0.1,body_height],center=true);
            
        }
        // screw hole
        translate([0, 0, -(plate_height-2)/2])
            polyhole(d=m3_size+0.5, h=plate_height+10, center=true);
        translate([0, 0, nut_wall_size-(plate_height-2)])
            hexagon(size=m3_nut_size+0.5, h=plate_height+1);
    }
}

module 608_adapter(center_hole_d=idler_pulley_axis_diameter+0.25, border_d=idler_pulley_size+belt_thickness+1, border_bottom_h=2, border_top_h=1.5,
                   shim_d=-1, shim_h=0.3, bearing_width=7, bearing_hole_d=8) {
    shim_d=shim_d < 1 ? center_hole_d+8 : shim_d;
    total_height=border_bottom_h+border_top_h+shim_h*2+bearing_width;
    difference() {
        union() {
            cylinder(r=border_d/2, h=border_bottom_h);
            cylinder(r=shim_d/2, h=border_bottom_h+shim_h);
            cylinder(r=bearing_hole_d/2, h=border_bottom_h+shim_h+bearing_width/2, $fn=60);
        }
        #translate([0, 0, -1]) polyhole(d=center_hole_d, h=total_height+2);
    }
    translate([0, 25, 0]) difference() {
        difference() {
            union() {
                cylinder(r=border_d/2, h=border_top_h);
                cylinder(r=shim_d/2, h=border_top_h+shim_h);
                cylinder(r=bearing_hole_d/2, h=border_top_h+shim_h+bearing_width/2, $fn=60);
            }
            #translate([0, 0, -1]) polyhole(d=center_hole_d, h=total_height+2);
        }
    }
}

module timing_belt_trench(height=10) {
    union() {
        translate([1.75, 0, 0]) belt_length(profile = "T2.5", belt_width = height, n = 15, backing_thickness_plus=0.35);
        translate([0, 0, -0.5]) rotate([45, 0, 0]) cube([15*2.5, 2, 2]);
        rotate([0, 0, -90]) mirror([0, 1, 0]) {
            translate([1.75, 0, 0])  belt_length(profile = "T2.5", belt_width = height, n = 15, backing_thickness_plus=0.35);
            translate([0, 0, -0.5]) rotate([45, 0, 0]) cube([15*2.5, 2, 2]);
        }            
        translate([4, -4, 0]) difference() {
            translate([-4, 0, 0]) cube([4, 4, height]);
            cylinder(r=4, h=height, $fn=60);
        }
    }
}
module timing_belt_trap_y(width=10, length=40, height=7, base_thickness=10, nut_wall_size=3, board_thickness=5.5) {
    difference() {
        union() {
            // body
            translate([-length/2, -width/2, 0]) cube([length, width, height+base_thickness]);
            translate([0, 0, height+base_thickness]) rotate([0, 0, 90]) linear_extrude(file="Y anchor interlock.dxf", layer="0", height=board_thickness);
        }
        // bolt hole+nut trap
        translate([0, 0, height+base_thickness+0.3-nut_wall_size]) polyhole(d=m3_size+0.5, h=nut_wall_size);
        translate([0, 0, -1]) hexagon(size=m3_nut_size+0.5, h=height+base_thickness+1-nut_wall_size);
        // force-bearing trench
        #translate([5, 0, -1]) timing_belt_trench(height=height+1);
        #mirror([1, 0, 0]) translate([5, 0, -1]) timing_belt_trench(height=height+1);
    }
}

module timing_belt_trap_x(corner_radius=4, width=10, length=20, height=7, base_thickness=3) {
    difference() {
        // body
        translate([corner_radius-width/2, corner_radius-width/2, 0]) minkowski() {
            cube([length+width-2*corner_radius, width-2*corner_radius, height+base_thickness]);
            cylinder(r=corner_radius, h=0.0001);
        }
        // Hole for M4 bolt
        translate([0, 0, -1]) polyhole(d=m4_size+0.5, h=height+base_thickness+2);
        // force-bearing trenches
        #translate([width/2, 0, -1]) timing_belt_trench(height=height+1);
    }
}

module endstop_holder(z=false, height=10, thickness=3, rod_size=8, bolt_offset=5) {
    inner_radius = rod_size/2;
    module clamp(height=height, inner_radius=rod_size/2, thickness=thickness, bolt_offset=bolt_offset) {
        channel_width = 4*rod_size/5;
        channel_length = 12;
        outer_radius = inner_radius+thickness;
        difference() {
            union() {
                cylinder(h=height, r=outer_radius, $fn = 20);
                translate([0, -outer_radius, 0]) cube([channel_length, outer_radius*2, height]);
            }
            #translate([0, -channel_width/2, -1]) cube([channel_length+1, channel_width, height+2]);
            #translate([0, 0, -1]) cylinder(h=height+2, r=inner_radius, $fn = 18);
            #translate([channel_length-bolt_offset, 0, height/2]) rotate([90, 0, 0]) cylinder(h=2*outer_radius+2, r=m3_size/2, center=true, $fn=10);
            #translate([channel_length-bolt_offset, -(outer_radius+1), height/2]) rotate([-90, 0, 0]) hexagon(m3_nut_size, 3);
        }
    }
    module cradle(thickness=thickness, endstop_width=20, endstop_height=10, endstop_thickness=6, endstop_hole_size = 2.5, endstop_hole_separation = 9, endstop_hole_offset=2) {
        length = endstop_width+0.5;
        width = endstop_thickness+0.25;
        outer_length = length+2*thickness;
        outer_width = width+2;
        translate([-(outer_length/2+inner_radius), -inner_radius, 0]) {
            union() {
                difference() {
                    translate([-(outer_length/2), 0, 0]) cube([outer_length, outer_width+thickness, height]);
                    #translate([-length/2, thickness, -1]) cube([length, width, height+2]);
                    translate([-(length/2), thickness, -1]) cube([1, outer_width+1, 2*height/3]);
                    translate([length/2-1, thickness, -1]) cube([1, outer_width+1, 2*height/3]);
                }
                translate([endstop_hole_separation/2, thickness-0.3, endstop_hole_offset]) sphere(r=endstop_hole_size/2, $fn=6);
                translate([-endstop_hole_separation/2, thickness-0.3, endstop_hole_offset]) sphere(r=endstop_hole_size/2, $fn=6);
                translate([endstop_hole_separation/2, thickness+width+0.3, endstop_hole_offset]) sphere(r=endstop_hole_size/2, $fn=6);
                translate([-endstop_hole_separation/2, thickness+width+0.3, endstop_hole_offset]) sphere(r=endstop_hole_size/2, $fn=6);
            }
        }
    }
    union() {
        clamp();
        if (z) {
            mirror([0, 1, 0]) translate(z ? [inner_radius, inner_radius*2, 0]: [0, 0, 0]) cradle();
        } else {
            cradle();
        }
    }
}

module z_bolt_holder(anchor_width=26, anchor_height=11, anchor_hole_separation=18, anchor_hole_vert_offset=5, bridge_thickness=4, board_thickness=5.5, board_separation=12,
                        cylinder_d=8, cylinder_h=10) {
    module half_body() {
        union() {
            translate([-anchor_width/2, 0, 0]) cube([anchor_width/2, board_thickness, anchor_height]);
            translate([-(anchor_width/2-bridge_thickness), 0, anchor_height]) {
                rotate([-90, 0, 0]) cylinder(r=bridge_thickness, h=board_thickness);
                cube([anchor_width/2-bridge_thickness, board_thickness, bridge_thickness]);
            }
            translate([-(board_separation-1)/2, 0, anchor_height]) cube([(board_separation-1)/2, board_thickness*2+cylinder_d, bridge_thickness]);
            translate([-(board_separation-1)/2, board_thickness*2+0.5, anchor_height-bridge_thickness]) cube([(board_separation-1)/2, cylinder_d-0.5, bridge_thickness*2]);
        }
    }
    difference() {
        union() {
            half_body();
            mirror([1, 0, 0]) half_body();
            translate([0, board_thickness*2+cylinder_d/2, anchor_height+bridge_thickness]) cylinder(r=cylinder_d/2, h=cylinder_h);
        }
        for (i=[-1,1]) {
            #translate([i*anchor_hole_separation/2, -1, anchor_hole_vert_offset]) rotate([-90, 0, 0]) polyhole(d=m3_size+0.20, h=board_thickness+2);
        }
        #translate([0, board_thickness*2+cylinder_d/2, anchor_height-(bridge_thickness+1)]) polyhole(d=m3_size+1, h=cylinder_h+2*bridge_thickness-2);
        #translate([0, board_thickness*2+cylinder_d/2, anchor_height-(bridge_thickness+1)+cylinder_h+2*bridge_thickness-1.7]) polyhole(d=m3_size, h=cylinder_h+2*bridge_thickness+2);
    }
}