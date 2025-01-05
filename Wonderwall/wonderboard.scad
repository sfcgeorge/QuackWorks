/*Design by DavidD and OpenSCAD by BlackjackDuck (Andy)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Change Log:
- 2025- 
    - Initial release

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Wonderwall

*/

include <BOSL2/std.scad>

/*[Board Size]*/
Board_Width = 2;
Board_Height= 2;

/*[Style and Mounting]*/
Bevel_Everywhere = true;

/*[Tile Parameters]*/
Tile_Size = 28;

/*[Debug]*/
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

calculatedCornerSquare = sqrt(Tile_Size^2+Tile_Size^2)-2*sqrt(Intersection_Distance^2/2);
Tile_Inner_Size = Tile_Size - Tile_Inner_Size_Difference; //25mm default
insideExtrusion = (Tile_Size-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default

//Build Grid Faster
    render(convexity=2)
    for(i=[0: Board_Width-1]) {
      for(j=[0: Board_Height-1]) {
        translate([Tile_Size/2+i*Tile_Size, Tile_Size/2+j*Tile_Size])
          if(Render_Method == "2D") wonderboardTileAp1();
            else wonderboardTileAp2();
      }
    }

/*
//Build Grid
*diff(){
    grid_copies(spacing=Tile_Size, n=[Board_Width,Board_Height])
        if(Render_Method == "2D") wonderboardTileAp1();
        else wonderboardTileAp2();

    //All Intersections
    if(Bevel_Everywhere)
    tag("remove")
    grid_copies(spacing=Tile_Size, size=[Board_Width*Tile_Size,Board_Height*Tile_Size])
        down(0.01)
        zrot(45)
            cuboid([Intersection_Distance,Intersection_Distance,Tile_Thickness+0.02], anchor=BOT);
}
*/



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

echo(str(full_tile_profile));
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