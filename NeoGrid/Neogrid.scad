/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all non-Gridfinity parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Gridfinity components are licensed under the MIT License.


Documentation available at https://handsonkatie.com/

Change Log:
- 

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    Zack Freedman for his work on the original Gridfinity
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

/*[Material Size]*/
//Material Thickness (by mm)
Material_Thickness = 3.5; //.01
//Depth of the channel for the material to sit in.
Channel_Depth = 20; 

/*[Channel Customizations]*/
//Thickness of the walls of the channel (by mm)
Wall_Thickness = 4;

/*[Material Holding Options]*/
Retention_Spike = true;
//Adjust the size of the spike. Spike auto-calculates to 1/3 the thickness of the material.
Spike_Scale = 1;

/*[Straight Channel]*/
//Length of the channel (by mm)
Channel_Length = 42; 

/*[Vertical Trim Channel]*/
Show_Vertical_Trim = false;
//Length of the channel (by mm)
Total_Trim_Width = 42; 
Middle_Seam_Width = 5;
Total_Trim_Height = 20;

/*[Advanced]*/
//Size of the grid (by mm). 42mm by default for gridfinity. Other sized not tested. 
grid_size = 42;
grid_clearance = 0.5; //adjusted grid size for spacing between grids
//Additional channel length beyond center for partial channels. This allows slop in cutting dividers. 
Partial_Channel_Buffer = 3;
Part_Separation = 5;

/*[Hidden]*/
outside_radius = 7.5; //radius of the outside corner of the baseplate
inside_radius = 0.8; //radius of the inside corner of the baseplate
grid_x = 1;
grid_y = 1;

part_placement = grid_size/2+Part_Separation;

/*

BEGIN DISPLAYS

*/

left(part_placement*3){
    fwd(quantup(Channel_Length, grid_size)/2+Part_Separation) 
        NeoGrid_Straight_Thru_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
    back(Channel_Length/2+Part_Separation)
        NeoGrid_Straight_Thru_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size, Channel_Length = Channel_Length);
}
fwd(part_placement){
    left(part_placement)
        NeoGrid_X_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_X_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

back(part_placement){
    left(part_placement)
        NeoGrid_T_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_T_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

back(part_placement*3){
    left(part_placement)
        NeoGrid_Straight_End_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_Straight_End_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

fwd(part_placement*3){
    left(part_placement) 
        NeoGrid_L_Intersection_Base(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
    right(part_placement)
        NeoGrid_L_Intersection_Top(Material_Thickness, Channel_Depth = Channel_Depth, Wall_Thickness = Wall_Thickness, grid_size = grid_size);
}

if(Show_Vertical_Trim ) 
right(100)
diff()
cuboid([Total_Trim_Width, Wall_Thickness*2+Material_Thickness, Total_Trim_Height], anchor=BOT){
    //cutouts
    attach([LEFT, RIGHT], LEFT, inside=true, shiftout=0.01)
        cuboid([Total_Trim_Width/2-Middle_Seam_Width/2, Material_Thickness, Total_Trim_Height+0.02]);
    //chamfers
    edge_profile([BOT+FRONT, BOT+BACK, TOP+FRONT, TOP+BACK])
        mask2d_chamfer(Wall_Thickness/3);
}

/*
    
END DISPLAYS
    
*/

/*

BEGIN NEOGRID MODULES

*/

//channelDeleteTool([Material_Thickness, grid_size+0.02, Channel_Depth-Wall_Thickness+0.02]);

module channelDeleteTool(size, chamfer_edges = [BOT], spike_count = 1, anchor = CENTER, spin = 0, orient = UP){
    tag_scope()
    diff("spike"){
        cuboid(size, anchor=anchor, spin=spin, orient=orient){ //passthru attachables
                //material insertion chamfer 
                edge_profile_asym(chamfer_edges, corner_type="chamfer")
                    xflip() mask2d_chamfer(Wall_Thickness/3);
        if(Retention_Spike)
            //Retention Spike
            tag("spike") ycopies(n=spike_count, spacing=size[1]/2)attach([LEFT,RIGHT], BOT, inside=true, overlap=0.01, $fn=30)
                cyl(h=Material_Thickness/3*Spike_Scale,d2=0, d1=Material_Thickness/3*Spike_Scale*2);
        children();
        }
    }
}

//STRAIGHT CHANNELS

module NeoGrid_Straight_Thru_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42, Channel_Length = 42){
    diff(){
        //Channel Walls
        cuboid([Wall_Thickness*2+Material_Thickness, Channel_Length, Channel_Depth], anchor=BOT){ //Gridfinity Base
            //top chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3);
        //Removal tool for channel
        attach(TOP, BOT, inside=true, shiftout=0.01)
            channelDeleteTool([Material_Thickness, Channel_Length+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_Straight_Thru_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, Channel_Length = 42, grid_size = 42){
    //Straight Channel
    diff(){
        //Gridfinity Base
        gridfinity_bin_bottom_grid( x = 1, y = quantup(Channel_Length, grid_size)/grid_size, anchor=BOT)
        //Channel Walls
        attach(TOP, BOT, overlap=0.01)
            cuboid([ Wall_Thickness*2+Material_Thickness, Channel_Length-grid_clearance,  Channel_Depth], anchor=BOT){ //Gridfinity Base
                //bottom chamfer
                tag("keep") //must label keep due to chamfering out an addition and not a diff. 
                    edge_profile([BOT+FRONT, BOT+BACK])
                        xflip()mask2d_chamfer(5);
                //top chamfer
                    edge_profile([TOP+FRONT, TOP+BACK])
                        mask2d_chamfer(Wall_Thickness/3);
            //Removal tool for channel
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, Channel_Length+0.02,Channel_Depth+0.02]);
            }
    }
}

//X INTERSECTIONS

module NeoGrid_X_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Channel Walls
        zrot_copies([0,90]) 
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size, Channel_Depth], anchor=BOT){ //Gridfinity Base
                //top chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3);
            //Removal tool for channel
            zrot_copies([0,90]) 
                attach(TOP, BOT, inside=true, shiftout=0.01)
                    channelDeleteTool([Material_Thickness, grid_size+0.02, Channel_Depth-Wall_Thickness+0.02], spike_count=2);
        }
    }
}

module NeoGrid_X_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel chamf") //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        //Gridfinity Base 1x1 for all intersections.
        gridfinity_bin_bottom_grid(x=1,y=1, anchor=BOT){
        //Channel Wall Y
        attach(TOP, BOT, overlap=0.01) //attach to the top of the gridfinity base
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size-grid_clearance, Channel_Depth]){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(5); 
                //top inward chamfer
                    tag("chamf") edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall X
        attach(TOP, BOT)
            zrot(90) down(0.01)
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size-grid_clearance, Channel_Depth]){
            //bottom chamfer
                edge_profile_asym([BOT+LEFT, BOT+RIGHT])
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(5); 
            //top chamfer
                tag("chamf") edge_profile_asym([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        tag("channel")attach(TOP, TOP, shiftout=0.01)
            channelDeleteTool([Material_Thickness, grid_size+0.01, Channel_Depth+0.02], spike_count=2);
        tag("channel")zrot(90) attach(TOP, TOP, shiftout=0.01)
            channelDeleteTool([Material_Thickness, grid_size+0.01, Channel_Depth+0.02], spike_count=2);
        }//end gridfinity base
}

//T INTERSECTIONS
module NeoGrid_T_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Full Width Channel
        cuboid([Wall_Thickness*2+Material_Thickness, grid_size, Channel_Depth], anchor=BOT){
            //top chamfer
            edge_profile([BOT+LEFT, BOT+RIGHT])
                mask2d_chamfer(Wall_Thickness/3);
            //Removal tool - Full Width
            attach(TOP, BOT, inside=true, shiftout=0.01)
                channelDeleteTool([Material_Thickness, grid_size+0.02, Channel_Depth-Wall_Thickness+0.02], spike_count=2);
        }
        //Partial Width Channel
        zrot(90)
        fwd(Material_Thickness/2+Wall_Thickness-0.01)
        cuboid([Wall_Thickness*2+Material_Thickness, grid_size/2+Material_Thickness/2+Wall_Thickness, Channel_Depth], anchor=BOT+FRONT){ //Gridfinity Base
            //top chamfer
            edge_profile([BOT+LEFT, BOT+RIGHT])
                mask2d_chamfer(Wall_Thickness/3);
            //Removal tool - Partial
            attach(TOP, BOT, shiftout=0.01, inside=true, align=BACK)
                channelDeleteTool([Material_Thickness, grid_size/2++Material_Thickness/2+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_T_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel chamf") //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        //Gridfinity Base 1x1 for all intersections.
        gridfinity_bin_bottom_grid(x=1,y=1, anchor=BOT){
        //Channel Wall partial 
        attach(TOP, BOT, overlap=0.01, align=FRONT) up(0.01)//attach to the top of the gridfinity base
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size/2, Channel_Depth]){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(5); 
                //top inward chamfer
                    tag("chamf")edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall full width
        attach(TOP, BOT)
            zrot(90)
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size-grid_clearance, Channel_Depth]){
            //bottom chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(5); 
            //top chamfer
                tag("chamf")edge_profile([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        //channel clear partial
        tag("channel")attach(TOP, TOP, shiftout=0.01, align=FRONT)
            channelDeleteTool([Material_Thickness, grid_size/2+0.02, Channel_Depth+0.02]);
        //channel clear full length
        tag("channel")zrot(90) attach(TOP, TOP, shiftout=0.01)
            channelDeleteTool([Material_Thickness, grid_size+0.02, Channel_Depth+0.02], spike_count=2);
        }//end gridfinity base
}

//End Channels
module NeoGrid_Straight_End_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    diff(){
        //Channel Walls
            cuboid([ grid_size, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT){
            //top chamfer
                edge_profile([BOT+FRONT, BOT+BACK, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3);
        //Removal tool for channel
        attach(TOP, BOT, inside=true, shiftout=0.01, align=LEFT, spin=90)
                channelDeleteTool([Material_Thickness, grid_size/2+Partial_Channel_Buffer+0.02, Channel_Depth-Wall_Thickness+0.02]);
        }
    }
}

module NeoGrid_Straight_End_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //Straight Channel
    diff(){
        //Gridfinity Base
        gridfinity_bin_bottom_grid(x = 1, y = 1, anchor=BOT)
        //Channel Walls
        attach(TOP, BOT, overlap=0.01, align=LEFT)
            cuboid([grid_size - grid_clearance, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT){
                //bottom chamfer
                tag("keep") //must label keep due to chamfering out an addition and not a diff. 
                    edge_profile_asym([BOT+FRONT, BOT+BACK])
                        xflip()mask2d_chamfer(5);
                //top chamfer
                    edge_profile([TOP+FRONT, TOP+BACK])
                        mask2d_chamfer(Wall_Thickness/3);
                //Removal tool for channel
                attach(TOP, BOT, inside=true, shiftout=0.01, spin=90, align=LEFT)
                    channelDeleteTool([ Material_Thickness, grid_size/2+Partial_Channel_Buffer+0.02, Channel_Depth+0.02]);
            }
    }
}



module NeoGrid_L_Intersection_Top(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff(){ //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        //Channel Wall X axis
        back(Material_Thickness/2+Wall_Thickness)
        cuboid([Wall_Thickness*2+Material_Thickness, grid_size/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Channel_Depth], anchor=BOT+BACK){
            //inward chamfer
                edge_profile([BOT+LEFT, BOT+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer half the wall thickness
        }
        //Channel Wall Y axis
        right(Material_Thickness/2+Wall_Thickness)
        cuboid([grid_size/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Wall_Thickness*2+Material_Thickness, Channel_Depth], anchor=BOT+RIGHT){
        //inward chamfer
            edge_profile([BOT+FRONT, BOT+BACK])
                mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            tag("remove")
                attach(TOP, TOP, inside=true, shiftout=0.01, align=LEFT, spin=90)
                channelDeleteTool([ Material_Thickness, grid_size/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth-Wall_Thickness+0.02], chamfer_edges=TOP, anchor=BOT+RIGHT);

        }
        //clear the channels in both directions
        //channel clear partial
        tag("remove")
            up(Wall_Thickness) back(Material_Thickness/2)
            channelDeleteTool([Material_Thickness, grid_size/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth-Wall_Thickness+0.02], chamfer_edges=TOP, anchor=BOT+BACK);
    }
}


module NeoGrid_L_Intersection_Base(Material_Thickness, Channel_Depth = 20, Wall_Thickness = 4, grid_size = 42){
    //X Intersection Base
    diff("channel") //small trick here. External chamfers auto-apply the "remove" tag. This is a workaround to keep the chamfers on the channel walls by renaming the remove tag.
        //Gridfinity Base 1x1 for all intersections.
        gridfinity_bin_bottom_grid(x=1,y=1, anchor=BOT){
        //Channel Wall X axis
        attach(TOP, BOT, overlap=0.01, shiftout=-0.01, align=FRONT) //attach to the top of the gridfinity base
            cuboid([Wall_Thickness*2+Material_Thickness, grid_size/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Channel_Depth]){
                //bottom outward chamfer
                    edge_profile([BOT+LEFT, BOT+RIGHT])
                        xflip() //xflip to put the chamfer out rather than in
                            mask2d_chamfer(5); 
                //top inward chamfer
                    edge_profile([TOP+LEFT, TOP+RIGHT])
                        mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
            }
        //Channel Wall Y axis
        attach(TOP, BOT, shiftout=-0.01, align=LEFT)
            cuboid([grid_size/2+Wall_Thickness+Material_Thickness/2-grid_clearance/2, Wall_Thickness*2+Material_Thickness, Channel_Depth]){
            //bottom chamfer
                edge_profile_asym([BOT+FRONT, BOT+BACK, BOT+RIGHT], corner_type="sharp")
                    xflip() //xflip to put the chamfer out rather than in
                        mask2d_chamfer(5); 
            //top chamfer
                edge_profile([TOP+LEFT, TOP+RIGHT])
                    mask2d_chamfer(Wall_Thickness/3); //chamfer portion of the wall thickness
        }
        //clear the channels in both directions
        //channel clear partial
        tag("channel")attach(TOP, TOP, shiftout=0.01, align=FRONT)
            channelDeleteTool([Material_Thickness, grid_size/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth+0.02]);
        //channel clear full length
        tag("channel")attach(TOP, TOP, shiftout=0.01, align=LEFT, spin=90)
            channelDeleteTool([Material_Thickness, grid_size/2+Material_Thickness/2-grid_clearance/2+0.02, Channel_Depth+0.02]);
        }//end gridfinity base
}

/*

END NEOGRID MODULES

*/

/*

BEGIN GRIDFINITY MODULES

*/

module gridfinity_bin_bottom_grid(x, y, additionalHeight = 0.6, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[42*x-0.5, 42*y-0.5, 4.75+additionalHeight]){
        down((4.75+additionalHeight)/2)
        union(){
            up(4.75+additionalHeight/2-0.01)
                minkowski(){
                    cuboid([42*x-.5-outside_radius,42*y-0.5-outside_radius, additionalHeight]);
                    cyl(h=0.01, d=outside_radius, $fn=50);
                }
            translate([42/2-42/2*x,42/2-42/2*y,0])
                for (i = [0:x-1]){
                    for (j = [0:y-1]){
                        translate([i*42, j*42, 0]){
                            gridfinity_bin_bottom(anchor=BOT);
                        }
                    }
                }
        }
    children();
    }
    
}

//Gridfinity bin bottom profile with inside radius added (for minkowski)
base_profile_adj = [
                    [0,0], //start at inner profile
                    [inside_radius,0], //start at inner profile
                    [0.8+inside_radius, 0.8], //up and out 0.8
                    [0.8+inside_radius, 0.8 + 1.8], //up 1.8
                    [0.8 + 2.15+inside_radius, 0.8 + 1.8 + 2.15], //up and out 2.15
                    [0, 0.8 + 1.8 + 2.15] //back to inside
                ]; //Gridfinity Bin Bottom Specs

module gridfinity_bin_bottom(additionalHeight = 0, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[41.5, 41.5, 4.75]){
                translate(v = [-(35.6-inside_radius*2)/2,-(35.6-inside_radius*2)/2,-4.75/2]) 
                    rotate(a = [0,0,0]) 
                        minkowski() {
                            rotate_extrude($fn=50) 
                                    polygon(points=base_profile_adj); //Gridfinity Bin Bottom Specs
                            cube(size = [35.6-inside_radius*2,35.6-inside_radius*2,0.01+additionalHeight]);
                        }
    children();
    }
}
module gridfinity_base() {
    difference() {
        cube(size = [42,42,4.65]);
        /*
        baseplate delete tool
        This is a delete tool which is the inverse profile of the baseplate intended for Difference.
        Using polygon, I sketched the profile of the base edge per gridfinity specs.
        I then realized I need rounded corners with 8mm outer diameter, so I increased the x axis enough to have a 4mm total outer length (radius).
        I rotate extrude to created the rounded corner 
        Finally, I used minkowski (thank you Katie from "Hands on Katie") using a cube that is 42mm minus the 8mm of the edges (equalling 34mm)
        I also added separate minkowski tools to extend the top and the bottom for proper deleting
        */
        union() {
            //primary profile
            translate(v = [4,38,5.65]) 
                rotate(a = [180,0,0]) 
                    minkowski() {
                        rotate_extrude($fn=50) 
                                polygon(points = [[0,0],[4,0],[3.3,0.7],[3.3,2.5],[1.15,4.65],[0,4.65]]);
                        cube(size = [34,34,1]);
                    }
            //bottom extension bottom tool
            translate(v = [4,4,-2]) 
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4-2.85, $fn=50);
                        cube(size = [34,34,6]);
            }
            //top extension
                translate(v = [4,4,5])
                    minkowski() {
                        linear_extrude(height = 1) circle(r = 4, $fn=50);
                        cube(size = [34,34,2]);
            }
        }
    }
}