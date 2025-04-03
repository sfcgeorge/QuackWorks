/* 
Deskware
Design by Hands on Katie
OpenSCAD by BlackjackDuck (Andy)
openGrid by David D

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025- 
    - Initial release

Credit to 
    @David D on Printables for openGrid
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
*/

include <BOSL2/std.scad>

/*[Core Section Dimensions]*/
//Width (in mm) from riser to riser measured from the center
Core_Section_Width = 192; //[108:84:948]
//Depth (in mm) from front of the riser to the rear of the backer
Core_Section_Depth = 196.5;
//Height of the core section from the bottom of the riser to the bottom of the base plate
Core_Section_Height = 80;



/*[Riser Slide]*/
//Width (and rise of angle) of the slide recess
Slide_Width = 4;
//Total height of the slide recess
Slide_Height = 10.5;
//Vertical distance between slides
Slide_Vertical_Separation = 40;
//Distance from the bottom of the riser to the bottom of the slide
Slide_Distance_From_Bottom = 11.75;
//Minimum clearance required for a top of a slide to the top of the riser
Slide_Minimum_Distance_From_Top = 17.75;

/*[Base Plate]*/
Base_Plate_Front_Overhang = 10.5;
Base_Plate_Width = Core_Section_Width;
Base_Plate_Depth = Core_Section_Depth + 10.5;

/*[Advanced]*/
clearance = 0.15;
openGridSize = 28;

/*[Hidden]*/
///*[Riser]*/
Riser_Depth = Core_Section_Depth - 7.5;
Riser_Height = Core_Section_Height;
Riser_Width = 18;

///*[Backer]*/
Backer_Width = Core_Section_Width;
Backer_Height = Core_Section_Height;

back(Riser_Depth/2+10)
    Backer();
xcopies(spacing = Backer_Width)
Riser();

up(Riser_Height + 100)
BasePlateOG(Base_Plate_Width, Base_Plate_Depth, anchor=BOT);

//BasePlateOGRail(Base_Plate_Width);

module BasePlateOG(width, depth, height = 22, anchor=CENTER, spin=0, orient=UP){
    Grid_Min_Side_Clearance = Riser_Width/2;
    Available_Grid_Width = quantdn((width-Grid_Min_Side_Clearance*2)/openGridSize, 1);

    diff(){
        BasePlateRAW(width = width, depth = depth, height = height){
            //up(10)
            ycopies(spacing = 140)
            attach(BOT, BOT, inside=true, shiftout=0.01) 
                BasePlateOGRailDeleteTool(width)
                    attach(BOT, BOT, inside=true, shiftout=0.01) 
                        tag("keep")openGrid(Board_Width = Available_Grid_Width, Board_Height = 1, Tile_Thickness = 11.5);
            children();
        }
    }
}

module BasePlateRAW(width, depth, height = 22, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[width,depth, height]){
        tag_scope()
        move([width/2, depth/2, -22/2])
            yrot(-90)
            zrot(-90)
            linear_sweep(BasePlateProfile(), h = width) ;
        children();
    }

    function BasePlateProfile() = [
        [0,0],
        [0,height],
        [3,height-3],
        [depth-3, height-3],
        [depth,height],
        [depth, 5],
        [depth-8, 0]
    ];
}

module BasePlateOGRailDeleteTool(width, anchor=CENTER, spin=0, orient=UP){
    Grid_Min_Side_Clearance = Riser_Width/2;
    Available_Grid_Width = quantdn((width-Grid_Min_Side_Clearance*2)/openGridSize, 1);
    
    Grid_Min_Depth_Clearance = 3;
    Tile_Thickness = 11.5;

    openingFlair = 7.5;
    
    
    attachable(anchor, spin, orient, size=[width,openGridSize + Grid_Min_Depth_Clearance*2+openingFlair*2,Tile_Thickness+openingFlair]){

        //tag_scope()
        down(openingFlair/2){
            force_tag()
                cuboid([Available_Grid_Width*openGridSize, openGridSize, Tile_Thickness+0.02]);
            force_tag()
                up(Tile_Thickness/2)
                    prismoid(size1=[width+0.02, openGridSize + Grid_Min_Depth_Clearance*2], size2=[width+0.02, openGridSize + Grid_Min_Depth_Clearance*2+openingFlair*2], h=openingFlair+0.02);
        }
        children();
    }
}

module Backer(anchor=CENTER, spin=0, orient=UP){
    Backer_Thickness = 12.5;
    Grid_Dist_From_Bot = 2;
    Grid_Min_Side_Clearance = Riser_Width/2;

    //these are the cutouts that allow the riser to overlap with the backer
    sideCutoutDepth = 5;
    sideCutoutWidth = 9;

    Available_Grid_Width = quantdn((Backer_Width-Grid_Min_Side_Clearance*2)/openGridSize, 1);
    Available_Grid_Height = quantdn((Backer_Height-Grid_Dist_From_Bot)/openGridSize, 1);
    
        //main body
        diff(){
            cuboid([Backer_Width-clearance*2, Backer_Thickness, Backer_Height], anchor=BOT){
                //clear space for opengrid
                up(Grid_Dist_From_Bot)
                    attach(BACK, BOT, inside=true, align=BOT, shiftout=0.01) 
                        cuboid([Available_Grid_Width*openGridSize-0.02, Available_Grid_Height*openGridSize -0.02, Backer_Thickness+0.02]);
                //opengrid
                tag("keep")
                up(Grid_Dist_From_Bot)
                attach(BACK, BOT, inside=true, align=BOT) 
                    openGrid(Available_Grid_Width, Available_Grid_Height);
                attach(FRONT, FRONT, inside=true, shiftout=0.01, align=[LEFT, RIGHT])
                    cuboid([sideCutoutWidth,sideCutoutDepth,Backer_Height+0.02]);
                children();
            }
        }          

}

module Riser(){
    number_of_slides = quantdn((Riser_Height - Slide_Distance_From_Bottom - Slide_Height - Slide_Minimum_Distance_From_Top)/Slide_Vertical_Separation+1, 1);
    
    //main riser body
    diff(){
        cuboid([Riser_Width, Riser_Depth, Riser_Height], anchor=BOT)
            //Slides
            attach([LEFT, RIGHT], LEFT, inside=true, shiftout=0.01, align=BOT) 
                ycopies(spacing = Slide_Vertical_Separation, sp=[0,Slide_Distance_From_Bottom], n = number_of_slides)
                    Riser_Slide_Delete_Tool();
    }
}

module Riser_Slide_Delete_Tool(length = Riser_Depth+0.02, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[Slide_Width,length,Slide_Height]){
        move([-Slide_Width/2, length/2,-Slide_Height/2 ])
            xrot(90)
                linear_sweep(Riser_Slide_Delete_Tool_Profile(), height = length) ;
        children();
    }

    function Riser_Slide_Delete_Tool_Profile() = [
        [0,0],
        [Slide_Width,Slide_Width],
        [Slide_Width,Slide_Height],
        [0,Slide_Height]
    ];
}




//BEGIN openGrid Import - Replace with import
module openGrid(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP){
    //Screw_Mounting options: [Everywhere, Corners, None]
    //Bevel options: [Everywhere, Corners, None]

    $fn=30;
    //2D is fast. 3D is slow. No benefits of 3D. 
    Render_Method = "2D";//[3D, 2D]
    Intersection_Distance = 4.2;
    Tile_Thickness = Tile_Thickness;
    
    tileChamfer = sqrt(Intersection_Distance^2*2);
    lite_cutout_distance_from_top = 1;
    connector_cutout_height = 2.4;

    attachable(anchor, spin, orient, size=[Board_Width*tileSize,Board_Height*tileSize,Tile_Thickness]){

        down(Tile_Thickness/2)
        render(convexity=2)
        diff(){
            move([-Board_Width*tileSize/2, -Board_Height*tileSize/2, 0])
            union()
            for(i=[0: Board_Width-1]) {
                for(j=[0: Board_Height-1]) {
                    translate([tileSize/2+i*tileSize, tileSize/2+j*tileSize])
                    if(Render_Method == "2D") openGridTileAp1(tileSize = tileSize, Tile_Thickness = Tile_Thickness);
                        else wonderboardTileAp2();
                }
            }
            //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
            //Bevel Everywhere
            if(Bevels == "Everywhere" && Screw_Mounting != "Everywhere" && Screw_Mounting != "Corners")
            tag("remove")
                grid_copies(spacing=tileSize, size=[Board_Width*tileSize,Board_Height*tileSize])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Bevel Corners
            if(Bevels == "Corners" || (Bevels == "Everywhere" && (Screw_Mounting == "Everywhere" || Screw_Mounting == "Corners")))
                tag("remove")
                move_copies([[tileSize*Board_Width/2,tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,tileSize*Board_Height/2,0],[tileSize*Board_Width/2,-tileSize*Board_Height/2,0],[-tileSize*Board_Width/2,-tileSize*Board_Height/2,0]])
                    down(0.01)
                    zrot(45)
                        cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
            //Screw Mount Corners
            if(Screw_Mounting == "Corners")
                tag("remove")
                move_copies([[tileSize*Board_Width/2-tileSize,tileSize*Board_Height/2-tileSize,0],[-tileSize*Board_Width/2+tileSize,tileSize*Board_Height/2-tileSize,0],[tileSize*Board_Width/2-tileSize,-tileSize*Board_Height/2+tileSize,0],[-tileSize*Board_Width/2+tileSize,-tileSize*Board_Height/2+tileSize,0]])
                up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            //Screw Mount Everywhere
            if(Screw_Mounting == "Everywhere")
                tag("remove")
                grid_copies(spacing=tileSize, size=[(Board_Width-2)*tileSize,(Board_Height-2)*tileSize])            up(Tile_Thickness+0.01)
                    cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                        attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                            attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
            if(Connector_Holes){
                if(Board_Height > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                xflip_copy(offset = -tileSize*Board_Width/2-0.005)
                    ycopies(spacing=tileSize, l=Board_Height > 2 ? Board_Height*tileSize-tileSize*2 : Board_Height*tileSize - tileSize - 1)
                        connector_cutout_delete_tool(anchor=LEFT);
                if(Board_Width > 1)
                tag("remove")
                up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
                yflip_copy(offset = -tileSize*Board_Height/2-0.005)
                    xcopies(spacing=tileSize, l=Board_Width > 2 ? Board_Width*tileSize-tileSize*2 : Board_Width*tileSize-tileSize-1)
                        zrot(90)
                            connector_cutout_delete_tool(anchor=LEFT);
            }

        }//end diff
        children();
    }

    //BEGIN CUTOUT TOOL
    module connector_cutout_delete_tool(anchor=CENTER, spin=0, orient=UP){
        //Begin connector cutout profile
        connector_cutout_radius = 2.6;
        connector_cutout_dimple_radius = 2.7;
        connector_cutout_separation = 2.5;
        connector_cutout_height = 2.4;
        dimple_radius = 0.75/2;
        
        attachable(anchor, spin, orient, size=[connector_cutout_radius*2-0.1 ,connector_cutout_radius*2,connector_cutout_height]){
            //connector cutout tool
            tag_scope()
            translate([-connector_cutout_radius+0.05,0,-connector_cutout_height/2])
            render()
            half_of(RIGHT, s=connector_cutout_dimple_radius*4)
                linear_extrude(height = connector_cutout_height) 
                union(){
                    left(0.1)
                    diff(){
                        $fn=50;
                        //primary round pieces
                        hull()
                            xcopies(spacing=connector_cutout_radius*2)
                                circle(r=connector_cutout_radius);
                        //inset clip
                        tag("remove")
                        right(connector_cutout_radius-connector_cutout_separation)
                            ycopies(spacing = (connector_cutout_radius+connector_cutout_separation)*2)
                                circle(r=connector_cutout_dimple_radius);
                        //dimple (ass) to force seam. Only needed for positive connector piece (not delete tool)
                        //tag("remove")
                        //right(connector_cutout_radius*2 + 0.45 )//move dimple in or out
                        //    yflip_copy(offset=(dimple_radius+connector_cutout_radius)/2)//both sides of the dimpme
                        //        rect([1,dimple_radius+connector_cutout_radius], rounding=[0,-connector_cutout_radius,-dimple_radius,0], $fn=32); //rect with rounding of inner flare and outer smoothing

                    }
                    //outward flare fillet for easier insertion
                    rect([1,connector_cutout_separation*2-(connector_cutout_dimple_radius-connector_cutout_separation)], rounding=[0,-.25,-.25,0], $fn=32, corner_flip=true, anchor=LEFT);
                }
            children();
        }
    }
    //END CUTOUT TOOL

    //BEGIN APROACH 1 - 2D Extrusion
    //This Render_Method takes the profile of the long ways and corners and sweeps them around the tile. The profiles attempt to derive the points from the variables in the original design. 
    module openGridTileAp1(tileSize = 28, Tile_Thickness = 6.8){
        //Begin Tile Profile
        Tile_Thickness = Tile_Thickness;
        
        Outside_Extrusion = 0.8;
        Inside_Grid_Top_Chamfer = 0.4;
        Inside_Grid_Middle_Chamfer = 1;
        Top_Capture_Initial_Inset = 2.4;
        Corner_Square_Thickness = 2.6;
        Intersection_Distance = 4.2;

        Tile_Inner_Size_Difference = 3;
        fillBack=5; //fillback is needed for the corners to fill gaps that would otherwise be in the corners.



        calculatedCornerSquare = sqrt(tileSize^2+tileSize^2)-2*sqrt(Intersection_Distance^2/2);
        Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
        insideExtrusion = (tileSize-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
        middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
        cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default



        
        full_tile_profile = [
            [0,0],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,0],
            [Outside_Extrusion+insideExtrusion,Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion,Top_Capture_Initial_Inset],
            [Outside_Extrusion,Tile_Thickness-Top_Capture_Initial_Inset],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Top_Capture_Initial_Inset+Inside_Grid_Middle_Chamfer],
            [Outside_Extrusion+insideExtrusion,Tile_Thickness-Inside_Grid_Top_Chamfer],
            [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,Tile_Thickness],
            [0,Tile_Thickness]
            ];

        full_tile_corners_profile = [
            [0,0],
            [Corner_Square_Thickness-cornerChamfer,0],
            [Corner_Square_Thickness,cornerChamfer],
            [Corner_Square_Thickness,Tile_Thickness-cornerChamfer],
            [Corner_Square_Thickness-cornerChamfer,Tile_Thickness],
            [0,Tile_Thickness]

            ];
        
        intersection() {
            union(){
                move([-tileSize/2,-tileSize/2,0]) 
                    path_sweep2d(full_tile_profile, turtle(["move", tileSize+0.01, "turn", 90], repeat=4));
                zrot(45)move([-calculatedCornerSquare/2,-calculatedCornerSquare/2,0]) 
                    path_sweep2d(full_tile_corners_profile, turtle(["move", calculatedCornerSquare, "turn", 90], repeat=4));
                zrot(45)rect_tube(isize=[calculatedCornerSquare-1,calculatedCornerSquare-1], wall=fillBack, h=Tile_Thickness);
            }
            cuboid([tileSize,tileSize,Tile_Thickness], anchor=BOT);
        }
    }
    //END TILE Approach 1

}