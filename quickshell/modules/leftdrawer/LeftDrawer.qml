import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/utils" 
import "root:/"

Scope{
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id : root

            property LeftDrawerState state: LeftDrawerState {}
            property var modelData
            property real effectiveHorizontalOffset: state.showTopBar? 0 : -(background.width)+ (state.hoveringTopBar? 5: 0)
            // property real effectiveHorizontalOffset: 20
            property bool isShown: false // Initially hidden
            screen: modelData

            property real extraPadding: 40
            // Dictates the area that mouse inputs don't affect the panel window
            // Otherwise, the whole area of the panel window would be unusable by other apps
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: 0
                y: detectionArea.y
                width: root.effectiveHorizontalOffset+detectionArea.width-root.extraPadding
                height: detectionArea.height
                intersection: Intersection.Union

                // regions: [
                //     Region {
                //         x: root.modelData.width/2 - detectionArea.width/2
                //         y: effectiveVerticalOffset
                //         width: detectionArea.width
                //         height: detectionArea.height
                //         intersection: Intersection.Xor
                //     }
                // ]
            }
            
            anchors {
                left: true
            }
            implicitHeight: modelData.height
            implicitWidth: detectionArea.width

            // color: "white"
            color: "transparent"
            
            // Top border bar, covers bar content when hidden
            // Rectangle{
            //     width: barShape.implicitWidth
            //     height: Style.borderWidth
            //     anchors.top: parent.top
            //     anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top
            // anchors.topMargin: -root.effectiveVerticalOffset+5
            //     color: "black"
            //     z: 101

            // }
            // Main detection area
            MouseArea {
                id: detectionArea
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: background.height+40
                width: content.width+Style.borderWidth+42
                
                hoverEnabled: true
                anchors.leftMargin: root.effectiveHorizontalOffset-root.extraPadding
                // anchors.rightMargin: 20

                onEntered: root.state.onMainTopBarHovered(true);
                onExited: root.state.onMainTopBarHovered(false);
                z: 100
                propagateComposedEvents: true // Ensure events propagate to children
                // clip: true
                
                layer.enabled: true // Essential to apply effects
                layer.effect: DropShadow {
                    color: "#65000000" // Shadow color (80 is 50% opacity black)
                    radius: 17    // Blur radius of the shadow
                    samples: 17         // Quality of the blur (higher = smoother, slower)
                }

                // Rectangle{
                //     anchors.fill:parent
                //     color: "white"
                // }
                Background {
                    id: background
                    anchors.left: detectionArea.left
                    anchors.verticalCenter: parent.verticalCenter
                    // anchors.leftMargin: Style.borderWidth
                    leftMargin: Style.borderWidth+40

                    barHeight: content.height
                    barWidth: content.implicitWidth
                    barColor: "black"
                    margin: 20
                    // rightCurveOffset: 0
                    curveOffset: -root.effectiveHorizontalOffset
                    Content {
                        id: content
                        root: root
                        state: root.state
                        anchors.rightMargin: -root.extraPadding/2
                    }
                }

                // Detecting when very top is hovered
                // MouseArea {

                //     width: 160
                //     height: Style.borderWidth
                //     anchors.topMargin: 0
                //     anchors.top: parent.top
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     hoverEnabled: true
                //     propagateComposedEvents: true 
                //     onEntered: root.barState.onTopMainTopBarHovered(true);
                //     onExited: root.barState.onTopMainTopBarHovered(false);

                //     z: 100000
                //     // Rectangle{
                //     //     anchors.fill:parent
                //     //     color: "white"
                //     // }
                // // }
                // Rectangle{
                //     anchors.fill:parent
                //     color: "white"
                // }

            }

            //  Animations
            Behavior on effectiveHorizontalOffset {
                NumberAnimation {
                    duration: 400
                    easing.type: root.state.showTopBar?   Easing.InBack : Easing.OutBack
                }
            }
            
        }
    }
}