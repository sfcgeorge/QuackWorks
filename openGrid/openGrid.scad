/* 
openGrid
Design by DavidD
OpenSCAD by BlackjackDuck (Andy) https://makerworld.com/en/@BlackjackDuck
This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025- 
    - Initial release

Credit to 
    @David D on Printables for openGrid https://www.printables.com/@DavidD
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord https://handsonkatie.com/
    Pedro Leite for research and contributions on script performance improvements https://makerworld.com/en/@pedroleite

*/

include <BOSL2/std.scad>

/*[Board Size]*/
Full_or_Lite = "Lite";//[Full, Lite]
Board_Width = 2;
Board_Height= 2;

/*[Style and Mounting Options]*/
//Screw holes for mounting -  
Screw_Mounting = "Corners"; //[Everywhere, Corners, None]
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
//Thickness of the tile (full only)
Tile_Thickness = 6.8;

/*[Tile Stacking - Full Tile Only]*/
//Full Tile Only - Lite tiles coming soon
Stack_Count = 1;
//Thickness of the interface between tiles. This is the distance between the top of the tile and the bottom of the next tile.
Interface_Thickness = 0.4; 
//Distance between the interface and the tile. This is the distance between the top of the tile and the bottom of the interface.
Interface_Separation = 0.05;

//GENERATE TILES
if(Full_or_Lite == "Full" && Stack_Count == 1) openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);
if(Full_or_Lite == "Lite") openGridLite(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size,  Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);

//Stacked tiles
if(Full_or_Lite == "Full" && Stack_Count > 1){
    zcopies(spacing = Tile_Thickness + Interface_Thickness, n=Stack_Count, sp=[0,0,0])
        openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);
    zcopies(spacing = Tile_Thickness + Interface_Thickness, n=Stack_Count-1, sp=[0,0,Tile_Thickness + Interface_Separation])
        color("red") interfaceLayer(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, Connector_Holes = Connector_Holes);
}

//interfaceLayer(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = Tile_Size, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);

module openGridLite(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Bevels = "None",  anchor=CENTER, spin=0, orient=UP){
    //Screw_Mounting options: [Everywhere, Corners, None]
    //Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;
    Lite_Tile_Thickness = 4;
    
    attachable(anchor, spin, orient, size=[Board_Width*tileSize,Board_Height*tileSize,4]){

        render(convexity=2)
        down((4)/2)
        down(Tile_Thickness-4)
        top_half(z=Tile_Thickness-4, s=max(tileSize*Board_Width,tileSize*Board_Height)*2)
        openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = tileSize, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);
    children();
    }
}

module interfaceLayer(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP){
    linear_extrude(height = Interface_Thickness - Interface_Separation*2) 
            interfaceLayer2D(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = tileSize, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels);
}

//create a 2d profile of the interface layer to be extruded later. This is used to create the interface layer between tiles.
module interfaceLayer2D(Board_Width, Board_Height, tileSize = 28, Tile_Thickness = 6.8, Screw_Mounting = "None", Bevels = "None", Connector_Holes = false, anchor=CENTER, spin=0, orient=UP){
    projection(cut=true)
            openGrid(Board_Width = Board_Width, Board_Height = Board_Height, tileSize = tileSize, Tile_Thickness = Tile_Thickness, Screw_Mounting = Screw_Mounting, Bevels = Bevels, anchor=BOT);
}

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
            render() union() {
                grid_copies(spacing = tileSize, n = [Board_Width, Board_Height])

                    if(Render_Method == "2D") openGridTileAp1(tileSize = tileSize, Tile_Thickness = Tile_Thickness);
                        else wonderboardTileAp2();
                
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
        
        render() intersection() {
        union() {
            move([-tileSize/2,-tileSize/2,0]) 
                path_sweep2d(full_tile_profile, turtle(["move", tileSize+0.01, "turn", 90], repeat=4));
            zrot(45)move([-calculatedCornerSquare/2,-calculatedCornerSquare/2,0]) 
                path_sweep2d(full_tile_corners_profile, turtle(["move", calculatedCornerSquare, "turn", 90], repeat=4));
            zrot(45)
                rect_tube(isize=[calculatedCornerSquare-1,calculatedCornerSquare-1], wall=fillBack, h=Tile_Thickness);        
        } 
        //rect_tube(isize = [tileSize, tileSize], wall = calculatedCornerSquare, h = Tile_Thickness);
        cube([tileSize, tileSize, Tile_Thickness], anchor = BOT);
        }
    }
    //END TILE Approach 1

}

/*
//APPROACH 2 (slower) - 3D Shapes - This method uses the 3D shapes to create the tile. This method is slower but can be more accurate and easier to understand.
module wonderboardTileAp2(chamfer_edges = []){
    Tile_Thickness = 6.8;
    Intersection_Distance = 4.2;

    tag_scope()
    diff()
        cuboid([tileSize+0.02,tileSize+0.02,Tile_Thickness], chamfer=Intersection_Distance, edges=chamfer_edges, except=[TOP, BOT], anchor=BOT)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                wonderboardTileDeleteToolAp2();
}

module wonderboardTileDeleteToolAp2(){
    //Begin Tile Profile
    Tile_Thickness = 6.8;
    
    Outside_Extrusion = 0.8;
    Inside_Grid_Top_Chamfer = 0.4;
    Inside_Grid_Middle_Chamfer = 1;
    Top_Capture_Initial_Inset = 2.4;
    Corner_Square_Thickness = 2.6;
    Intersection_Distance = 4.2;

    Tile_Inner_Size_Difference = 3;

    //Render_Method 2
    calculatedCornerSquare = sqrt(tileSize^2+tileSize^2)-2*sqrt(Intersection_Distance^2/2);
    Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
    insideExtrusion = (tileSize-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
    middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
    cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default



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
*/