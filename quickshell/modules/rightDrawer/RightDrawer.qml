import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/utils"
import "root:/"

// import "root:/modules/rightDrawer/State.qml"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            property RightDrawerState state: RightDrawerState {}
            property var modelData
            property real effectiveHorizontalOffset: state.show ? 0 : -(background.width) + (state.hovering ? 5 : 0)
            // property real effectiveHorizontalOffset: 20
            property bool isShown: false // Initially hidden
            screen: modelData

            // Dictates the area that mouse inputs don't affect the panel window
            // Otherwise, the whole area of the panel window would be unusable by other apps
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: root.implicitWidth - root.effectiveHorizontalOffset - 85
                y: detectionArea.y
                width: 100000
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
                right: true
            }
            implicitHeight: modelData.height
            implicitWidth: detectionArea.width + 100

            // color: "white"
            color: "transparent"

            // Top border bar, covers bar content when hidden
            // Rectangle{
            //     width: barShape.implicitWidth
            //     height: Style.borderWidth
            //     anchors.top: parent.top
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     // anchors.top
            //     // anchors.topMargin: -root.effectiveVerticalOffset+5

            //     color: "black"
            //     z: 101

            // }
            // Main detection area
            MouseArea {
                id: detectionArea
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: background.height + 40
                width: childrenRect.width + Style.borderWidth * 2 + 40

                hoverEnabled: true
                anchors.rightMargin: root.effectiveHorizontalOffset - 20
                // anchors.rightMargin: 20

                onEntered: root.state.onMainTopBarHovered(true)
                onExited: root.state.onMainTopBarHovered(false)
                z: 100
                propagateComposedEvents: true // Ensure events propagate to children
                // clip: true

                layer.enabled: true // Essential to apply effects
                layer.effect: DropShadow {
                    color: "#65000000" // Shadow color (80 is 50% opacity black)
                    radius: 17    // Blur radius of the shadow
                    samples: 17         // Quality of the blur (higher = smoother, slower)
                }

                Background {
                    id: background
                    anchors.right: detectionArea.right
                    anchors.verticalCenter: parent.verticalCenter
                    // anchors.rightMargin: Style.borderWidth
                    rightMargin: Style.borderWidth + 20

                    barHeight: content.height + 5
                    barWidth: content.implicitWidth
                    barColor: "black"

                    margin: 30
                    // rightCurveOffset: 0
                    rightCurveOffset: -root.effectiveHorizontalOffset
                    Content {
                        id: content
                        root: root
                        state: root.state
                        anchors.leftMargin: 30
                    }
                }

                // Rectangle{
                //     anchors.fill:parent
                //     color: "white"
                // }

            }

            //  Animations
            Behavior on effectiveHorizontalOffset {
                NumberAnimation {
                    duration: 300
                    easing.type: root.state.show ? Easing.OutCubic : Easing.OutBack
                    // easing.type: Easing.OutBack
                }
            }
        }
    }
}
