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
    Pedro Leite for openGrid optimization
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/joiners.scad>

/*[Core Section Dimensions]*/
//Width (in mm) from riser center to riser center. 84mm increments. 
Core_Section_Width = 196; //[112:84:952] 
//Depth (in mm) from front of the riser to the rear of the backer (top plate will be deeper out the front). 28mm increments.
Core_Section_Depth = 196.5; //[112.5:84:840.5]
//Total Height of the core section from the bottom of the riser to the base of the top plate.
Total_Height = 107.5; //[27.5:40:387.5]
//DISPLAY PURPOSES ONLY - The output will always contain the parts needed for 1 core. For extra cores, simply print 1 more of the following: 1 Riser, 1 Backer, 1 Baseplate, 1 Top plate
Core_Section_Count = 1; //[1:1:8]

/*[Ends]*/
End_Style = "Rounded Square"; //[Rounded, Squared, Rounded Square]
//Change the rounding radius of the rounded square
Rounded_Square_Rounding = 50;


/*[Drawers]*/
Drawer_Pull_Type = "Screw Holes - Single"; //[Screw Holes - Single, Screw Holes - Double]
Drawer_Pull_Screw_Diameter = 5;
//Distance from screw hole centers if using double-screw drawer pulls
Drawer_Pull_Double_Screw_Hole_Distance_from_Center = 75;
//Adjust the height (mm) of the drawer pull holes up(positive) or down (negative)
Drawer_Pull_Height_Adjustement = 0;

/*[Colors]*/
Primary_Color = "#2e2e2e"; // color
Drawer_Front_Color = "#00cf30"; // color
Top_Plate_Color = "#00cf30"; // color

/*[Advanced Options]*/
//Additional reach of top plate support built into the baseplate. 1 = 1 openGrid unit.
Additional_Top_Plate_Support = 1; //[1:1:8] 



/*[Select Parts]*/
Show_Baseplate = true;
Show_Risers = true;
Show_Backer = true;
Show_Top_Plate = true;
Show_Drawers = true;
Connector_Fit_Tests = false;


/*[Debug]*/
openGrid_Render = true;
Show_Connected=false;
MakerWorld_Render_Mode = false;
Show_Plate = 0;
Disable_Colors = false;

/*[Hidden]*/
///*[Advanced]*/
clearance = 0.15;
openGridSize = 28;

Show_Top_Plate_all_options = false;

///*[Printable Bed Volume]*/
//Select printer and a log entry will tell you if it will fit
Select_Printer = "X1C/P1S"; //[X1C/P1S, A1, A1 Mini, H2D, Other - Enter Below]
Custom_Bed_Width = 256;
Custom_Bed_Depth = 256;

curve_resolution = 100;

///*[Riser Slide]*/
//Width (and rise of angle) of the slide recess
Slide_Width = 4;
//Total height of the slide recess
Slide_Height = 10.5;
//Vertical distance between slides
Slide_Vertical_Separation = 40;
//Distance from the bottom of the riser to the bottom of the slide delete tool. Drawers should add clearance
Slide_Distance_From_Bottom = 11.75;
//Minimum clearance required for a top of a slide to the top of the riser
Slide_Minimum_Distance_From_Top = 16.75;
Slide_Clearance = 0.25;

///*[Top Plate]*/
Top_Plate_Thickness = 8.5;
//Clearance (in mm) between the top plate and the base plate
Top_Plate_Clearance = 1;
topChamfer = 2;
topLipDepth = 0.5;
topLipHeight = 1;

///*[Base Plate]*/
Base_Plate_Width = Core_Section_Width;
Base_Plate_Depth = Core_Section_Depth + 10.5;
Base_Plate_Thickness = 19;

Core_Section_Height = Total_Height - Top_Plate_Thickness - Base_Plate_Thickness;

///*[Riser]*/
Riser_Depth = Core_Section_Depth - 7.5;
Riser_Height = Core_Section_Height;
Riser_Width = 22;

///*[Backer]*/
Backer_Width = Core_Section_Width;
Backer_Height = Core_Section_Height;
Backer_Thickness = 12.5;
//these are the cutouts that allow the riser to overlap with the backer
sideCutoutDepth = 3.65;
sideCutoutWidth = Riser_Width/2+clearance;
Backer_To_Riser_Tab_Inset = 2;
Backer_To_Riser_Tab_Depth = 8;

//Baseplate parameters
Grid_Min_Side_Clearance = Riser_Width/2;
Grid_Min_Depth_Clearance = 18;
Grid_Min_FrontBack_Clearance = 2;
Tile_Thickness = 11.5;
Baseplate_Bottom_Chamfer = 5;

//oG Height Calculations
Grid_Dist_From_Bot = 2; //size of base on bottom of BACKER before starting the grid
minimumTopSpacing = 2; //minimum height of the grid from the top of the backer
safeHOKClearance = 17;
Available_Grid_Height = quantdn((Backer_Height-Grid_Dist_From_Bot-minimumTopSpacing)/openGridSize, 1);
Grid_Height_mm = Available_Grid_Height * openGridSize;
Grid_Height_is_Odd = Available_Grid_Height % 2 == 0 ? false : true; 
enableHOKBlocks = Backer_Height - Grid_Height_mm - Grid_Dist_From_Bot < safeHOKClearance ? true : false;

//oG Width Calculations
Available_Grid_Width_Units = quantdn((Base_Plate_Width - Grid_Min_Side_Clearance*2) / openGridSize, 1);
Grid_Width_is_Odd = Available_Grid_Width_Units % 2 == 0 ? false : true; 
Grid_Width_mm = Available_Grid_Width_Units * openGridSize;

//oG Depth Calculations
Available_Grid_Depth_Units = quantdn((Base_Plate_Depth - Grid_Min_Depth_Clearance*2) / openGridSize, 1);
Grid_Depth_is_Odd = Available_Grid_Depth_Units % 2 == 0 ? false : true; 
Grid_Depth_mm = Available_Grid_Depth_Units * openGridSize;


echo(str(Grid_Width_is_Odd));

//HOK Parameters
HOK_Connector_Spacing_Depth = Grid_Depth_is_Odd ? openGridSize*2 : openGridSize*3;

Default_HOK_Connector_Spacing_Back = min(openGridSize*(Available_Grid_Width_Units - 1), Grid_Width_is_Odd ? openGridSize*4 : openGridSize*3); //Spacing between multiple HOK connecters (center to center). Either the outer grids or 
//Distance from part edge to center of HOK Connector
HOK_Connector_Inset = 4.5;
HOK_Connector_Thickness = 3.00;
HOK_Connector_Width = 8.9*2;

//Baseplate Dovetails
Dovetail_Spacing = 40;
Dovetail_Depth = 3.15;
Dovetail_Width = 10;
Dovetail_Height = 9;
Dovetail_Chamfer = 0.6;
Dovetail_Slop = 0.1;

//Baseplate to top plate interface parameters
//The chamfer depth and height of the outermost chamfer on the base plate
Top_Bot_Plates_Interface_Chamfer = 3;
//The minimum depth of the surface that the top plate rests on the base plate (excluding the chamfer above)
Minimum_Flat_Resting_Surface = 7.5;
TabDistanceFromOutsideEdge = 6;
TabProtrusionHeight = 4;

//Baseplate End Angle Parameters
baseplateEndAngleUp= 11; //the angle of the end
baseplateEndAngleDistance = 89; //the width of the rectangle that is then angled upwards for the ends
baseplateEndAngleBevel = 5; //the bevel value for the rectangle that is then angled upwards for the ends
baseplateEndLateralWidth = cos(baseplateEndAngleUp) * baseplateEndAngleDistance; //Because the total width is determined by the angle and the width of the angled piece, this calculates the lateral width

//Tab parameters
TopPlateTabWidth = 3;



//Drawer Parameters
DrawerThickness = 3;
DrawerVerticalClearance = 1.5;
//Moves the drawers up (positive) or down (negative relative to the slide). Zero = the drawers sitting flush with the bottom of the riser. 
DrawerSlideHeightMicroadjustement = 0.5;
Drawer_Outside_Width = Core_Section_Width - Riser_Width - clearance*2;
Drawer_Outside_Depth = quantdn(Core_Section_Depth - sideCutoutDepth - clearance, 42)+DrawerThickness*2; //find the available space and round down to the nearest 42mm (gridfinity)
//Distance from the top of the drawer to the top of the slide.
Drawer_Slide_From_Top = Slide_Vertical_Separation - Slide_Distance_From_Bottom - Slide_Height-Slide_Clearance-DrawerVerticalClearance+clearance;
DrawerDovetailWidth = 10;
DrawerDovetailHeight = 25;
DrawerPullHoleCount = 
    Drawer_Pull_Type == "Screw Holes - Single" ? 1 :
    Drawer_Pull_Type == "Screw Holes - Double" ? 2 :
    0;

//Bed Size Calculations
availablePrintVolume = 
    Select_Printer == "Other - Enter Below" ? [Custom_Bed_Width, Custom_Bed_Depth] :
    Select_Printer == "X1C/P1S" ? [255, 227] :
    Select_Printer == "A1" ? [256, 256] :
    Select_Printer == "A1 Mini" ? [180, 180] :
    Select_Printer == "H2D" ? [350, 320] :
    [Custom_Bed_Width, Custom_Bed_Depth];

print_volume_message = 
    availablePrintVolume[0] >= Core_Section_Width && availablePrintVolume[1] >= Core_Section_Depth ? "Print will fit!" : "Warning: Print will not fit!";
echo(print_volume_message);

//If viewing on desktop
if(!MakerWorld_Render_Mode && Show_Plate == 0)
    mw_assembly_view();
if(!MakerWorld_Render_Mode && Show_Plate == 1)
    mw_plate_1();
if(!MakerWorld_Render_Mode && Show_Plate == 2)
    mw_plate_2();
if(!MakerWorld_Render_Mode && Show_Plate == 3)
    mw_plate_3();
if(!MakerWorld_Render_Mode && Show_Plate == 4)
    mw_plate_4();
if(!MakerWorld_Render_Mode && Show_Plate == 5)
    mw_plate_5();
if(!MakerWorld_Render_Mode && Show_Plate == 6)
    mw_plate_6();
if(!MakerWorld_Render_Mode && Show_Plate == 7)
    mw_plate_7();
if(!MakerWorld_Render_Mode && Show_Plate == 8)
    mw_plate_8();
if(!MakerWorld_Render_Mode && Show_Plate == 9)
    mw_plate_9();
module mw_assembly_view() {
    if(Show_Backer)
        xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
            back(Riser_Depth/2+ Backer_Thickness/2 + (Show_Connected ? -sideCutoutDepth + clearance : 15))
                Backer();

    if(Show_Risers)
        xcopies(spacing = Backer_Width, n = Core_Section_Count + 1)
            Riser();

    if(Show_Baseplate)
        
        up(Show_Connected ? Riser_Height + clearance : Riser_Height + 50){
            xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                BasePlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth,  height = Base_Plate_Thickness);
            if(End_Style == "Rounded Square"){
                xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? 0: 50))
                    zrot($idx == 0 ? 0 : 180)
                        baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = Rounded_Square_Rounding, anchor=BOT+RIGHT);
            }
            else if(End_Style == "Squared"){
                xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? 0: 50))
                    zrot($idx == 0 ? 0 : 180)
                        baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = 1, anchor=BOT+RIGHT);
            }

            else{
                left (Core_Section_Width / 2 * Core_Section_Count + (Show_Connected ? 0 : 25))
                    BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=LEFT, style=End_Style);
                right (Core_Section_Width / 2 * Core_Section_Count + (Show_Connected ? 0 : 25))
                    BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=RIGHT, style=End_Style);
            }
        }

    if(Show_Top_Plate){
        up(Riser_Height + (Show_Connected ? Base_Plate_Thickness: 150))
        {
            xcopies(n=Core_Section_Count, spacing = Core_Section_Width)
                TopPlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, anchor=BOT);
            if(End_Style == "Rounded"){
                xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                    TopPlateEndRoundNew(depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT);
            }
            else if(End_Style == "Squared"){
                xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                    TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, radius = 1, half=$idx == 0 ? LEFT : RIGHT);
            }
            else{
                xcopies(spacing = Core_Section_Width * Core_Section_Count + (Show_Connected ? clearance*2: 50))
                    TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, radius = Rounded_Square_Rounding, half=$idx == 0 ? LEFT : RIGHT);
            }
        }
    }

    if(Show_Drawers){
        //bottom drawer
        up(DrawerSlideHeightMicroadjustement)
        xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
            fwd(Show_Connected ? 8.5 : 50)
                if($idx % 2 == 0){
                    zcopies(spacing = 40, sp=0)
                    Drawer(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT)
                        //drawer fronts
                        if(Show_Connected)
                        attach(FRONT, TOP)
                            DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2);
                }
                else
                    Drawer(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT)
                        //drawer fronts
                        if(Show_Connected)
                        attach(FRONT, TOP)
                            DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2);
        //drawer fronts if not connected
        if(!Show_Connected)
            up(DrawerSlideHeightMicroadjustement)
            fwd(Core_Section_Depth/2 + 25 + 60)
                xcopies(spacing = Core_Section_Width, n=Core_Section_Count)
                    if($idx == 0)
                    ycopies(spacing = 40)
                        DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2);
                    else
                        DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2);
    }

    if(Connector_Fit_Tests){
        diff()
        cube([19,5,18], anchor=BOT)
            attach(TOP, BOT, inside=true, shiftout=0.01)
                HOKConnectorDeleteTool();
        
        move([10,20])
            Dovetail_Male(anchor=UP, orient=DOWN);

        ycopies(spacing = Dovetail_Width+5)
            diff()
                move([-10,20])
                    zrot($idx == 0 ? 180 : 0)
                    cuboid([Dovetail_Width+4,Dovetail_Width,Dovetail_Depth+1], anchor=BOT)
                        attach(TOP, BACK, align = FRONT, inside=true) 
                                Dovetail_Female();
    }
}

//BEGIN MAKERWORLD PLATING

//Plate 1 - Core Baseplate
module mw_plate_1(){
    BasePlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth,  height = Base_Plate_Thickness);
}


//Plate 2 - Risers and Backer
module mw_plate_2(){
    widthOfAllRisers = (2) * (Riser_Width+5); //removed dynamic riser adds based on core count (to keep render times down)
    widthOfAllBackers = 1 * (Backer_Height + 5); //removed dynamic riser adds based on core count (to keep render times down)

    left(widthOfAllRisers/2)
    xcopies(spacing = Riser_Width+5, n = 2)
        Riser(orient=DOWN, anchor=TOP) ;
    right(widthOfAllBackers/2)
        xcopies(spacing = Backer_Height + 5, n=1)
            zrot(90)
                Backer(orient=BACK, anchor=BACK);
}

//Plate 3 - Baseplate Ends
module mw_plate_3(){
    if(End_Style == "Rounded Square"){
                xcopies(spacing = -5)
                    zrot($idx == 0 ? 0 : 180)
                        baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = Rounded_Square_Rounding, anchor=BOT+RIGHT, orient=RIGHT);
    }
    if(End_Style == "Squared"){
        xcopies(spacing = -5)
            zrot($idx == 0 ? 0 : 180)
                baseplateEndSquared(depth = Base_Plate_Depth, height = Base_Plate_Thickness, radius = Rounded_Square_Rounding, anchor=BOT+RIGHT, orient=RIGHT);
    }

    else{
            xcopies(spacing = 5)
                BasePlateEndRounded(width = Base_Plate_Width, depth = Base_Plate_Depth, height = Base_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT, style=End_Style);
    }

    move([0, Base_Plate_Depth/2 + 15])
        xcopies(n = 4, spacing = 15)
            Dovetail_Male(anchor=UP, orient=DOWN);
}

//Plate 4 - Core Top plate
module mw_plate_4(){
    TopPlateCore(width = Base_Plate_Width, depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, anchor=BOT);

}

//Plate 5 - Ends Top plate
module mw_plate_5(){
    if(End_Style == "Rounded"){
        xcopies(spacing = 5)
            TopPlateEndRoundNew(depth = Base_Plate_Depth, thickness = Top_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT);
    }
    else if(End_Style == "Squared"){
        xcopies(5)
            TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Base_Plate_Depth, radius = 1, thickness = Top_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT);
    }
    else{
        xcopies(5)
            TopPlateEndSquared(width = baseplateEndAngleDistance*2, depth = Base_Plate_Depth, radius = Rounded_Square_Rounding, thickness = Top_Plate_Thickness, half=$idx == 0 ? LEFT : RIGHT);
    }


}

//Plate 6 - Drawer 1 Unit High
module mw_plate_6(){
    Drawer(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT);
}

//Plate 7 - Drawer 2 Units High
module mw_plate_7(){
    Drawer(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2, Drawer_Outside_Depth = Drawer_Outside_Depth, anchor=BOT);

}

//Plate 8 - Drawer Fronts
module mw_plate_8(){
    ydistribute(sizes=[40, 80], spacing = 5){
        DrawerFront(height_units = 1, inside_width = Drawer_Outside_Width - DrawerThickness*2);
        DrawerFront(height_units = 2, inside_width = Drawer_Outside_Width - DrawerThickness*2);
    }
}


//END MAKERWORLD PLATING

module DrawerFront(height_units, inside_width, anchor=CENTER, orient=UP, spin=0){
    drawerFrontThickness = 3.5;
    drawerFrontChamfer = 1;
    drawerFrontRecess = 3.1;
    drawer_height = height_units * Slide_Vertical_Separation - DrawerVerticalClearance;
    drawerFrontHeightReduction = 4.5;

    drawerFrontLateralClearance = 2;
    
    inside_width_adjusted = quant(inside_width, 42);
    drawerOuterWidth = inside_width_adjusted + DrawerThickness*2;
    drawerFrontWidth = drawerOuterWidth + Riser_Width - drawerFrontLateralClearance*2;

    tag_scope()
    recolor(Disable_Colors ? $color : Drawer_Front_Color)
    diff()
    cuboid([drawerFrontWidth, drawer_height, drawerFrontThickness], chamfer = drawerFrontChamfer, edges=BOT, anchor=anchor, orient=orient, spin=spin){
        //drawer dovetails
        tag("keep")
        xcopies(spacing=inside_width_adjusted - 28 )
        attach(TOP, FRONT, overlap=0.01, align=BACK, inset=drawerFrontHeightReduction)
            cuboid([DrawerDovetailWidth+DrawerThickness*2-clearance*2, DrawerThickness+0.02, DrawerDovetailHeight*height_units - clearance], chamfer=DrawerThickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //drawer pull screw hole(s)
        tag("remove")
            back(Drawer_Pull_Height_Adjustement)
            xcopies(spacing = Drawer_Pull_Double_Screw_Hole_Distance_from_Center, n=DrawerPullHoleCount)
            attach(TOP, BOT, inside = true, shiftout=0.01)
                cyl(d=Drawer_Pull_Screw_Diameter, h = drawerFrontThickness + 0.02, $fn = 25);
        children();
    }
}

module Drawer(height_units, inside_width, Drawer_Outside_Depth, anchor=CENTER, orient=UP, spin=0){
    //FORCE INSIDE TO STANDARD UNITS
    inside_width_adjusted = quant(inside_width, 42);

    drawer_height = height_units * Slide_Vertical_Separation - DrawerVerticalClearance;
    drawerFloorThickness = 2;
    drawerOuterWidth = inside_width_adjusted + DrawerThickness*2;

    drawerInsideRounding = 3.75;
    drawerFrontHeightReduction = 4.5;

    tag_scope()
    recolor(Disable_Colors ? undef : Primary_Color)
    diff()
    rect_tube(size = [drawerOuterWidth, Drawer_Outside_Depth], h = drawer_height, wall=DrawerThickness, anchor=anchor, orient=orient, spin=spin){
        attach([LEFT, RIGHT], LEFT, align=TOP, overlap=0.01, inset=Drawer_Slide_From_Top+DrawerSlideHeightMicroadjustement)
            Drawer_Slide(length = Drawer_Outside_Depth);
        //drawer bottom
        tag("keep")
        attach(BOT, BOT, inside=true)
            cuboid([drawerOuterWidth-0.01, Drawer_Outside_Depth-0.01, drawerFloorThickness]);
        //drawer front dovetails
        xcopies(spacing=inside_width_adjusted - 28 )
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([DrawerDovetailWidth+DrawerThickness*2, DrawerThickness+0.02, DrawerDovetailHeight*height_units+drawerFrontHeightReduction], chamfer=DrawerThickness, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //drawer front height reduction
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([drawerOuterWidth+0.02, DrawerThickness+0.02, drawerFrontHeightReduction]);
        //front drawer pull
        color(Disable_Colors ? undef : Primary_Color)
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=drawerFrontHeightReduction-0.02)
            cuboid([inside_width_adjusted/3, DrawerThickness+0.02, 20], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = min(5,5), 
                        edges=[LEFT+BOT, RIGHT+BOT]) 
                        //top round out
                        edge_profile_asym([TOP+LEFT, TOP+RIGHT], corner_type="round") xflip() mask2d_roundover(2) 
                        ;
        //Back cable port
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            color(Disable_Colors ? undef : Primary_Color)
            cuboid([20, DrawerThickness+0.02, 15], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = min(5,5), 
                        edges=[LEFT+BOT, RIGHT+BOT]) 
                        //top round out
                        edge_profile_asym(TOP, corner_type="round") xflip() mask2d_roundover(3) 
                        ;
        //Back cable port inside
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=20)
            cuboid([20, DrawerThickness+0.02, 10], 
                        //bottom rounding at 5 or maximum possible given cutout width
                        rounding = 2, 
                        edges=[LEFT+BOT, RIGHT+BOT, TOP+LEFT, TOP+RIGHT]) 
                        ;
        //drawer pull screw hole(s)
        tag("remove")
            up(Drawer_Pull_Height_Adjustement)
            xcopies(spacing = Drawer_Pull_Double_Screw_Hole_Distance_from_Center, n=DrawerPullHoleCount)
            attach(FRONT, BOT, inside = true, shiftout=0.01)
                cyl(d=Drawer_Pull_Screw_Diameter, h = DrawerThickness + 0.02, $fn = 25);
        children();
    }
}


module TopPlateCore(width, depth, thickness, spin = 0, orient = UP, anchor=CENTER){

    color(Disable_Colors ? undef : Top_Plate_Color)
    diff()
    cuboid([width-clearance*2, depth+Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2, thickness+topLipHeight], spin=spin, orient=orient, anchor=anchor){
        //bot chamfer
        edge_profile([BOT+FRONT, BOT+BACK])
            mask2d_chamfer(x=Top_Bot_Plates_Interface_Chamfer*2);
        //top chamfer
        edge_profile([TOP+FRONT, TOP+BACK])
            mask2d_chamfer(x=topChamfer);
        //top lip cutout
        attach(TOP, TOP, inside=true, shiftout=0.01)
            cuboid([width+0.02, depth+Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2 - topChamfer*2-topLipDepth*2, topLipHeight]);
        //top plate tabs
        attach(BOT, BOT, inside=true, shiftout=0.01, align=[LEFT, RIGHT], inset=TabDistanceFromOutsideEdge-clearance)
            TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
        children();
    }
}

module TopPlateEndSquared(width, depth, thickness, radius = 50, half = LEFT){
    depthAdjusted = depth + Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2;
    thicknessAdjusted = thickness + topLipHeight;
    
    color(Disable_Colors ? undef : Top_Plate_Color)
    diff(){
        half_of(half, s = width*2 + 5)
            topPlateBuilder(totalHeight = thicknessAdjusted, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer)
                rect([width,depthAdjusted], rounding = [radius,radius,radius,radius]);
            tag("remove")
               up(TabProtrusionHeight/2-0.01)
               xcopies(spacing = TopPlateTabWidth+TabDistanceFromOutsideEdge*2)
                    TopPlateTab(height = TabProtrusionHeight, deleteTool = true, anchor=BOT);
    }
}

module TopPlateEndRoundNew(depth, thickness, half = LEFT){
    
    depthAdjusted = depth + Top_Bot_Plates_Interface_Chamfer*2 - Top_Plate_Clearance*2;
    thicknessAdjusted = thickness + topLipHeight;
    
    color(Disable_Colors ? undef : Top_Plate_Color)
    diff(){
        half_of(half, s = depth*2 + 5)
            topPlateBuilder(totalHeight = thicknessAdjusted, bottomChamfer = Top_Bot_Plates_Interface_Chamfer*2, topChamfer = topChamfer)
                ellipse(d=depthAdjusted);
        tag("remove")
            up(TabProtrusionHeight/2-0.01)
            xcopies(spacing = TopPlateTabWidth+TabDistanceFromOutsideEdge*2)
                TopPlateTab(height = TabProtrusionHeight, deleteTool = true);
    }
}

module topPlateBuilder(totalHeight = 9.5, bottomChamfer = 1, topChamfer = 1, topInset = 0.5, half = LEFT, topRecess = 1, $fn = 150){
    //takes any 2D shape and builds a top plate to match
    //for end pieces, this shape is expected to be split down the middle to produce symmetrical sides
    //the children() is the 2D shape received when this module is called
    middleSectionHeight = totalHeight - bottomChamfer - topChamfer;  

    translate([0,0,bottomChamfer])
    difference(){
        chamferedBody() children();
        topCutout() children();
    }

    module chamferedBody(){
        middleSection() children();
        topChamfer() children();
        bottomChamfer() children();
    }

    module topCutout(){
        translate([0,0,middleSectionHeight+topRecess+0.001])
        linear_extrude(topRecess+0.01)
            offset(delta=-topInset-topChamfer)
                children(); 
    }

    module middleSection()
        linear_extrude(totalHeight-topChamfer - bottomChamfer)
            children();
    
    module topChamfer()
        intersection(){
            scopeBody() children();
            translate([0,0,middleSectionHeight])
                roof()
                    children();
        }

    module scopeBody()
        translate([0,0,-bottomChamfer])
            linear_extrude(totalHeight)
                children();

    module bottomChamfer()
        intersection(){
            mirror([0,0,1])
                roof()
                    children();
            scopeBody() children();
        }
}

module baseplateEndSquared(width = 120, depth = 207, height = 19, radius = 50, spin = 0, orient = UP, anchor=CENTER){
    //NOTE: attachments are being passed through from main_section
    
    $fn = 150;
  
    color(Disable_Colors ? undef : Primary_Color)
    diff("HOKConnectors", "k1")
        diff("r1", "keep HOKConnectors"){
            main_section(spin = spin, orient = orient, anchor = anchor){
                //top cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01)            
                    intersection(){
                        translate([-baseplateEndLateralWidth/2,-depth/2])
                            roof()
                                rect([baseplateEndLateralWidth*2,depth], rounding = radius);
                        cube([baseplateEndLateralWidth*2,depth, Top_Bot_Plates_Interface_Chamfer], center=true);
                    }
                //inside deep cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01, align=RIGHT)
                    cuboid([baseplateEndAngleDistance-Minimum_Flat_Resting_Surface*3-radius/2, depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, height-Tile_Thickness+Top_Bot_Plates_Interface_Chamfer],  chamfer = (height - Tile_Thickness), edges=BOT, except_edges=RIGHT);
                if(Additional_Top_Plate_Support)
                    //middle support
                    tag("keep")
                    down(Top_Bot_Plates_Interface_Chamfer)
                    attach(TOP, TOP, inside=true, align=RIGHT)
                        cuboid([20,28*4,height - 4], chamfer=height-Tile_Thickness, edges=TOP, except_edges=RIGHT)
                            tag("HOKConnectors")
                            attach(RIGHT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                    xcopies(spacing = Dovetail_Spacing)
                                        Dovetail_Female();
                                    //dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height,chamfer=0.6);
                //top plate tabs
                tag("keep")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, inset=TabDistanceFromOutsideEdge)
                    TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);
                //HOK Connector cutouts
                tag("HOKConnectors")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, spin=90, inset = HOK_Connector_Inset-HOK_Connector_Thickness/2-clearance) 
                    xcopies(spacing=HOK_Connector_Spacing_Depth)
                    //zrot(90)
                        HOKConnectorDeleteTool();
                //openGrid
                /* disabling for now due to print orientation challenges
                tag("r1")
                    attach(BOT, BOT, inside=true, align=RIGHT)
                    ycopies(spacing = openGridSize*5)
                    up(Tile_Thickness-4+0.02) left(openGridSize/2 - clearance)
                        cube([openGridSize,openGridSize,height])
                            tag("keep")                                
                                
                                attach(BOT, BOT, inside=true, align=RIGHT)
                                    openGridLite(Board_Width = 1, Board_Height = 1);
                */
                children();
            }
    }

    module main_section(spin = 0, orient = UP, anchor=CENTER){
        attachable(anchor, spin, orient, size=[baseplateEndLateralWidth,depth,height+Top_Bot_Plates_Interface_Chamfer]){
            //build base
            translate([baseplateEndLateralWidth/2,0,-(height+Top_Bot_Plates_Interface_Chamfer)/2])
            mirror([0, 0, 1])
            intersection(){
                tilt(); //tilt bevel stretched upward
                
                base(); //base bevel stretched upward

                //rest                
                translate([-width/2, 0])
                    linear_extrude((height+Top_Bot_Plates_Interface_Chamfer)*2, center = true)
                    square([width, depth], true);
            }
            children();
        }
    }

    //the lower chamfer section
    module base() {
        
        stretch()
        down(baseplateEndAngleBevel)
        intersection(){
            //basechamfer
            //scale([1, 1, 1])
            roof()
            square([width*2, depth], true);
            
            linear_extrude(baseplateEndAngleBevel)
            square([width*2, depth], true);
        }
    }

        //tilt();

    module tilt() {
        stretch()
        rotate([0, -baseplateEndAngleUp, 0])
        intersection(){
            roof()
            radius(radius)
            square([baseplateEndAngleDistance*2, depth], true);
            
            linear_extrude(baseplateEndAngleBevel/2)
            square([baseplateEndAngleDistance*2, depth], true);
        }    
    }

    module stretch() { 
        minkowski(){
            children();
            
            mirror([0, 0, 1])
            cylinder(r1 = 0, r2 = 0.001, h = 100);
        }
    }

    module radius(amount) {
        offset(r = amount)
        offset(delta = -amount)
        children();
    }
}

module BasePlateEndRounded(width, depth, height = 19, half = LEFT, style="Oct"){

    $fn = 
        style == "Rounded" ? curve_resolution : 
        style == "Oct" ? 8 :
        style == "Hex" ? 6 :
        curve_resolution;

    //adjust the diameter if a hexagon
    adjusted_diameter = 
        style == "Hex" ? depth * sqrt(3) / 1.5 +1: depth;

    color(Disable_Colors ? undef : Primary_Color)
    half_of(half, s = adjusted_diameter*2 + 5)
    diff("HOKConnectors Dovetails", "k1")
    diff("r1", "keep HOKConnectors Dovetails"){
        //main plate
        cyl(d=adjusted_diameter, h= height+Top_Bot_Plates_Interface_Chamfer, anchor=BOT){
            //bot chamfer
            tag("r1")
            edge_profile([BOT])
                mask2d_chamfer(x=Baseplate_Bottom_Chamfer);
            //top chamfer
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cyl(d=adjusted_diameter, h=Top_Bot_Plates_Interface_Chamfer, chamfer1 = Top_Bot_Plates_Interface_Chamfer);
            //inside cutout
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.02)
                cyl(d=depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, h=height-Tile_Thickness+Top_Bot_Plates_Interface_Chamfer, chamfer1 = (height - Tile_Thickness));
            //top plate tabs
            tag("keep")
            right(half == LEFT ? -TabDistanceFromOutsideEdge-TopPlateTabWidth/2 : TabDistanceFromOutsideEdge+TopPlateTabWidth/2)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                TopPlateTab(height = height + TabProtrusionHeight, deleteTool = false);

            //HOK Connector cutouts
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01) 
                grid_copies(spacing=[HOK_Connector_Inset*2-clearance*2,HOK_Connector_Spacing_Depth])
                zrot(90)
                    HOKConnectorDeleteTool();
            if(Additional_Top_Plate_Support)
                //middle support
                tag("keep")
                down(Top_Bot_Plates_Interface_Chamfer)
                attach(TOP, TOP, inside=true)
                    cuboid([28*2.5-2,28*4,height - 4], chamfer=height-Tile_Thickness, edges=[TOP])
                    //dovetails
                    right(half == LEFT ? -4.5 : 4.5)zrot(half == LEFT ? 90 : -90)
                    tag("Dovetails")
                        attach(TOP, BACK, inside=true, shiftout = 0.01) 
                            xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                                //dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height,chamfer=Dovetail_Chamfer);
        }
    }
}

module BasePlateCore(width, depth, height = 19, spin = 0, orient = UP, anchor=CENTER){


    color(Disable_Colors ? undef : Primary_Color)
    diff("HOKConnectors Dovetails", "k1")
        diff("r1", "keep HOKConnectors Dovetails"){
        //main plate
        cuboid([width-clearance*2, depth, height + Top_Bot_Plates_Interface_Chamfer], chamfer=Baseplate_Bottom_Chamfer, edges=BOT+FRONT, anchor=BOT, spin=0,orient=UP){
            //top chamfer
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cuboid([width+0.02, depth, Top_Bot_Plates_Interface_Chamfer+0.02], chamfer = Top_Bot_Plates_Interface_Chamfer, edges=[BOT+FRONT, BOT+BACK]);
            //Inside cutout
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cuboid([width+0.02, depth-Minimum_Flat_Resting_Surface*2-Top_Bot_Plates_Interface_Chamfer*2, height + Top_Bot_Plates_Interface_Chamfer - Tile_Thickness +0.02],  chamfer = (height - Tile_Thickness), edges=[BOT+FRONT, BOT+BACK]);
            //cutout for opengrid and opengrid. 
            tag("r1")
            attach(BOT, BOT, inside=true, shiftout=0.01)
                cuboid([Grid_Width_mm, Grid_Depth_mm, Tile_Thickness+0.01]){
                    tag("keep")
                        openGrid(Board_Width = openGrid_Render ? Available_Grid_Width_Units : 1, Board_Height = openGrid_Render ? Available_Grid_Depth_Units : 1, Tile_Thickness = Tile_Thickness);
                }
            //top plate tabs
            tag("keep")
            attach(BOT, BOT, inside=true, align=[LEFT, RIGHT], inset=TabDistanceFromOutsideEdge)
                TopPlateTab(height = height + TabProtrusionHeight);
            //middle support
            tag_this("keep")
            down(Top_Bot_Plates_Interface_Chamfer)
                attach(TOP, TOP, inside=true, align=[LEFT, RIGHT])
                    cuboid([28*(Additional_Top_Plate_Support + 0.5),28*4,height - 6.8], chamfer=height-Tile_Thickness, edges=[TOP], except=$idx == 0 ? LEFT : RIGHT){
                        //dovetail
                        tag("Dovetails")
                            attach($idx == 0 ? LEFT : RIGHT, BOT, inside=true, shiftout = 0.01, align=TOP) 
                                xcopies(spacing = Dovetail_Spacing)
                                Dovetail_Female();
                        //display-only male dovetails
                        //if(Show_Connected){
                        //    #tag("keep")
                        //    back($idx == 0 ? Dovetail_Width/2 : -Dovetail_Width/2)
                        //        attach(TOP, TOP, inside=true, shiftout = 0.01, align=$idx == 0 ? LEFT : RIGHT, inset = 0) 
                        //            ycopies(spacing = Dovetail_Spacing)
                        //                zrot(90)
                        //                    Dovetail_Male();
                        //}
                    }
            children();
        
            //HOK connector cutouts back
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01, align=BACK) 
                    fwd(HOK_Connector_Inset-HOK_Connector_Thickness/2)
                    xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        HOKConnectorDeleteTool(anchor=CENTER);
            //HOK connector cutouts sides
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01, align=[LEFT, RIGHT], inset=HOK_Connector_Inset-clearance) 
                    back($idx == 1 ? HOK_Connector_Width/2 : -HOK_Connector_Width/2)
                    ycopies(spacing = HOK_Connector_Spacing_Depth)
                            HOKConnectorDeleteTool(spin=90);
        }
    }
}

module TopPlateTab(height = 19, deleteTool = false, anchor=CENTER, spin=0, orient=UP){
    TopPlateTabWidth = 3;
    TopPlateTabDepth = 20;
    //TopPlateTabHeight = 4;
    TopPlateTabChamfer = 0.5;

    cuboid([ deleteTool ? TopPlateTabWidth + clearance*2 : TopPlateTabWidth, deleteTool ? TopPlateTabDepth + clearance*2 : TopPlateTabDepth, deleteTool ? height + clearance : height], chamfer=TopPlateTabChamfer, except=BOT)
        children();
}

module Backer(anchor=BOT, spin=0, orient=UP){

        //main body
        color(Disable_Colors ? undef : Primary_Color)
        diff("HOKConnector", "k1")
        diff("remove", "keep HOKConnector"){
            cuboid([Backer_Width-clearance*2, Backer_Thickness, Backer_Height], anchor=anchor, orient=orient, spin=spin){
                //clear space for opengrid
                //if(Available_Grid_Height>0)
                up(Grid_Dist_From_Bot)
                    attach(BACK, BOT, inside=true, align=BOT, shiftout=0.01) 
                        cuboid([Available_Grid_Width_Units*openGridSize-0.02, Available_Grid_Height > 0 ? Available_Grid_Height*openGridSize -0.02 : Backer_Height - minimumTopSpacing - Grid_Dist_From_Bot, Backer_Thickness+0.02]);
                //opengrid
                tag("keep")
                up(Grid_Dist_From_Bot)
                attach(BACK, BOT, inside=true, align=BOT) 
                    openGrid(openGrid_Render ? Available_Grid_Width_Units : 1, openGrid_Render ? Available_Grid_Height : 1)
                        //HOK Tab Blocks
                        if(enableHOKBlocks)
                        xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        attach(BOT, TOP, inside=true, align=BACK, shiftout=0.01)
                            cuboid([openGridSize, openGridSize, Backer_Thickness-sideCutoutDepth], chamfer=0.5, edges=BOT, except_edges=BACK);
                //cutouts for risers
                attach(FRONT, FRONT, inside=true, shiftout=0.01, align=[LEFT, RIGHT])
                    cuboid([sideCutoutWidth,sideCutoutDepth,Backer_Height+0.02]);
                //HOK Connector cutouts
                tag("HOKConnector")
                attach(TOP, BOT, inside=true, shiftout=0.01, align=BACK) 
                    fwd(HOK_Connector_Inset-HOK_Connector_Thickness/2)
                    xcopies(spacing = Default_HOK_Connector_Spacing_Back)
                        HOKConnectorDeleteTool(anchor=CENTER);
                //Riser Tabs
                tag("keep")
                attach(BACK, BOT, align=[LEFT, RIGHT], inset=Backer_To_Riser_Tab_Inset-clearance, inside=true)
                    TopPlateTab(height = Backer_Thickness - sideCutoutDepth + Backer_To_Riser_Tab_Depth, deleteTool = false);

                children();
            }
        }          

}

module Riser(anchor=BOT, spin=0, orient=UP){
    number_of_slides = quantdn((Riser_Height - Slide_Distance_From_Bottom - Slide_Height - Slide_Minimum_Distance_From_Top)/Slide_Vertical_Separation+1, 1);
    
    //main riser body
    color(Disable_Colors ? undef : Primary_Color)
    diff(){
        cuboid([Riser_Width-clearance*2, Riser_Depth, Riser_Height], anchor=anchor, orient=orient, spin=spin){
            //Slides
            attach([LEFT, RIGHT], LEFT, inside=true, shiftout=0.01, align=BOT) 
                ycopies(spacing = Slide_Vertical_Separation, sp=[0,Slide_Distance_From_Bottom], n = number_of_slides)
                    Drawer_Slide(deleteTool = true);
            //HOK Connector cutouts
            attach(TOP, BOT, inside=true, shiftout=0.01) 
                grid_copies(spacing=[HOK_Connector_Inset*2-clearance,HOK_Connector_Spacing_Depth])
                zrot(90)
                    HOKConnectorDeleteTool();
            xcopies(spacing = TopPlateTabWidth + Backer_To_Riser_Tab_Inset*2)
            attach(BACK, BOT, inside=true, shiftout=0.01)
                    TopPlateTab(height = Backer_To_Riser_Tab_Depth + clearance, deleteTool = true);
            children();
        }
    }
}


module Dovetail_Male(anchor=CENTER, spin = 0, orient = UP){
    attachable(anchor, spin, orient, size=[Dovetail_Width,Dovetail_Height*2,Dovetail_Depth]){
        mirror_copy([0,1,0])
            dovetail("male", slide=Dovetail_Depth-0.6, width=Dovetail_Width, height=Dovetail_Height,chamfer=Dovetail_Chamfer, taper = -3, slope = 4, anchor=BOT, orient=FRONT);
        children();
    }
}

module Dovetail_Female(anchor=BOT, spin = 0, orient = DOWN){
    dovetail("female", slide=Dovetail_Depth, width=Dovetail_Width, height=Dovetail_Height, chamfer=Dovetail_Chamfer, slope = 4, taper = -3, $slop = 0, anchor=anchor, spin=spin, orient=orient)
        children();
}

module Drawer_Slide(length = Riser_Depth+0.02, deleteTool = false, anchor=CENTER, spin=0, orient=UP){
    
    
    attachable(anchor, spin, orient, size=[Slide_Width,length,Slide_Height]){
        move([-Slide_Width/2, length/2,-Slide_Height/2 ])
            xrot(90)
                linear_sweep(deleteTool ? Drawer_Slide_DeleteTool_Profile() : Drawer_Slide_Profile(), height = length) ;
        children();
    }

    function Drawer_Slide_DeleteTool_Profile() = [
        [0,0],
        [Slide_Width,Slide_Width],
        [Slide_Width,Slide_Height],
        [0,Slide_Height]
    ];

    function Drawer_Slide_Profile() = [
        [0,0],
        [Slide_Width-Slide_Clearance,Slide_Width-Slide_Clearance],
        [Slide_Width-Slide_Clearance,Slide_Height-Slide_Clearance*2],
        [0,Slide_Height-Slide_Clearance*2]
    ];
}

module HOKConnectorDeleteTool(anchor=CENTER, spin=0, orient=UP){
    //thickness = 3.2;
    chamfer = 0.5;

    attachable(anchor, spin, orient, size=[8.9*2,HOK_Connector_Thickness,15.2]){
    down(15.2/2)xrot(90)
        skin( 
            [mirrorXProfile(connector_path_chamfered()), mirrorXProfile(connector_path_full()), mirrorXProfile(connector_path_full()), mirrorXProfile(connector_path_chamfered())],
            z=[-HOK_Connector_Thickness/2,-HOK_Connector_Thickness/2+chamfer, HOK_Connector_Thickness/2-chamfer, HOK_Connector_Thickness/2],
            slices=0
        );
    children();
    }

    //outer profile of connector cutout
    function connector_path_full() = [
        [-7.9, 0],
        [-7.9, 4.875],
        [-8.9, 5.862],
        [-8.9, 8.084],
        [-7.9, 9.097],
        [-7.9, 13.083],
        [-5.783, 15.2],
        //[0, 15.2] midpoint
    ];

    //couldn't figure out the chamfer so I just mapped the points of the smaller profile for now
    function connector_path_chamfered() = [
        [-7.4, 0],
        [-7.4, 5.084],
        [-8.4, 6.071],
        [-8.4, 7.879],
        [-7.4, 8.892],
        [-7.4, 12.876],
        [-5.576, 14.7],
        //[0, 14.7] midpoint
    ];

    function mirrorX(pt) = [ -pt[0], pt[1] ];

    function mirrorXProfile(pathInput) =
        let(
            half = pathInput
        )
        concat(
            half,
            // Mirror in *reverse index* so the final perimeter is a continuous loop
            [ for(i = [len(half)-1 : -1 : 0]) mirrorX(half[i]) ]
        );

}


//BEGIN openGrid Import - Replace with import
module openGridLite(Board_Width, Board_Height, tileSize = 28, Screw_Mounting = "None", Bevels = "None", anchor = CENTER, spin = 0, orient = UP, Connector_Holes = false) {
    // Screw_Mounting options: [Everywhere, Corners, None]
    // Bevel options: [Everywhere, Corners, None]
    Tile_Thickness = 6.8;
    Lite_Tile_Thickness = 4;
    
    attachable(anchor, spin, orient, size = [Board_Width * tileSize, Board_Height * tileSize, 4]) {
        render(convexity = 2)
        down(4 / 2)
        down(Tile_Thickness - 4)
        top_half(z = Tile_Thickness - 4, s = max(tileSize * Board_Width, tileSize * Board_Height) * 2)
        openGrid(
            Board_Width = Board_Width,
            Board_Height = Board_Height,
            tileSize = tileSize,
            Screw_Mounting = Screw_Mounting,
            Bevels = Bevels,
            anchor = BOT,
            Connector_Holes = Connector_Holes
        );
    children();
    }
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
                    }
                    //outward flare fillet for easier insertion
                    rect([1,connector_cutout_separation*2-(connector_cutout_dimple_radius-connector_cutout_separation)], rounding=[0,-.25,-.25,0], $fn=32, corner_flip=true, anchor=LEFT);
                }
            children();
        }
    }
    //END CUTOUT TOOL

    module openGridTileAp1(tileSize = 28, Tile_Thickness = 6.8){
        Tile_Thickness = Tile_Thickness;
        
        Outside_Extrusion = 0.8;
        Inside_Grid_Top_Chamfer = 0.4;
        Inside_Grid_Middle_Chamfer = 1;
        Top_Capture_Initial_Inset = 2.4;
        Corner_Square_Thickness = 2.6;
        Intersection_Distance = 4.2;

        Tile_Inner_Size_Difference = 3;



        calculatedCornerSquare = sqrt(tileSize^2+tileSize^2)-2*sqrt(Intersection_Distance^2/2)-Intersection_Distance/2;
        Tile_Inner_Size = tileSize - Tile_Inner_Size_Difference; //25mm default
        insideExtrusion = (tileSize-Tile_Inner_Size)/2-Outside_Extrusion; //0.7 default
        middleDistance = Tile_Thickness-Top_Capture_Initial_Inset*2;
        cornerChamfer = Top_Capture_Initial_Inset-Inside_Grid_Middle_Chamfer; //1.4 default

        CalculatedCornerChamfer = sqrt(Intersection_Distance^2 / 2);
        cornerOffset = CalculatedCornerChamfer + Corner_Square_Thickness; //5.56985 (half of 11.1397)

        CorderSquareWidth = sqrt(Corner_Square_Thickness^2 + Corner_Square_Thickness^2)+Intersection_Distance;
        
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
            [cornerOffset-cornerChamfer,0],
            [cornerOffset,cornerChamfer],
            [cornerOffset,Tile_Thickness-cornerChamfer],
            [cornerOffset-cornerChamfer,Tile_Thickness],
            [0,Tile_Thickness]

            ];
        
        path_tile = [[tileSize/2,-tileSize/2],[-tileSize/2,-tileSize/2]];
        
        intersection() {
        union() {
            zrot_copies(n=4)
                union() {
                    path_extrude2d(path_tile) 
                        polygon(full_tile_profile);
                    move([-tileSize/2,-tileSize/2])
                        rotate([0,0,45])
                            back(cornerOffset)
                                rotate([90,0,0])
                                    linear_extrude(cornerOffset*2) 
                                        polygon(full_tile_corners_profile);
                }
        } 
        cube([tileSize, tileSize, Tile_Thickness], anchor = BOT);
        }
    }
}