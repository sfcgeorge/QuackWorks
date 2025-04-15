/* 
Deskware
Design by Hands on Katie
OpenSCAD by BlackjackDuck (Andy)

This code is Licensed Creative Commons 4.0 Attribution Non-Commercial Share-Alike (CC-BY-NC-SA)
Derived parts are licensed Creative Commons 4.0 Attribution (CC-BY)

Change Log:
- 2025- 
    - Initial release

Credit to 
    Katie and her community at Hands on Katie on Youtube, Patreon, and Discord
*/

include <BOSL2/std.scad>

Side_1_Depth = 15;
Side_2_Depth = 15;
Pre_Tab_Width = 15;

HOKOutsideProfileHalf = turtle([
    "move", 5, 
    "left", 45,
    "move", 0.5,
    "arcright", 1, 45,
    "move", 1.8,
    "arcright", 1, 45,
    "move", 0.5,
    "left", 45,
    "move", 3.156,
    "arcright", 1, 45,
    "move", 1.172,
    "arcright", 1, 45,
    "move", 4.672,
    "arcright", 1, 45,
    "move", 1.172,
    "arcright", 1, 45,
    "move", 3.156,
    "left", 45,
    "move", 0.5,
    "arcright", 1, 45,
    "move", 1.8,
    "arcright", 1, 45,
    "move", 0.5,
    "left", 45,
    "move", 5,
]);


stroke(HOKOutsideProfileHalf, width=0.05, closed=true);