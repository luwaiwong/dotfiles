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

Item {
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    property int workspacesShown: 10
    
    readonly property int workspaceGroup: Math.floor((monitor.activeWorkspace?.id - 1) / workspacesShown)
    property list<bool> workspaceOccupied: []
    property int widgetPadding: 0
    property int workspaceButtonWidth: 24
    property real workspaceIconSize: workspaceButtonWidth * 0.69
    property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.55
    property real workspaceIconOpacityShrinked: 1
    property real workspaceIconMarginShrinked: -4
    property int workspaceIndexInGroup: (monitor.activeWorkspace?.id - 1) % workspacesShown

    property bool enabled: false
    // Function to update workspaceOccupied
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: workspacesShown }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * workspacesShown + i + 1);
        })
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

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
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
        onWheel: (event) => {
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
                radius: Appearance.rounding.full
                property var leftOccupied: (workspaceOccupied[index-1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index))
                property var rightOccupied: (workspaceOccupied[index+1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index+2))
                property var radiusLeft: leftOccupied ? 0 : 20
                property var radiusRight: rightOccupied ? 0 : 20

                topLeftRadius: radiusLeft
                bottomLeftRadius: radiusLeft
                topRightRadius: radiusRight
                bottomRightRadius: radiusRight
                
                // color: "#2e3440"
                color: "transparent"
                opacity: (workspaceOccupied[index] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index+1)) ? 1 : 0

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

    // Active workspace
    Rectangle {
        z: 2
        // Make active ws indicator, which has a brighter color, smaller to look like it is of the same size as ws occupied highlight
        property real activeWorkspaceMargin: 2
        implicitHeight: 25
        radius: 20
        color: "#81a1c1"
        // color: "transparent"
        // border.color: "#81a1c1" // Color of the border
        // border.width: 1         // Width of the border in pixels
        
        anchors.verticalCenter : parent.verticalCenter
        anchors.verticalCenterOffset: 0.5
        

        property real idx1: workspaceIndexInGroup
        property real idx2: workspaceIndexInGroup
        x: Math.min(idx1, idx2) * workspaceButtonWidth  -0.1 
        implicitWidth: Math.abs(idx1 - idx2) * workspaceButtonWidth + workspaceButtonWidth 

        Behavior on activeWorkspaceMargin {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on idx1 { // Leading anim
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutSine
            }
        }
        Behavior on idx2 { // Following anim
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutSine
            }
        }
    }

    // Workspaces - numbers
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
                onHoveredChanged: {
                    if (hovered) {
                        workspaceButtonIndicator.width = 14
                        workspaceButtonIndicator.height = 14
                    } else {
                        workspaceButtonIndicator.width = 10
                        workspaceButtonIndicator.height = 10
                    }
                }
                width: workspaceButtonWidth
                background: Item {
                    id: workspaceButtonBackground
                    implicitWidth: workspaceButtonWidth
                    implicitHeight: workspaceButtonWidth
                    property var biggestWindow: {
                        const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == button.workspaceValue)
                        return windowsInThisWorkspace.reduce((maxWin, win) => {
                            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0)
                            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0)
                            return winArea > maxArea ? win : maxWin
                        }, null)
                    }
                    property var mainAppIconPath: AppSearch.guessIcon(biggestWindow?.class)
                    property var mainAppIconSource: Quickshell.iconPath(mainAppIconPath, "image-missing")

                    Rectangle {
                        id: workspaceButtonIndicator
                        anchors.centerIn: parent
                        width: workspaceOccupied[index] ? workspaceIconSize-1: 10
                        height: workspaceOccupied[index] ? workspaceIconSize-1: 10
                        radius: 20
                        color: workspaceOccupied[index] ? "white": "#4c566a"
                        
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
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: (true) ? 
                                (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked
                            anchors.rightMargin: (true) ? 
                                (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked

                            opacity: workspaceButtonBackground.mainAppIconPath == "image-missing" ? 0 : 1
                            // visible: workspaceButtonBackground.mainAppIconSource == "image-missing" ? 0 : 1
                            source: workspaceButtonBackground.mainAppIconSource
                            implicitSize: workspaceIconSize

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
                        }
                    }
                }
                

            }

        }

    }

}
