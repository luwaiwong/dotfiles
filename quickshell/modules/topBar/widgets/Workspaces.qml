import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "root:/utils/"

MouseArea {
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    property int workspacesShown: 10

    readonly property int workspaceGroup: Math.floor((monitor.activeWorkspace?.id - 1) / workspacesShown)
    property list<bool> workspaceOccupied: []

    // Size configuration
    property int widgetPadding: 0
    property int workspaceButtonWidth: 22
    property real workspaceIconSize: workspaceButtonWidth * 0.69
    property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.30
    property real workspaceIconOpacityShrinked: 1
    property real workspaceIconMarginShrinked: -4
    property real workspaceBackgroundRadius: 20
    property real workspaceIndicatorSize: 10
    property real workspaceIndicatorSizeHover: 12
    property real workspaceIndicatorSizeOccupied: workspaceIndicatorSize
    property real workspaceIconSizeHover: 22
    property real workspaceIconSizeDefault: 14

    property int workspaceIndexInGroup: (monitor.activeWorkspace?.id - 1) % workspacesShown

    property bool enabled: false
    cursorShape: Qt.PointingHandCursor
    // Function to update workspaceOccupied
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({
            length: workspacesShown
        }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * workspacesShown + i + 1);
        });
    }

    // Initialize workspaceOccupied when the component is created
    Component.onCompleted: updateWorkspaceOccupied()

    // Listen for changes in Hyprland.workspaces.values
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateWorkspaceOccupied();
        }
    }

    Layout.fillHeight: true
    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    opacity: enabled ? 1 : 0

    implicitHeight: 40
    Layout.topMargin: -1.5  // Move up by 1.5 pixels

    // Background
    Rectangle {
        z: 0
        anchors.centerIn: parent
        implicitHeight: 32
        implicitWidth: rowLayout.implicitWidth
        radius: 10
        color: "transparent"
    }

    // Scroll to switch workspaces
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`workspace r+1`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`workspace r-1`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    ///// Workspaces - background /////
    RowLayout {
        id: rowLayout
        z: 1

        spacing: 0
        anchors.fill: parent
        implicitHeight: 40

        Repeater {
            model: workspacesShown

            Rectangle {
                z: 1
                implicitWidth: workspaceButtonWidth
                implicitHeight: workspaceButtonWidth
                // radius: Appearance.rounding.full
                property var leftOccupied: (workspaceOccupied[index - 1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index))
                property var rightOccupied: (workspaceOccupied[index + 1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index + 2))
                property var radiusLeft: leftOccupied ? 0 : workspaceBackgroundRadius
                property var radiusRight: rightOccupied ? 0 : workspaceBackgroundRadius

                topLeftRadius: radiusLeft
                bottomLeftRadius: radiusLeft
                topRightRadius: radiusRight
                bottomRightRadius: radiusRight

                color: "#2e3440"
                // color: "transparent"
                opacity: (workspaceOccupied[index] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index + 1)) ? 1 : 0

                // anchors.topMargin: 2

                Behavior on opacity {
                    NumberAnimation {
                        // Use a single, consistent duration for the entire show/hide animation
                        duration: 30 // Adjust this for your desired speed
                        easing.type: Easing.OutCubic // A smoother easing curve for movement
                    }
                }
                Behavior on radiusLeft {
                    NumberAnimation {
                        // Use a single, consistent duration for the entire show/hide animation
                        duration: 50 // Adjust this for your desired speed
                        easing.type: Easing.OutCubic // A smoother easing curve for movement
                    }
                }

                Behavior on radiusRight {
                    NumberAnimation {
                        // Use a single, consistent duration for the entire show/hide animation
                        duration: 50 // Adjust this for your desired speed
                        easing.type: Easing.OutCubic // A smoother easing curve for movement
                    }
                }
            }
        }
    }
    //////////

    // Active workspace indicator
    // Sliding circle behind active icon
    Rectangle {
        z: 2
        // Make active ws indicator, which has a brighter color, smaller to look like it is of the same size as ws occupied highlight
        property real activeWorkspaceMargin: 2
        implicitHeight: workspaceButtonWidth
        radius: workspaceBackgroundRadius
        color: "#81a1c1"
        // color: "transparent"
        // border.color: "#81a1c1" // Color of the border
        // border.width: 1         // Width of the border in pixels

        anchors.verticalCenter: parent.verticalCenter

        property real idx1: workspaceIndexInGroup
        property real idx2: workspaceIndexInGroup
        x: Math.min(idx1, idx2) * workspaceButtonWidth - 0.1
        implicitWidth: Math.abs(idx1 - idx2) * workspaceButtonWidth + workspaceButtonWidth

        Behavior on activeWorkspaceMargin {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on idx1 {
            // Leading anim
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutSine
            }
        }
        Behavior on idx2 {
            // Following anim
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutSine
            }
        }
    }

    // Workspaces icons and white color
    RowLayout {
        id: rowLayoutNumbers
        z: 3

        spacing: 0
        anchors.fill: parent
        implicitHeight: 40

        Repeater {
            model: workspacesShown

            Button {
                id: button
                property int workspaceValue: workspaceGroup * workspacesShown + index + 1
                Layout.fillHeight: true
                onPressed: Hyprland.dispatch(`workspace ${workspaceValue}`)
                hoverEnabled: true
                onHoveredChanged: {
                    if (hovered) {
                        workspaceButtonIndicator.width = workspaceIndicatorSizeHover;
                        workspaceButtonIndicator.height = workspaceIndicatorSizeHover;
                        mainAppIcon.width = workspaceIconSizeHover;
                        mainAppIcon.height = workspaceIconSizeHover;
                    } else {
                        workspaceButtonIndicator.width = workspaceIndicatorSize;
                        workspaceButtonIndicator.height = workspaceIndicatorSize;
                        mainAppIcon.width = workspaceIconSizeDefault;
                        mainAppIcon.height = workspaceIconSizeDefault;
                    }
                }
                width: workspaceButtonWidth
                background: Item {
                    id: workspaceButtonBackground
                    implicitWidth: workspaceButtonWidth
                    implicitHeight: workspaceButtonWidth
                    property var biggestWindow: {
                        const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == button.workspaceValue);
                        return windowsInThisWorkspace.reduce((maxWin, win) => {
                            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0);
                            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
                            return winArea > maxArea ? win : maxWin;
                        }, null);
                    }
                    property var mainAppIconPath: AppSearch.guessIcon(biggestWindow?.class)
                    property var mainAppIconSource: Quickshell.iconPath(mainAppIconPath, "image-missing")

                    Rectangle {
                        id: workspaceButtonIndicator
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 0
                        anchors.horizontalCenterOffset: 0.1
                        width: workspaceOccupied[index] ? workspaceIndicatorSizeOccupied : workspaceIndicatorSize
                        height: workspaceOccupied[index] ? workspaceIndicatorSizeOccupied : workspaceIndicatorSize
                        radius: workspaceBackgroundRadius
                        color: workspaceOccupied[index] ? "#d8dee9" : "#4c566a"
                        // visible:

                        Behavior on width {
                            NumberAnimation {
                                // Use a single, consistent duration for the entire show/hide animation
                                duration: 200 // Adjust this for your desired speed
                                easing.type: Easing.OutCubic // A smoother easing curve for movement
                            }
                        }
                        Behavior on height {
                            NumberAnimation {
                                // Use a single, consistent duration for the entire show/hide animation
                                duration: 200 // Adjust this for your desired speed
                                easing.type: Easing.OutCubic // A smoother easing curve for movement
                            }
                        }
                    }
                    // Text {
                    //     opacity: 1
                    //     z: 3

                    //     anchors.centerIn: parent
                    //     horizontalAlignment: Text.AlignHCenter
                    //     verticalAlignment: Text.AlignVCenter
                    //     font.pixelSize: Appearance.font.pixelSize.small - ((text.length - 1) * (text !== "10") * 2)
                    //     text: `${button.workspaceValue}`
                    //     elide: Text.ElideRight
                    //     color: (monitor.activeWorkspace?.id == button.workspaceValue) ?
                    //         "white" :
                    //         (workspaceOccupied[index] ? "white" :
                    //             "white")

                    //     Behavior on opacity {
                    //         animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    //     }

                    // }
                    Item {
                        anchors.centerIn: parent
                        width: workspaceButtonWidth
                        height: workspaceButtonWidth
                        IconImage {
                            id: mainAppIcon
                            anchors.centerIn: parent
                            // anchors.bottom: parent.bottom
                            // anchors.right: parent.right
                            // anchors.bottomMargin: (true) ?
                            //     (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked
                            // anchors.rightMargin: (true) ?
                            //     (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked

                            opacity: workspaceButtonBackground.mainAppIconPath == "image-missing" ? 0 : 1
                            visible: workspaceButtonBackground.mainAppIconSource == "image-missing" ? 0 : 1
                            source: workspaceButtonBackground.mainAppIconSource
                            implicitSize: workspaceIconSize
                            // color: workspaceButtonBackground.mainAppIconPath == "image-missing" ? "#d8dee9" : "#4c566a"

                            Behavior on opacity {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }
                            Behavior on anchors.bottomMargin {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }
                            Behavior on anchors.rightMargin {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }
                            Behavior on implicitSize {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }

                            Behavior on width {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    // Use a single, consistent duration for the entire show/hide animation
                                    duration: 200 // Adjust this for your desired speed
                                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
