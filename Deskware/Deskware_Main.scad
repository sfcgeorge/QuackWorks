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

//back(Riser_Depth/2+10)Backer();
Riser();

//Riser_Slide_Delete_Tool();

/*[Riser]*/
Riser_Width = 18;
Riser_Depth = 189;
Riser_Height = 80;

/*[Riser Slide]*/
//Width (and rise of angle) of the slide recess
Slide_Width = 4;
//Total height of the slide recess
Slide_Height = 10.5;
//Vertical distance between slides
Slide_Vertical_Separation = 40;
//Distance from the bottom of the riser to the bottom of the slide
Slide_Distance_From_Bottom = 11.75;

/*[Backer]*/
Backer_Width = 192;
Backer_Height = Riser_Height;


module Backer(){
    Backer_Depth = 12.5;
    
    //main body
    cuboid([Backer_Width, Backer_Depth, Backer_Height]);
}

module Riser(){
    //main riser body
    diff(){
        cuboid([Riser_Width, Riser_Depth, Riser_Height])
            //Slides
             up(11.75)
            attach([LEFT, RIGHT], LEFT, inside=true, shiftout=0.01, align=BOT) 
                ycopies(spacing = Slide_Vertical_Separation, sp=[0,0])
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
}

function Riser_Slide_Delete_Tool_Profile() = [
    [0,0],
    [Slide_Width,Slide_Width],
    [Slide_Width,Slide_Height],
    [0,Slide_Height]
];