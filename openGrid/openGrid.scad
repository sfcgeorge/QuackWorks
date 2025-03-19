/* 
openGrid
Design by DavidD
OpenSCAD by BlackjackDuck (Andy)
This code and all derived parts are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025- 
    - Initial release

Credit to 
    @David D on Printables for openGrid
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    

*/

include <BOSL2/std.scad>

/*[Board Size]*/
Full_or_Lite = "Lite";//[Full, Lite]
Board_Width = 2;
Board_Height= 2;

/*[Style and Mounting Options]*/
//Screw holes for mounting -  
Screw_Mounting = "Everywhere"; //[Everywhere, Corners, None]
//Cosmetic bevels - If screw holes turned on, bevels will only be on the outside corners. 
Bevels = "Corners"; //[Everywhere, Corners, None]
Connector_Holes = true;

/*[Screw Mounting Sizes]*/
Screw_Diameter = 4.1;
Screw_Head_Diameter = 7.2;
Screw_Head_Inset = 1;

/*[Advanced - Tile Parameters]*/
//Customize tile sizes - openGrid standard is 28mm
Tile_Size = 28;

/*[Hidden]*/
//2D is fast. 3D is slow. No benefits of 3D. 
Render_Method = "2D";//[3D, 2D]

/*[Hidden]*/
///*[Advanced: Tile Definition]*/
Tile_Inner_Size_Difference = 3;
Tile_Thickness = 6.8;

Intersection_Distance = 4.2;
Corner_Square_Thickness = 2.6;

//Begin Tile Profile
Outside_Extrusion = 0.8;
Inside_Grid_Top_Chamfer = 0.4;
Inside_Grid_Middle_Chamfer = 1;
Top_Capture_Initial_Inset = 2.4;


//Begin connector cutout profile
connector_cutout_radius = 2.6;
connector_cutout_dimple_radius = 2.7;
connector_cutout_separation = 2.5;
connector_cutout_height = 2.4;
dimple_radius = 0.75/2;
lite_cutout_distance_from_top = 1;

calculatedCornerSquare = sqrt(Tile_Size^2+Tile_Size^2)-2*sqrt(Intersection_Distance^2/2);
Tile_Inner_Size = Tile_Size - Tile_Inner_Size_Difference; //25mm default
insideExtrusion = (Tile_Size-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default
tileChamfer = sqrt(Intersection_Distance^2*2);

//GENERATE TILES
if(Full_or_Lite == "Full") wonderboardGrid(Board_Width = Board_Width, Board_Height = Board_Height);
else wonderboardGridLite(Board_Width = Board_Width, Board_Height = Board_Height);

//!connector_cutout_delete_tool() show_anchors(2);

module connector_cutout_delete_tool(anchor=CENTER, spin=0, orient=UP){
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
        
module wonderboardGridLite(Board_Width, Board_Height){
    render(convexity=2)
    down(Tile_Thickness-4)
    top_half(z=Tile_Thickness-4, s=max(Tile_Size*Board_Width,Tile_Size*Board_Height)*2)
    wonderboardGrid(Board_Width = Board_Width, Board_Height = Board_Height);
}


module wonderboardGrid(Board_Width, Board_Height){
    $fn=30;
    render(convexity=2)
    diff(){
        move([-Board_Width*Tile_Size/2, -Board_Height*Tile_Size/2, 0])
        union()
        for(i=[0: Board_Width-1]) {
            for(j=[0: Board_Height-1]) {
                translate([Tile_Size/2+i*Tile_Size, Tile_Size/2+j*Tile_Size])
                if(Render_Method == "2D") wonderboardTileAp1();
                    else wonderboardTileAp2();
            }
        }
        //TODO: Modularize positioning (Outside Corners, inside corners, inside all) and holes (chamfer and screw holes)
        //Bevel Everywhere
        if(Bevels == "Everywhere" && Screw_Mounting != "Everywhere" && Screw_Mounting != "Corners")
        tag("remove")
            grid_copies(spacing=Tile_Size, size=[Board_Width*Tile_Size,Board_Height*Tile_Size])
                down(0.01)
                zrot(45)
                    cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
        //Bevel Corners
        if(Bevels == "Corners" || (Bevels == "Everywhere" && (Screw_Mounting == "Everywhere" || Screw_Mounting == "Corners")))
            tag("remove")
            move_copies([[Tile_Size*Board_Width/2,Tile_Size*Board_Height/2,0],[-Tile_Size*Board_Width/2,Tile_Size*Board_Height/2,0],[Tile_Size*Board_Width/2,-Tile_Size*Board_Height/2,0],[-Tile_Size*Board_Width/2,-Tile_Size*Board_Height/2,0]])
                down(0.01)
                zrot(45)
                    cuboid([tileChamfer,tileChamfer,Tile_Thickness+0.02], anchor=BOT);
        //Screw Mount Corners
        if(Screw_Mounting == "Corners")
            tag("remove")
            move_copies([[Tile_Size*Board_Width/2-Tile_Size,Tile_Size*Board_Height/2-Tile_Size,0],[-Tile_Size*Board_Width/2+Tile_Size,Tile_Size*Board_Height/2-Tile_Size,0],[Tile_Size*Board_Width/2-Tile_Size,-Tile_Size*Board_Height/2+Tile_Size,0],[-Tile_Size*Board_Width/2+Tile_Size,-Tile_Size*Board_Height/2+Tile_Size,0]])
            up(Tile_Thickness+0.01)
                cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                    attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                        attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
        //Screw Mount Everywhere
        if(Screw_Mounting == "Everywhere")
            tag("remove")
            grid_copies(spacing=Tile_Size, size=[(Board_Width-2)*Tile_Size,(Board_Height-2)*Tile_Size])            up(Tile_Thickness+0.01)
                cyl(d=Screw_Head_Diameter, h=Screw_Head_Inset, anchor=TOP)
                    attach(BOT, TOP) cyl(d2=Screw_Head_Diameter, d1=Screw_Diameter, h=sqrt((Screw_Head_Diameter/2-Screw_Diameter/2)^2))
                        attach(BOT, TOP) cyl(d=Screw_Diameter, h=Tile_Thickness+0.02);
        if(Connector_Holes){
            tag("remove")
            up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
            xflip_copy(offset = -Tile_Size*Board_Width/2-0.005)
                ycopies(spacing=Tile_Size, l=Board_Height*Tile_Size-Tile_Size*2)
                    connector_cutout_delete_tool(anchor=LEFT);
            tag("remove")
            up(Full_or_Lite == "Full" ? Tile_Thickness/2 : Tile_Thickness-connector_cutout_height/2-lite_cutout_distance_from_top)
            yflip_copy(offset = -Tile_Size*Board_Height/2-0.005)
                xcopies(spacing=Tile_Size, l=Board_Width*Tile_Size-Tile_Size*2)
                    zrot(90)
                        connector_cutout_delete_tool(anchor=LEFT);
        }

    }//end diff
}




//APROACH 1 - 2D Extrusion
//This Render_Method takes the profile of the long ways and corners and sweeps them around the tile. The profiles attempt to derive the points from the variables in the original design. 
fillBack=5; //fillback is needed for the corners to fill gaps that would otherwise be in the corners.

module wonderboardTileAp1(){
    intersection() {
        union(){
            move([-Tile_Size/2,-Tile_Size/2,0]) 
                path_sweep2d(full_tile_profile, turtle(["move", Tile_Size+0.01, "turn", 90], repeat=4));
            zrot(45)move([-calculatedCornerSquare/2,-calculatedCornerSquare/2,0]) 
                path_sweep2d(full_tile_corners_profile, turtle(["move", calculatedCornerSquare, "turn", 90], repeat=4));
            zrot(45)rect_tube(isize=[calculatedCornerSquare-1,calculatedCornerSquare-1], wall=fillBack, h=Tile_Thickness);
        }
        cuboid([Tile_Size,Tile_Size,Tile_Thickness], anchor=BOT);
    }
}

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

//echo(str(full_tile_profile));
//echo(str(half_tile_corners_profile));



//APPROACH 2 (slower) - 3D Shapes - This method uses the 3D shapes to create the tile. This method is slower but can be more accurate and easier to understand.
module wonderboardTileAp2(chamfer_edges = []){
    tag_scope()
    diff()
        cuboid([Tile_Size+0.02,Tile_Size+0.02,Tile_Thickness], chamfer=Intersection_Distance, edges=chamfer_edges, except=[TOP, BOT], anchor=BOT)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                wonderboardTileDeleteToolAp2();
}

module wonderboardTileDeleteToolAp2(){
    //Render_Method 2
    
    intersection() {
        //bottom chamfer
        render(convexity=1)
        prismoid(h=Inside_Grid_Top_Chamfer, size1 = [Tile_Inner_Size+Inside_Grid_Top_Chamfer*2,Tile_Inner_Size+Inside_Grid_Top_Chamfer*2], size2=[Tile_Inner_Size,Tile_Inner_Size], anchor=BOT)
            //bottom cuboid
            attach(TOP, BOT) cuboid([Tile_Inner_Size,Tile_Inner_Size,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer-Inside_Grid_Top_Chamfer+0.02])
                //middle lower chamfer
                attach(TOP, BOT) prismoid(size1 = [Tile_Inner_Size, Tile_Inner_Size], size2 = [Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2], h = Inside_Grid_Middle_Chamfer+0.02)
                    //middle straight section
                    attach(TOP, BOT) cuboid([Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2, middleDistance+0.02])
                        //middle upper chamfer
                        attach(TOP, BOT) prismoid(size2 = [Tile_Inner_Size, Tile_Inner_Size], size1 = [Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2], h = Inside_Grid_Middle_Chamfer+0.02)
                            //Top Cuboid
                            attach(TOP, BOT) cuboid([Tile_Inner_Size,Tile_Inner_Size,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer-Inside_Grid_Top_Chamfer+0.02])
                                //Top chamfer
                                attach(TOP, BOT) prismoid(h=Inside_Grid_Top_Chamfer, size2 = [Tile_Inner_Size+Outside_Extrusion,Tile_Inner_Size+Outside_Extrusion], size1=[Tile_Inner_Size,Tile_Inner_Size]);
        zrot(45)
        //corner square
            prismoid(h=cornerChamfer+0.01, size1=[calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2,calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2], size2 = [calculatedCornerSquare-Corner_Square_Thickness*2,calculatedCornerSquare-Corner_Square_Thickness*2])
                attach(TOP, BOT, overlap=0.01)
                    cuboid([calculatedCornerSquare-Corner_Square_Thickness*2, calculatedCornerSquare-Corner_Square_Thickness*2, Tile_Thickness-cornerChamfer*2+0.02])
                        attach(TOP, BOT, overlap=0.01)
                            prismoid(h=cornerChamfer+0.01, size2=[calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2,calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2], size1 = [calculatedCornerSquare-Corner_Square_Thickness*2,calculatedCornerSquare-Corner_Square_Thickness*2]);


    }
}