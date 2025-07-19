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
- 2025-07-15
    - New Multiconnect v2 option added with improved holding (thanks @dontic on GitHub!)
- 2025-07-19 @timtucker
    - Curved support structure (should be stronger, print faster, and use less filament)
    - Allow the hole / slot to be repositioned
    - Prevent the hole / slot from extending into the back wall
    - Allow tuning of the resolution of circles and curves
    - Simplify / reorganize parameters
*/

/*[Parameters]*/
// Diameter (in mm) of the item you wish to insert (this becomes the internal diameter)
itemDiameter = 50; // 0.1
// Distance (in mm) from the back wall to the back rim
offSet = 0;

/*[Rim]*/
// Height (in mm) of the rim protruding upward to hold the item
rimHeight = 10;
// Thickness (in mm) of the wall surrounding the item
rimThickness = 1;

/*[Cutout]*/
// Diameter of a hole (in mm) for items to pass through (leave 0 for no cutout)
cutoutDiameter = 0;
// Offset from the center (in mm) for the hole to start (postive values extend towards the front wall, negative values extend towards the back wall)
cutoutStart = 0;
// Offset from the center (in mm) for the hole to end (postive values extend towards the front wall, negative values extend towards the back wall)
cutoutEnd = 0;

/*[Support]*/
// Thickness (in mm) of the base underneath the item you are holding (leave 0 for an open hole to hang items)
baseThickness = 3;
// If the rim is shorter than the total height, slope towards the back wall
slopeTowardsBackWall = true;

/*[Multiconnect]*/
// Version of multiconnect (dimple or snap)
multiConnectVersion = "v2"; // [v1, v2]
// Distance between Multiconnect slots on the back (25mm is standard for MultiBoard, 28mm for openGrid)
distanceBetweenSlots = 25;
// Number of vertical slots for the attachment (recommended to have at least 1/4 the item diameter)
slotsHigh = 1; // [1:0.5:20]
// Number of horizontal slots for the attachment
slotsWide = 2; // [1:1:20]
// QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
// Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; // [0.5:0.05:1.5]
// Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; // [0.925:0.005:1.075]
// Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; // [-.5:0.05:.5]
// Enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
// Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryXSlots = 1;

/*[Performance]*/
// Resolution for circles and curves (higher values are smoother but slower to render)
circleResolution = 500; // [50:50:1000]

/*[Hidden]*/

// Shortcuts for reference measurements and positions
totalWidth = itemDiameter + rimThickness * 2;
totalHeight = slotsHigh * distanceBetweenSlots;
itemCenterX = totalWidth / 2;
itemCenterY = totalWidth / 2 + offSet;
heightAboveRim = totalHeight - rimHeight;

maxZHeight = max(totalHeight, rimHeight + baseThickness);

beyondX = itemCenterX * 10;
beyondY = itemCenterY * 10;
beyondZ = maxZHeight * 10;

// Curve support angling up towards the back wall
supportHeight = slopeTowardsBackWall ? totalHeight : rimHeight + baseThickness;
supportCurveY = itemCenterY * 2;
supportCurveZ = heightAboveRim * 2;

// Stop the cutout from extending into the back wall
adjustedCutoutDiameter = min(cutoutDiameter, itemDiameter);
adjustedCutoutStart = max((adjustedCutoutDiameter/2) - itemCenterY, cutoutStart);
adjustedCutoutEnd = max((adjustedCutoutDiameter/2) - itemCenterY, cutoutEnd);

offsetWidth = min(totalWidth, distanceBetweenSlots * slotsWide);

//item holder
difference() {
    // Item holder and support structure
    union() {
        // Outer cylinder for the item holder
        createElongatedRoundObject(height = rimHeight + baseThickness, diameter = totalWidth, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);

        // Support structure
        difference() {
            // Fill the space between the item holder and the back wall along the base
            hull() {
                createElongatedRoundObject(height = supportHeight, diameter = totalWidth, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);

                // Create the shell to hold the multiconnect slots
                createMulticonnectBackShell(distanceBetweenSlots = distanceBetweenSlots, slotsWide = slotsWide, slotsHigh = slotsHigh);
            }

            // Slope from rim to back wall
            if (slopeTowardsBackWall == true && totalHeight > rimHeight + baseThickness) {
                union() {
                    // For the curve, subtract a cylinder that extends from the rim up to the back wall
                    translate(v = [-0.5 * beyondX, supportCurveY / 2, baseThickness + rimHeight + (supportCurveZ / 2)]) {
                        scale(v = [1, supportCurveY, supportCurveZ]) {
                            rotate([0, 90, 0]) {
                                cylinder(h = beyondY, d = 1, $fn = circleResolution);
                            }
                        }
                    }
                    // Remove the front half of the cylinder
                    translate(v = [-0.5* beyondX, itemCenterY, rimHeight + baseThickness]) {
                        cube([beyondX, beyondY, beyondZ]);
                    }
                }
            }
        }
    }
    union() {
        // Cut out a cylinder for the item to fit into
        translate(v = [0, 0, (baseThickness > 0) ? baseThickness : -0.5 * beyondZ]) {
            createElongatedRoundObject(height = beyondZ, diameter = itemDiameter, yCenterStart = itemCenterY, yCenterEnd = itemCenterY, circleResolution = circleResolution);
        }

        // Cut out a hole / slot
        createCutout(holeDiameter = adjustedCutoutDiameter, yCenterStart = itemCenterY + adjustedCutoutStart, yCenterEnd = itemCenterY + adjustedCutoutEnd, circleResolution = circleResolution);

        // Remove the slots for multiconnect
        translate(v = [-(slotsWide * distanceBetweenSlots)/2,0,0]) {
            createMulticonnectSlots(backWidth = slotsWide * distanceBetweenSlots, backHeight = slotsHigh * distanceBetweenSlots, distanceBetweenSlots = distanceBetweenSlots, circleResolution = circleResolution);
        }
    }
}

module createCutout(holeDiameter=0, yCenterStart=0, yCenterEnd=0, circleResolution=100) {
    // Use extreme values to ensure that the cutout extends beyond the bounds of the object
    translate(v = [0, 0, -0.5 * beyondZ]) {
        createElongatedRoundObject(height = beyondZ, diameter = holeDiameter, yCenterStart = yCenterStart, yCenterEnd = yCenterEnd, circleResolution = circleResolution);
    }
}

module createElongatedRoundObject(height, diameter=0, xCenterStart=0, xCenterEnd=0, yCenterStart=0, yCenterEnd=0, circleResolution=100) {
    // There's no object to create if the diameter is 0 or less
    if (diameter > 0) {
        // Create an elongated round object (like a cylinder) that extends from start to end position
        hull() {
            // Starting position for the object
            translate(v = [xCenterStart, yCenterStart, 0]) {
                cylinder(h = height, d = diameter, $fn = circleResolution);
            }
            
            // Ending position for the object
            translate(v = [xCenterEnd, yCenterEnd, 0]) {
                cylinder(h = height, d = diameter, $fn = circleResolution);
            }
        }
    }
}

//BEGIN MODULES
//Slotted back Module
module createMulticonnectSlots(backWidth, backHeight, distanceBetweenSlots, circleResolution=100)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth, distanceBetweenSlots), backHeight = max(backHeight, distanceBetweenSlots), slotCount = floor(backWidth / distanceBetweenSlots), backThickness = 6.5){
        //Loop through slots and center on the item
        //Note: I kept doing math until it looked right. It's possible this can be simplified.
        for (slotNum = [0:1:slotCount-1]) {
            translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-13]) {
                slotTool(backHeight);
            }
        }
    }

    // Create Slot Tool
    module slotTool(totalHeight) {
        scale(v = slotTolerance)
        // Slot minus optional dimple with optional on-ramp
        let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
        difference() {
            union() {
                // Round top
                rotate(a = [90,0,0,]) {
                    rotate_extrude($fn = circleResolution) {
                        polygon(points = slotProfile);
                    }
                }

                // Long slot
                translate(v = [0,0,0]) 
                    rotate(a = [180,0,0])
                    union() {
                        difference() {
                            // Main half slot
                            linear_extrude(height = totalHeight+1) {
                                polygon(points = slotProfile);
                            }
                            
                            // Snap cutout
                            if (slotQuickRelease == false && multiConnectVersion == "v2") {
                                translate(v= [10.15,0,0]) {
                                    rotate(a= [-90,0,0]) {
                                        linear_extrude(height = 5) {  // match slot height (5mm)
                                            polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 specs
                                        }
                                    }
                                }
                            }
                        }

                        mirror([1,0,0]) {
                            difference() {
                                // Main half slot
                                linear_extrude(height = totalHeight+1) {
                                    polygon(points = slotProfile);
                                }
                                
                                // Snap cutout
                                if (slotQuickRelease == false && multiConnectVersion == "v2") {
                                    translate(v= [10.15,0,0]) {
                                        rotate(a= [-90,0,0]) {
                                            linear_extrude(height = 5) {  // match slot height (5mm)
                                                polygon(points = [[0,0],[-0.4,0],[0,-8]]);  // triangle polygon with multiconnect v2 spec
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                // On-ramp
                if(onRampEnabled)
                    for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots]) {
                        translate(v = [0,-5,-y*distanceBetweenSlots]) {
                            rotate(a = [-90,0,0]) {
                                cylinder(h = 5, r1 = 12, r2 = 10.15);
                            }
                        }
                    }
            }
            // Dimple
            if (slotQuickRelease == false && multiConnectVersion == "v1") {
                scale(v = dimpleScale) {
                    rotate(a = [90,0,0,]) {
                        rotate_extrude($fn = circleResolution) {
                            polygon(points = [[0,0],[0,1.5],[1.5,0]]);
                        }
                    }
                }
            }
        }
    }
}

module createMulticonnectBackShell(distanceBetweenSlots=25, slotsWide=1, slotsHigh=1, backThickness=6.5) {
    translate(v = [-(distanceBetweenSlots * slotsWide) / 2, -backThickness, 0]) {
        cube([distanceBetweenSlots * slotsWide, backThickness, distanceBetweenSlots * slotsHigh]);
    }
}
