
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Scope{
    Variants {
            model: Quickshell.screens
            PanelWindow {
                property var modelData
                screen: modelData
                anchors {
                    left: true
                }
                

                implicitHeight: modelData.height-20
                implicitWidth: 20
                color: "transparent"

                Rectangle { 
                    anchors.left: parent.left
                    width: 5
                    implicitHeight: parent.height
                    color: "black"
                    z: 0
                    
                    layer.enabled: true // Essential to apply effects
                    layer.effect: DropShadow {
                        color: "#000000" // Shadow color (80 is 50% opacity black)
                        radius: 10        // Blur radius of the shadow
                        // verticalOffset: 3
                        samples: 17         // Quality of the blur (higher = smoother, slower)
                    }


                }


            }
        }
}
        