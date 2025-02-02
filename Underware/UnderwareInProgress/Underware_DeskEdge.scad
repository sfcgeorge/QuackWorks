/*Created by BlackjackDuck (Andy) and Hands on Katie. Original model from Hands on Katie (https://handsonkatie.com/)
This code and all parts derived from it are Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)

Documentation available at https://handsonkatie.com/underware-2-0-the-made-to-measure-collection/

Credit to 
    First and foremost - Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
    @David D on Printables for Multiconnect
    Jonathan at Keep Making for Multiboard
    @cosmicdust on MakerWorld and @freakadings_1408562 on Printables for the idea of diagonals (forward and turn)
    @siyrahfall+1155967 on Printables for the idea of top exit holes
    @Lyric on Printables for the flush connector idea
    @fawix on GitHub for her contributions on parameter descriptors

Release Notes
    - 2024-12-06 
        - Initial Release
    2024-12-28
        - Added internal mitre corner
        - Fixed bug with top length calculation

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/threading.scad>

/*[Channel Size]*/
//Width (Y axis) of channel in units. Default unit is 25mm
Channel_Width_in_Units = 1;
//Height inside the channel (in mm). Z axis for top channel and X axis bottom channel.
Channel_Internal_Height = 12; //[12:6:72]
//Length (X axis) in mm of offset from edge of desk to start of Multiboard tiles.
Offset_to_Multiboard = 5;
//Length (Z axis) in mm of the channel up the back of the desk.
Thickness_of_Desk = 40;

//Slot for cable access in mm
Cable_slot = 6.5;

/*[Advanced Options]*/
//Units of measurement (in mm) for hole and length spacing. Multiboard is 25mm. Untested
Grid_Size = 25;
//Color of part (color names found at https://en.wikipedia.org/wiki/Web_colors)
Global_Color = "SlateBlue";

/*[Hidden]*/
channelWidth = Channel_Width_in_Units * Grid_Size;
baseHeight = 9.63;
topHeight = 10.968;
totalHeight = 17.4897; // Combined height
actualHeight = (totalHeight - 12) + Channel_Internal_Height; // Calculate height with selected Internal channel height
interlockOverlap = 3.09; //distance that the top and base overlap each other
interlockFromFloor = 6.533; //distance from the bottom of the base to the bottom of the top when interlocked
partSeparation = 10;
//length of channel in units (default unit is 25mm)
Channel_Length_Units = 6; 

/*

***BEGIN DISPLAYS***

*/

//top 'L' piece
// Offset piece
difference(){
color_this(Global_Color)
back(30)zrot(180) {
half_of(DOWN+RIGHT, s=Channel_Length_Units*Grid_Size*2)
    path_sweep(topProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", (Offset_to_Multiboard+actualHeight)*2]), anchor=TOP, orient=BOT);
// Desk piece
color_this(Global_Color)
rot([180,-90,0])
    half_of(DOWN+RIGHT, s=Channel_Length_Units*Grid_Size*2)
    path_sweep(completeProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", (Thickness_of_Desk+actualHeight)*2]), anchor=TOP, orient=BOT);
// Join piece
color_this(Global_Color)
up(Channel_Internal_Height+5.75)
zrot(180)
    path_sweep(joinProfile(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Channel_Internal_Height+5.49]), orient=BOT);
};
// Delete pieces
color_this(Global_Color)
back(30)zrot(180) {
// Inside
right(2)
up(20)
rot([180,-90,0])
    path_sweep(completeInside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", 30]), anchor=TOP, orient=BOT);
};
color_this(Global_Color)
back(30)zrot(180) {
// Outside
rot([180,-90,0])
    path_sweep(completeOutside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Thickness_of_Desk*2]), anchor=TOP, orient=BOT);

};
// Join Inside
color_this(Global_Color)
zrot(180) {
up(Channel_Internal_Height+5.75)
right(Channel_Internal_Height*1.5)
fwd(30)
    path_sweep(joinInside(widthMM = channelWidth, heightMM = Channel_Internal_Height), turtle(["xmove", Channel_Internal_Height ]), orient=BOT);
};
}




//BEGIN PROFILES - Must match across all files

//take the two halves of base and merge them
function baseProfile(widthMM = 25) = 
    union(
        left((widthMM-25)/2,baseProfileHalf), 
        right((widthMM-25)/2,mirror([1,0],baseProfileHalf)), //fill middle if widening from standard 25mm
        back(3.5/2,rect([widthMM-25+0.02,3.5]))
    );

//take the two halves of base and merge them
function topProfile(widthMM = 25, heightMM = 12) = 
    union(
        left((widthMM-25)/2,topProfileHalf(heightMM)), 
        right((widthMM-25)/2,mirror([1,0],topProfileHalf(heightMM))), //fill middle if widening from standard 25mm
        back(topHeight-1 + heightMM-12 , rect([widthMM-25+0.02,2])) 
    );

//take the two halves of complete and merge them
function completeProfile(widthMM, heightMM) =
    difference(
        union(
            left((widthMM-25)/2,completeProfileHalf(heightMM, widthMM)), 
            right((widthMM-25)/2,mirror([1,0],completeProfileHalf(heightMM, widthMM))) //fill middle if widening from standard 25mm
        ),
    back((heightMM-12)/2,rect([Cable_slot+0.02,15]))  
    );

function baseDeleteProfile(widthMM = 25) = 
    union(
        left((widthMM-25)/2,baseDeleteProfileHalf), 
        right((widthMM-25)/2,mirror([1,0],baseDeleteProfileHalf)), //fill middle if widening from standard 25mm
        back(6.575,rect([widthMM-25+0.02,6.15]))
    );

function topDeleteProfile(widthMM, heightMM = 12) = 
    union(
        left((widthMM-25)/2,topDeleteProfileHalf(heightMM)), 
        right((widthMM-25)/2,mirror([1,0],topDeleteProfileHalf(heightMM))), //fill middle if widening from standard 25mm
        back(4.474 + (heightMM-12)/2,rect([widthMM-25+0.02,8.988 + heightMM - 12])) 
    );

//take the two halves the base 'join piece' and merge them
function joinProfile(widthMM = 25, heightMM = 12) =
    difference(
        union(
                left((widthMM-25)/2,baseJoinHalf(heightMM)), 
                right((widthMM-25)/2,mirror([1,0],baseJoinHalf(heightMM))) //fill middle if widening from standard 25m
        ),
    back((topHeight+5.5 + 36 - (heightMM)),rect([Cable_slot+0.02,500])) 
    );

// Build the inside/outside delete part
function completeInside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,completeInsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],completeInsideHalf(heightMM, widthMM))) //fill middle if widening from standard 25mm
    );

function completeOutside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,completeOutsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],completeOutsideHalf(heightMM, widthMM)))
    );

function joinInside(widthMM, heightMM) =
    union(
        left((widthMM-25)/2,joinInsideHalf(heightMM, widthMM)), 
        right((widthMM-25)/2,mirror([1,0],joinInsideHalf(heightMM, widthMM)))
    );

baseProfileHalf = 
    fwd(-7.947, //take Katie's exact measurements for half the profile and use fwd to place flush on the Y axis
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,1.683],
            [-10.517,1.683],
            [-11.459,1.422],
            [-11.459,-0.297],
            [-11.166,-0.592],
            [-11.166,-1.414],
            [-11.666,-1.914],
            [-12.517,-1.914],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [0,-7.947]
        ]
);

function topProfileHalf(heightMM = 12) =
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            
            [0,7.554 + (heightMM - 12)],//-0.017 per Katie's diagram. Moved to zero
            [0,9.554 + (heightMM - 12)],
            [-8.517,9.554 + (heightMM - 12)],
            [-12.517,5.554 + (heightMM - 12)],
            [-12.517,-1.414],
            [-11.166,-1.414],
            [-11.166,-0.592],
            [-11.459,-0.297],
            [-11.459,1.422],
            [-10.517,1.683],
            [-10.517,4.725 + (heightMM - 12)],
            [-7.688,7.554 + (heightMM - 12)]
        ]
);

function completeProfileHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947, 
        [
            [0 + (widthMM - 25)/2,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM - 25)/2,7.5427 + (heightMM - 12)],
            [0 + (widthMM - 25)/2,9.5427 + (heightMM - 12)],
            [-8.5,9.5427 + (heightMM - 12)],
            [-12.517,5.5427 + (heightMM - 12)],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [0 + (widthMM - 25)/2,-7.947],
        ]
);

baseDeleteProfileHalf = 
    fwd(-7.947, //take Katie's exact measurements for half the profile of the inside
        //profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,-4.447], //inner x axis point with width adjustment
            [0,1.683+0.02],
            [-9.5,1.683+0.02],
            [-9.5,-3.447],
            [-8.5,-4.447],
        ]
);

function topDeleteProfileHalf(heightMM = 12)=
        back(1.414,//profile extracted from exact coordinates in Master Profile F360 sketch. Any additional modifications are added mathmatical functions. 
        [
            [0,7.554 + (heightMM - 12)],
            [-7.688,7.554 + (heightMM - 12)],
            [-10.517,4.725 + (heightMM - 12)],
            [-10.517,1.683],
            [-11.459,1.422],
            [-11.459,-0.297],
            [-11.166,-0.592],
            [-11.166,-1.414-0.02],
            [0,-1.414-0.02]
        ]
);

function baseJoinHalf(heightMM = 12) =
        fwd(-7.947,
        [
            [-9.5,6 + (heightMM - 12)],
            [-12.517,5.554 + (heightMM - 12)],
            [-12.517,-4.448],
            [-10.517,-6.448],
            [-10.517,-7.947],
            [-2.967,-7.947],
            [-9.5,-1.414]
        ]
);
// Delete inside 'Complete'
function completeInsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [0 + (widthMM-25)/2,-4.447],
            [-8.5,-4.447],
            [-9.5,-3.447],
            [-9.5,0],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM-25)/2,7.5427 + (heightMM - 12)]
        ]
);
// Delete outside 'Complete'
function completeOutsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [-8.5,9.5427],
            [-12.517,5.5427],
            [-12.517,9.5427]
        ]
);

// Delete inside 'Join'
function joinInsideHalf(heightMM = 12, widthMM = 25) =
        fwd(-7.947,
        [
            [0 + (widthMM-25)/2,-8],
            [-2.914,-8],
            [-9.5,-1.414],
            [-9.5,0],
            [-9.5,5.7427 + (heightMM - 12)],
            [-7.7,7.5427 + (heightMM - 12)],
            [0 + (widthMM-25)/2,7.5427 + (heightMM - 12)]
        ]
);


//calculate the max x and y points. Useful in calculating size of an object when the path are all positive variables originating from [0,0]
function maxX(path) = max([for (p = path) p[0]]) + abs(min([for (p = path) p[0]]));
function maxY(path) = max([for (p = path) p[1]]) + abs(min([for (p = path) p[1]]));


