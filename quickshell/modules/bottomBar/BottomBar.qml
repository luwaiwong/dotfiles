import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/utils"
import "root:/"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            property BottomBarState state: BottomBarState {}
            property var modelData
            property real effectiveVerticalOffset: state.show ? 0 : -(detectionArea.height)
            property bool isShown: false // Initially hidden
            screen: modelData

            property real extraPadding: 20

            // Dictates the area that mouse inputs don't affect the panel window
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: detectionArea.x
                y: root.implicitHeight - root.effectiveVerticalOffset - detectionArea.height
                width: detectionArea.width
                height: 10000
                intersection: Intersection.Union
            }

            anchors {
                bottom: true
            }
            implicitWidth: modelData.width
            implicitHeight: detectionArea.height + 50

            color: "transparent"

            // Main detection area
            MouseArea {
                id: detectionArea
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: background.width + 20
                height: content.height + Style.borderWidth * 2 + 20

                hoverEnabled: true
                anchors.bottomMargin: root.effectiveVerticalOffset

                onEntered: root.state.onMainBottomBarHovered(true)
                onExited: root.state.onMainBottomBarHovered(false)
                z: 100
                propagateComposedEvents: true

                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#65000000"
                    radius: 17
                    samples: 17
                }

                Background {
                    id: background
                    anchors.bottom: detectionArea.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    bottomMargin: Style.borderWidth + 10

                    barHeight: content.height + 5
                    barWidth: content.implicitWidth
                    barColor: "black"
                    margin: 15
                    bottomCurveOffset: -root.effectiveVerticalOffset

                    Content {
                        id: content
                        root: root
                        state: root.state
                        anchors.topMargin: 15
                    }
                }
            }

            // Animations
            Behavior on effectiveVerticalOffset {
                NumberAnimation {
                    duration: 300
                    easing.type: root.state.show ? Easing.OutCubic : Easing.OutBack
                }
            }
        }
    }
}
