/*Created by Hands on Katie and BlackjackDuck (Andy)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @dmgerman on MakerWorld and @David D on Printables for the bolt thread specs
    Jonathan at Keep Making for Multiboard
    @Lyric on Printables for the flush connector idea

    
All parts except for Snap Connector are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Snap Connector adopts the Multiboard.io license at multiboard.io/license
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Choose Part]*/
//How do you intend to mount the channels to a surface such as Honeycomb Storage Wall or Multiboard? See options at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/
Show_Part = "Snap Keyhole"; // [Snap Keyhole]

/*[Options: Thread Snap Connector ]*/
//Height (in mm) the snap connector rests above the board. 3mm is standard. 0mm results in a flush fit. 
Snap_Connector_Height = 3;
//Scale of the Snap Connector holding 'bumpouts'. 1 is standard. 0.5 is half size. 1.5 is 50% larger. Large = stronger hold. 
Snap_Holding_Tolerance = 1; //[0.5:0.05:2.0]


/*[Advanced Options]*/
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";
//Octogon Scaling - Decrease if the octogon is too large for the snap connector. Increase if the octogon is too small.
Oct_Scaling = 1; //[0.8:0.01:1.2]

/*[keyhole]*/
// Depth (in mm) from the flush surface of the object to the bottom of the keyhole (larger number)
keyholeTotalDepth=5.5;
// Depth of the throat of the key.
keyholeEntranceDepth=2.55;
// Diameter of the larger keyhole opening
keyholeEntraceDiameter=7.5;
// diameter of the smaller keyhole slot
keyholeSlotDiameter=4;
// Pick a point on a keyhole and measure (in mm) from that point to the same point on the other hole
distanceBetweenKeyholeEntranceCenters = 144; 


/*

MOUNTING PARTS

*/

if(Show_Part == "Snap Keyhole"){
    octogonScale = 1/sin(67.5);
    innerMostDiameter = (11.4465 * 2) * octogonScale;
    remainingOffset = 25 - (distanceBetweenKeyholeEntranceCenters % 25);
    remainingOffset2 = ( 25-(distanceBetweenKeyholeEntranceCenters % 25) <= 12.5) ? 25 - (distanceBetweenKeyholeEntranceCenters % 25) : (distanceBetweenKeyholeEntranceCenters % 25);
    offsetToEdge = (innerMostDiameter - (keyholeEntraceDiameter)) / 2;
    keyhole1Offset = (remainingOffset2 < offsetToEdge) ? 0 : (remainingOffset2 * -0.5 );
    keyhole2Offset = (remainingOffset2 < offsetToEdge) ? remainingOffset2 : (remainingOffset2 * 0.5 );
    
    recolor(Global_Color)
    make_ThreadedSnap(offset = Snap_Connector_Height, anchor=BOT, keyholeOffset=keyhole1Offset);
    fwd(25 - keyhole2Offset + keyhole1Offset) make_ThreadedSnap(offset = Snap_Connector_Height, anchor=BOT, keyholeOffset=keyhole2Offset);
    
}

//THREADED SNAP
module make_ThreadedSnap (offset = 3, anchor=BOT,spin=0,orient=UP, keyholeOffset){
    left(0.2)yrot(-90)right_half()
    cyl(d=keyholeEntraceDiameter, h=keyholeTotalDepth-keyholeEntranceDepth, anchor=BOT)
        position(TOP) cyl(d=keyholeSlotDiameter, h=keyholeEntranceDepth, anchor=BOT)
            position(TOP) fwd(keyholeOffset) snapConnectBacker(
                offset = offset, 
                holdingTolerance = Snap_Holding_Tolerance, anchor=TOP, orient=DOWN) ;
    right(0.2)yrot(90)left_half()
    cyl(d=keyholeEntraceDiameter, h=keyholeTotalDepth-keyholeEntranceDepth, anchor=BOT)
        position(TOP) cyl(d=keyholeSlotDiameter, h=keyholeEntranceDepth, anchor=BOT)
            position(TOP) fwd(keyholeOffset) snapConnectBacker(
                offset = offset, 
                holdingTolerance = Snap_Holding_Tolerance, anchor=TOP, orient=DOWN) ;
    cuboid([0.42,keyholeEntraceDiameter,0.2], anchor=BOT);
}

module snapConnectBacker(offset = 0, holdingTolerance=1, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[11.4465*2, 11.4465*2, 6.17+offset]){ 
    //bumpout profile
    bumpout = turtle([
        "ymove", -2.237,
        "turn", 40,
        "move", 0.557,
        "arcleft", 0.5, 50,
        "ymove", 0.252
        ]   );

    down(6.2/2+offset/2)
    union(){
    diff("remove")
        //base
            oct_prism(h = 4.23, r = 11.4465*Oct_Scaling, anchor=BOT) {
                //first bevel
                attach(TOP, BOT, shiftout=-0.01) oct_prism(h = 1.97, r1 = 11.4465, r2 = 12.5125, $fn =8, anchor=BOT)
                    //top - used as offset. Independen snap height is 2.2
                    attach(TOP, BOT, shiftout=-0.01) oct_prism(h = offset, r = 12.9885, anchor=BOTTOM);
                        //top bevel - not used when applied as backer
                        //position(TOP) oct_prism(h = 0.4, r1 = 12.9985, r2 = 12.555, anchor=BOTTOM);
            
            //end base
            //bumpouts
            attach([RIGHT, LEFT, FWD, BACK],LEFT, shiftout=-0.01)  color("green") down(0.87) fwd(1)scale([1,1,holdingTolerance]) zrot(90)offset_sweep(path = bumpout, height=3);
            //delete tools
            //Bottom and side cutout - 2 cubes that form an L (cut from bottom and from outside) and then rotated around the side
            tag("remove") 
                 align(BOTTOM, [RIGHT, BACK, LEFT, FWD], inside=true, shiftout=0.01, inset = 1.6) 
                    color("lightblue") cuboid([0.8,7.161,3.4], spin=90*$idx)
                        align(RIGHT, [TOP]) cuboid([0.8,7.161,1], anchor=BACK);
            }
    }
    children();
    }

    //octo_prism - module that creates an oct_prism with anchors positioned on the faces instead of the edges (as per cyl default for 8 sides)
    module oct_prism(h, r=0, r1=0, r2=0, anchor=CENTER, spin=0, orient=UP) {
        attachable(anchor, spin, orient, size=[max(r*2, r1*2, r2*2), max(r*2, r1*2, r2*2), h]){ 
            down(h/2)
            if (r != 0) {
                // If r is provided, create a regular octagonal prism with radius r
                rotate (22.5) cylinder(h=h, r1=r, r2=r, $fn=8) rotate (-22.5);
            } else if (r1 != 0 && r2 != 0) {
                // If r1 and r2 are provided, create an octagonal prism with different top and bottom radii
                rotate (22.5) cylinder(h=h, r1=r1, r2=r2, $fn=8) rotate (-22.5);
            } else {
                echo("Error: You must provide either r or both r1 and r2.");
            }  
            children(); 
        }
    }
    
}
