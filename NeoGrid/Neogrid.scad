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


gridfinity_bin_bottom_grid(2, 2);

//gridfinity_bin_bottom();

module gridfinity_bin_bottom_grid(x, y, additionalHeight = 1){
    up(4.75+additionalHeight/2)
    minkowski(){
        cuboid([x*41.75-5.9+.25*(x-2), y*41.75-5.9+.25*(y-2), additionalHeight]);
        cyl(h=0.01, d=5.9, $fn=50);
    }
    translate([42/2-42/2*x,42/2-42/2*y,0])
    //translate([-x*42/2, -y*42/2,0])
    for (i = [0:x-1]){
        for (j = [0:y-1]){
            translate([i*42, j*42, 0]){
                gridfinity_bin_bottom(anchor=BOT);
            }
        }
    }
}

module gridfinity_bin_bottom(additionalHeight = 0, anchor, spin, orient){
    attachable(anchor, spin, orient, size=[41.5, 41.5, 4.75]){
                translate(v = [-35.6/2,-35.6/2,-4.75/2]) 
                    rotate(a = [0,0,0]) 
                        minkowski() {
                            rotate_extrude($fn=50) 
                                    polygon(points = [
                                        [0,0], //start at inner profile
                                        [0.8, 0.8], //up and out 0.8
                                        [0.8, 0.8 + 1.8], //up 1.8
                                        [0.8 + 2.15, 0.8 + 1.8 + 2.15], //up and out 2.15
                                        [0, 0.8 + 1.8 + 2.15] //back to inside
                                    ]); //Gridfinity Bin Bottom Specs
                            cube(size = [35.6,35.6,0.01+additionalHeight]);
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