import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "widgets"
import "root:/utils" 

Scope{
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id : root

            property BarState barState: BarState {}
            property var modelData
            property real effectiveVerticalOffset: barState.showTopBar? 0: -  (barShape.implicitHeight - 6) 
            property bool isShown: false // Initially hidden
            screen: modelData

            // Dictates the area that mouse inputs don't affect the panel window
            // Otherwise, the whole area of the panel window would be unusable by other apps
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: 0
                y: detectionArea.height+effectiveVerticalOffset
                width: 10000
                height: 10000
                intersection: Intersection.Xor

                regions: regions.instances
            }
            
            anchors {
                top: true
            }
            implicitHeight: detectionArea.height+40
            implicitWidth: modelData.width/3

            // color: "white"
            color: "transparent"
            
            // Top border bar, covers bar content when hidden
            Rectangle{
                width: barShape.implicitWidth
                height: 5
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                // anchors.top
                // anchors.topMargin: -root.effectiveVerticalOffset+5

                color: "black"
                z: 101

            }
            // Main detection area
            MouseArea {
                id: detectionArea
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: barShape.width
                height: childrenRect.height+30
                
                hoverEnabled: true
                anchors.topMargin: root.effectiveVerticalOffset-10

                onEntered: root.barState.onMainTopBarHovered(true);
                onExited: root.barState.onMainTopBarHovered(false);
                z: 100
                propagateComposedEvents: true // Ensure events propagate to children
                
                layer.enabled: true // Essential to apply effects
                layer.effect: DropShadow {
                    color: "#65000000" // Shadow color (80 is 50% opacity black)
                    radius: 17    // Blur radius of the shadow
                    samples: 17         // Quality of the blur (higher = smoother, slower)
                }

                BarBackgroundShape {
                    id: barShape
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    anchors.topMargin: 15
                    topCurveOffset: Math.max(0, -root.effectiveVerticalOffset)

                    barWidth: barContent.implicitWidth
                    barHeight: 40
                    barColor: "black"
                    BarContent {
                        id: barContent
                        root: root
                        barState: root.barState
                    }
                }

                // Detecting when very top is hovered
                MouseArea {

                    width: 100
                    height: 5
                    anchors.topMargin: 10
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    hoverEnabled: true
                    propagateComposedEvents: true 
                    onEntered: root.barState.onTopMainTopBarHovered(true);
                    onExited: root.barState.onTopMainTopBarHovered(false);

                    z: 100000
                    Rectangle{
                        anchors.fill:parent
                        color: "white"
                    }
                }
                // Rectangle{
                //     anchors.fill:parent
                //     color: "white"
                // }

            }


            //  Animations
            Behavior on effectiveVerticalOffset {
                NumberAnimation {
                    duration: 200 
                    easing.type: Easing.OutCubic //
                }
            }
            
        }
    }
}