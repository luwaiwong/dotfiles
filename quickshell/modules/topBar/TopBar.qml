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

Scope {
    id: scope

    // Signal to toggle launcher on focused screen
    signal toggleLauncher()

    // IPC handler for app launcher - call with: qs ipc call launcher toggle
    IpcHandler {
        target: "launcher"
        function toggle() {
            scope.toggleLauncher()
        }
    }

    Variants {
        id: barVariants
        model: Quickshell.screens

        PanelWindow {
            id: root

            property BarState state: BarState {}
            property var modelData
            property real effectiveVerticalOffset: state.showTopBar ? 0 : -(barShape.height - 5)
            property real extraPadding: 40
            // property real effectiveVerticalOffset: 0
            property bool isShown: false // Initially hidden
            screen: modelData

            // Listen for launcher toggle signal from IPC
            Connections {
                target: scope
                function onToggleLauncher() {
                    // Only toggle on the focused monitor
                    if (Hyprland.focusedMonitor === Hyprland.monitorFor(root.screen)) {
                        if (root.state.isLauncherOpen) {
                            root.state.closeLauncher()
                        } else {
                            root.state.openLauncher()
                        }
                    }
                }
            }

            // Dictates the area that mouse inputs don't affect the panel window
            // Otherwise, the whole area of the panel window would be unusable by other apps
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: root.state.isLauncherOpen ? WlrLayer.Overlay : WlrLayer.Top
            WlrLayershell.keyboardFocus: root.state.isLauncherOpen ? KeyboardFocus.Exclusive : KeyboardFocus.None
            mask: Region {
                x: root.state.isLauncherOpen ? 0 : root.modelData.width / 2 - detectionArea.width / 2
                y: root.state.isLauncherOpen ? 0 : root.effectiveVerticalOffset - root.extraPadding + 5
                width: root.state.isLauncherOpen ? root.modelData.width : detectionArea.width
                height: root.state.isLauncherOpen ? root.modelData.height : detectionArea.height
                intersection: Intersection.Union
            }

            anchors {
                top: true
            }
            height: root.state.isLauncherOpen ? modelData.height : detectionArea.height + 40
            width: modelData.width

            // color: "white"
            color: "transparent"

            // Fullscreen click-outside overlay (only when launcher is open)
            MouseArea {
                id: clickOutsideArea
                anchors.fill: parent
                visible: root.state.isLauncherOpen
                z: 50
                onClicked: root.state.closeLauncher()
            }

            // Top border bar, covers bar content when hidden
            Rectangle {
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
                height: barContent.height + Style.borderWidth * 2 + root.extraPadding

                hoverEnabled: true
                anchors.topMargin: root.effectiveVerticalOffset - root.extraPadding / 2

                onEntered: root.state.onMainTopBarHovered(true)
                onExited: root.state.onMainTopBarHovered(false)
                z: 100
                propagateComposedEvents: true // Ensure events propagate to children

                layer.enabled: true // Essential to apply effects
                layer.effect: DropShadow {
                    color: "#65000000" // Shadow color (80 is 50% opacity black)
                    radius: 17    // Blur radius of the shadow
                    samples: 17         // Quality of the blur (higher = smoother, slower)
                }

                Background {
                    id: barShape
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    topMargin: Style.borderWidth + root.extraPadding / 2
                    topCurveOffset: -root.effectiveVerticalOffset
                    margin: 10
                    barWidth: barContent.implicitWidth
                    barHeight: barContent.implicitHeight
                    barColor: "black"
                    // Rectangle{
                    //     id: barContent
                    //     implicitWidth: 100
                    //     implicitHeight:40
                    // }
                    Content {
                        id: barContent
                        root: root
                        state: root.state
                        anchors.bottomMargin: -10
                    }
                }

                // Detecting when very top is hovered
                MouseArea {

                    width: 50
                    height: 3
                    anchors.topMargin: root.extraPadding / 2
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onEntered: root.state.onWorkspaceAreaHovered(true)
                    onExited: root.state.onWorkspaceAreaHovered(false)

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
                    easing.type: root.state.showTopBar ? Easing.OutCubic : Easing.OutBack
                    // easing.type: Easing.OutCubic
                }
            }
        }
    }
}
