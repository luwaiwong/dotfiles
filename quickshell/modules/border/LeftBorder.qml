
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
pragma ComponentBehavior: Bound
import "../../"
Scope{
    Variants {
            model: Quickshell.screens
            PanelWindow {
                id: root
                property var modelData
                screen: modelData
                anchors {
                    left: true
                }
                
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                mask: Region {
                    x: 0
                    y: 0
                    width: 10000
                    height: 10000
                    intersection: Intersection.Xor

                    regions: regions.instances
                }
                property real borderWidth: Style.borderWidth
                property real radius: Style.radius
                implicitHeight: modelData.height-2*(borderWidth+radius)
                implicitWidth: borderWidth+20
                color: "transparent"

                Rectangle { 
                    anchors.left: parent.left
                    width: root.borderWidth
                    implicitHeight: parent.height
                    color: "black"
                    z: 0
                    
                    layer.enabled: true // Essential to apply effects
                    layer.effect: DropShadow {
                        color: "#000000" // Shadow color (80 is 50% opacity black)
                        radius: 13      // Blur radius of the shadow
                        // verticalOffset: 3
                        samples: 17         // Quality of the blur (higher = smoother, slower)
                    }


                }


            }
        }
}
        