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
include <BOSL2/rounding.scad>

/*[Tile Definition]*/
Tile_Size = 28;
Tile_Inner_Size_Difference = 3;
Tile_Thickness = 6.8;

Intersection_Distance = 4.2;
Corner_Square_Thickness = 2.6;

//Begin Tile Profile
Outside_Extrusion = 0.8;
Inside_Grid_Top_Chamfer = 0.4;
Inside_Grid_Middle_Chamfer = 1;
Top_Capture_Initial_Inset = 2.4;

/*[Hidden]*/


calculatedCornerSquare = sqrt(Tile_Size^2+Tile_Size^2)-2*sqrt(Intersection_Distance^2/2);
Tile_Inner_Size = Tile_Size - Tile_Inner_Size_Difference; //25mm default
insideExtrusion = (Tile_Size-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default

wonderboardTile();

//APPROACH 2
module wonderboardTile(){
    tag_scope()
    diff()
        cuboid([Tile_Size,Tile_Size,Tile_Thickness], anchor=BOT)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                wonderboardTileDeleteTool();
}

module wonderboardTileDeleteTool(){
    tag_scope()
    intersection() {
    //Delete tool
    //bottom cuboid
        diff()
        //bottom chamfer
        prismoid(h=Inside_Grid_Top_Chamfer, size1 = [Tile_Inner_Size+Inside_Grid_Top_Chamfer*2,Tile_Inner_Size+Inside_Grid_Top_Chamfer*2], size2=[Tile_Inner_Size,Tile_Inner_Size], anchor=BOT)
            //bottom cuboid
            attach(TOP, BOT, overlap=0.01) cuboid([Tile_Inner_Size,Tile_Inner_Size,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer-Inside_Grid_Top_Chamfer+0.02])
                //middle lower chamfer
                attach(TOP, BOT, overlap=0.01) prismoid(size1 = [Tile_Inner_Size, Tile_Inner_Size], size2 = [Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2], h = Inside_Grid_Middle_Chamfer+0.02)
                    //middle straight section
                    attach(TOP, BOT, overlap=0.01) cuboid([Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2, middleDistance+0.02])
                        //middle upper chamfer
                        attach(TOP, BOT, overlap=0.01) prismoid(size2 = [Tile_Inner_Size, Tile_Inner_Size], size1 = [Tile_Inner_Size+insideExtrusion*2, Tile_Inner_Size+insideExtrusion*2], h = Inside_Grid_Middle_Chamfer+0.02)
                            //Top Cuboid
                            attach(TOP, BOT, overlap=0.01) cuboid([Tile_Inner_Size,Tile_Inner_Size,Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer-Inside_Grid_Top_Chamfer+0.02])
                                attach(TOP, BOT, overlap=0.01) prismoid(h=Inside_Grid_Top_Chamfer, size2 = [Tile_Inner_Size+Outside_Extrusion,Tile_Inner_Size+Outside_Extrusion], size1=[Tile_Inner_Size,Tile_Inner_Size]);
        zrot(45)
        //corner square
            prismoid(h=cornerChamfer+0.01, size1=[calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2,calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2], size2 = [calculatedCornerSquare-Corner_Square_Thickness*2,calculatedCornerSquare-Corner_Square_Thickness*2])
                attach(TOP, BOT, overlap=0.01)
                    cuboid([calculatedCornerSquare-Corner_Square_Thickness*2, calculatedCornerSquare-Corner_Square_Thickness*2, Tile_Thickness-cornerChamfer*2+0.02])
                        attach(TOP, BOT, overlap=0.01)
                            prismoid(h=cornerChamfer+0.01, size2=[calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2,calculatedCornerSquare-Corner_Square_Thickness*2+cornerChamfer*2], size1 = [calculatedCornerSquare-Corner_Square_Thickness*2,calculatedCornerSquare-Corner_Square_Thickness*2]);


    }
}

//APROACH 1

//path_sweep(full_tile_profile(), turtle(["move", Tile_Size, "turn", 90, "move", Tile_Size, "turn", 90, "move", Tile_Size, "turn", 90, "move", Tile_Size, "turn", 90]));

function full_tile_profile() = 
    union(
        half_tile_profile,
        back(Tile_Thickness-0.01, mirror([0,1,0], half_tile_profile))
    );

half_tile_profile = [
    [0,0],
    [Outside_Extrusion+insideExtrusion-Inside_Grid_Top_Chamfer,0],
    [Outside_Extrusion+insideExtrusion,Inside_Grid_Top_Chamfer],
    [Outside_Extrusion+insideExtrusion,Top_Capture_Initial_Inset-Inside_Grid_Top_Chamfer-Inside_Grid_Middle_Chamfer],
    [Outside_Extrusion,Top_Capture_Initial_Inset-Inside_Grid_Top_Chamfer],
    [Outside_Extrusion,Tile_Thickness/2],
    [0,Tile_Thickness/2],
    ];

