/*Created by Andy Levesque

Credits:
    Credit to @David D on Printables and Jonathan at Keep Making for Multiconnect and Multiboard, respectively
    @Dontic on GitHub for Multiconnect v2 code

Licensed Creative Commons 4.0 Attribution Non-Commercial Sharable with Attribution

Change Log: 
- 2024-12-07
    - Initial Release
- 2025-03-11
    - Hole Cutout and Slot Cutout added (thanks @user_3620134323)
-2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
*/

/*[Parameters]*/
//diameter (in mm) of the item you wish to insert (this becomes the internal diameter)
itemDiameter = 50; //0.1
//thickness (in mm) of the wall surrounding the item
rimThickness = 1;
//Thickness (in mm) of the base underneath the item you are holding
baseThickness = 3;
//Additional thickness of the area between the item holding and the backer.
shelfSupportHeight = 3;
//Additional height (in mm) of the rim protruding upward to hold the item
rimHeight = 10;
//Additional Backer Height (in mm) in case you prefer additional support for something heavy
additionalBackerHeight = 0;
//Offset the holding position from the back wall
offSet = 0;
//Use cutout for holding items that are wider at the top
useCutout = false;

/*[Hole Cutout Customizations]*/
holeCutout = false;
//diameter/width of cord cutout
holeCutoutDiameter = 10;
//cut out a slot on the bottom and through the front
slotCutout = false;

/*[Slot Customization]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
distanceBetweenSlots = 25;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryXSlots = 1;


/*[Hidden]*/
totalWidth = itemDiameter + rimThickness*2;
totalHeight = max(baseThickness+shelfSupportHeight+0.25*itemDiameter,25);

//start build
translate(v = [-max(totalWidth,distanceBetweenSlots)/2,0,0]) 
    multiconnectBack(backWidth = totalWidth, backHeight = totalHeight+additionalBackerHeight, distanceBetweenSlots = distanceBetweenSlots);
    //item holder
translate(v = [-totalWidth/2,0,0]) 
union() {
    difference() {
        //itemwalls
        union() {
            hull(){
                translate(v = [totalWidth/2,itemDiameter/2+offSet,0])
                //outer circle
                linear_extrude(height = shelfSupportHeight+baseThickness)
                    circle(r = itemDiameter/2+rimThickness, $fn=50);
                //wide back for hull operation
                linear_extrude(height = shelfSupportHeight+baseThickness)
                    square(size = [totalWidth,1]);
            }
            //thin holding wall
            translate(v = [totalWidth/2,itemDiameter/2+offSet,shelfSupportHeight+baseThickness])
                linear_extrude(height = rimHeight)
                    circle(r = itemDiameter/2+rimThickness, $fn=50);
        }
        union(){
        //itemDiameter (i.e., delete tool)
            translate(v = [totalWidth/2,(itemDiameter/2)+offSet,baseThickness+.5 - (useCutout?+(baseThickness*2)+1:0)]) 
                linear_extrude(height = shelfSupportHeight+rimHeight+1+(useCutout?+(baseThickness*2):0)) 
                    circle(r = itemDiameter/2, $fn=50);

            //tool hole
            if (holeCutout == true) {
                translate(v = [totalWidth/2,(itemDiameter/2)+offSet]) union() {
                    linear_extrude(height = baseThickness*10) circle(r = holeCutoutDiameter/2, $fn=50);

                    if (slotCutout == true) {
                        translate(v = [-holeCutoutDiameter/2,0,0]) 
                            cube([holeCutoutDiameter, totalWidth/2, totalHeight]);
                    }
                }
            }
        }
    }
    //brackets
    bracketSize = min(totalHeight-baseThickness-shelfSupportHeight, itemDiameter/2);
    translate(v = [rimThickness,0,bracketSize+baseThickness+shelfSupportHeight]) 
        shelfBracket(bracketHeight = bracketSize, bracketDepth = bracketSize, rimThickness = rimThickness);
    translate(v = [rimThickness*2+itemDiameter,0,bracketSize+baseThickness+shelfSupportHeight]) 
        shelfBracket(bracketHeight = bracketSize, bracketDepth = bracketSize, rimThickness = rimThickness);
}

//BEGIN MODULES
//Slotted back Module
module multiconnectBack(backWidth, backHeight, distanceBetweenSlots)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots), backThickness = 6.5){
        difference() {
            translate(v = [0,-backThickness,0]) cube(size = [backWidth,backThickness,backHeight]);
            //Loop through slots and center on the item
            //Note: I kept doing math until it looked right. It's possible this can be simplified.
            for (slotNum = [0:1:slotCount-1]) {
                translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                    slotTool(backHeight);
                }
            }
        }
    }
    //Create Slot Tool
    module slotTool(totalHeight) {
        scale(v = slotTolerance)
        //slot minus optional dimple with optional on-ramp
        let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
        difference() {
            union() {
                //round top
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = slotProfile);
                //long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0]) 
                    union(){
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalHeight+1) 
                                polygon(points = slotProfile);
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2")
                                translate(v= [10.15,0,0])
                                rotate(a= [-90,0,0])
                                linear_extrude(height = 5)  // match slot height (5mm)
                                    polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                            }

                        mirror([1,0,0])
                            difference() {
                                // Main half slot
                                linear_extrude(height = totalHeight+1) 
                                    polygon(points = slotProfile);
                                
                                // Snap cutout
                                if (slotQuickRelease == false && multiConnectVersion == "v2")
                                    translate(v= [10.15,0,0])
                                    rotate(a= [-90,0,0])
                                    linear_extrude(height = 5)  // match slot height (5mm)
                                        polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                            }
                    }
                //on-ramp
                if(onRampEnabled)
                    for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                        translate(v = [0,-5,-y*distanceBetweenSlots]) 
                            rotate(a = [-90,0,0]) 
                                cylinder(h = 5, r1 = 12, r2 = 10.15);
            }
            //dimple
            if (slotQuickRelease == false && multiConnectVersion == "v1")
                scale(v = dimpleScale) 
                rotate(a = [90,0,0,]) 
                    rotate_extrude($fn=50) 
                        polygon(points = [[0,0],[0,1.5],[1.5,0]]);
        }
    }
}

module shelfBracket(bracketHeight, bracketDepth, rimThickness){
        rotate(a = [-90,0,90]) 
            linear_extrude(height = rimThickness) 
                polygon([[0,0],[0,bracketHeight],[bracketDepth,bracketHeight]]);
}
