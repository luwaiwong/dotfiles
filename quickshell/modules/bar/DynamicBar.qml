import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "widgets"
import "root:/utils" 
import "root:/"

Scope{
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id : root

            property BarState barState: BarState {}
            property var modelData
            property real effectiveVerticalOffset: barState.showTopBar? 0: -  (barShape.height - 5) 
            property real extraPadding: 40
            // property real effectiveVerticalOffset: 0
            property bool isShown: false // Initially hidden
            screen: modelData

            // Dictates the area that mouse inputs don't affect the panel window
            // Otherwise, the whole area of the panel window would be unusable by other apps
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: root.modelData.width/2 - detectionArea.width/2
                y: root.effectiveVerticalOffset- root.extraPadding+5
                width: detectionArea.width
                height: detectionArea.height
                intersection: Intersection.Union
            }
            
            anchors {
                top: true
            }
            height: detectionArea.height+40
            width: modelData.width

            // color: "white"
            color: "transparent"
            
            // Top border bar, covers bar content when hidden
            Rectangle{
                width: barShape.width
                height: Style.borderWidth
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
                height: barContent.height+Style.borderWidth*2+root.extraPadding
                
                hoverEnabled: true
                anchors.topMargin: root.effectiveVerticalOffset-root.extraPadding/2

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

                RoundedBackground {
                    id: barShape
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    topMargin: Style.borderWidth+root.extraPadding/2
                    topCurveOffset: -root.effectiveVerticalOffset
                    margin: 10
                    barWidth: barContent.implicitWidth
                    barHeight: 40
                    barColor: "black"
                    // Rectangle{
                    //     id: barContent
                    //     implicitWidth: 100
                    //     implicitHeight:40
                    // }
                    BarContent {
                        id: barContent
                        root: root
                        barState: root.barState
                        anchors.bottomMargin: -10
                    }
                }

                // Detecting when very top is hovered
                MouseArea {

                    width: 50
                    height: 3
                    anchors.topMargin: root.extraPadding/2
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    hoverEnabled: true
                    propagateComposedEvents: true 
                    onEntered: root.barState.onWorkspaceAreaHovered(true);
                    onExited: root.barState.onWorkspaceAreaHovered(false);

                    z: 100000
                    // Rectangle{
                    //     anchors.fill:parent
                    //     color: "white"
                    // }
                }
                // Rectangle{
                //     anchors.fill:parent
                //     color: "white"
                // }

            }


            //  Animations
            Behavior on effectiveVerticalOffset {
                NumberAnimation {
                  duration: 350
                    easing.type: root.barState.showTopBar?   Easing.OutCubic : Easing.OutBack
                    // easing.type: Easing.OutCubic
                }
            }
            
        }
    }
}
