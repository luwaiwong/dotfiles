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

    // Special workspaces
    property var specialWorkspaces: HyprlandData.specialWorkspaces
    property int specialWorkspaceCount: specialWorkspaces.length
    property string activeSpecialWorkspace: HyprlandData.activeSpecialWorkspace
    property real specialWorkspaceSpacing: 4  // Padding between special workspaces
    property real specialWorkspaceSectionWidth: specialWorkspaceCount > 0 ? specialWorkspaceCount * workspaceButtonWidth + (specialWorkspaceCount - 1) * specialWorkspaceSpacing + workspaceGroupSpacing : 0

    // Size configuration
    property int widgetPadding: 0
    property int workspaceButtonWidth: 22
    property real workspaceIconSize: workspaceButtonWidth * 0.65
    property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.30
    property real workspaceIconOpacityShrinked: 1
    property real workspaceIconMarginShrinked: -4
    property real workspaceBackgroundRadius: 20
    property real workspaceIndicatorSize: 10
    property real workspaceIndicatorSizeHover: 12
    property real workspaceIndicatorSizeOccupied: workspaceIndicatorSize
    property real workspaceIconSizeHover: 22
    property real workspaceIconSizeDefault: 14
    property real workspaceGroupSpacing: 8  // Spacing between workspace groups
    property var workspaceGroupBoundaries: [3, 6, 9]  // Indexes where separators appear (before these workspaces)

    property int workspaceIndexInGroup: (monitor.activeWorkspace?.id - (11 - workspacesShown)) % workspacesShown

    // Count how many boundaries are before a given index
    function boundariesBefore(idx) {
        return workspaceGroupBoundaries.filter(b => b <= idx).length;
    }

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
    implicitWidth: specialWorkspaceSectionWidth + workspacesShown * workspaceButtonWidth + workspaceGroupBoundaries.length * workspaceGroupSpacing
    opacity: enabled ? 1 : 0

    implicitHeight: 40
    Layout.topMargin: -1.5  // Move up by 1.5 pixels

    // Background
    Rectangle {
        z: 0
        anchors.centerIn: parent
        implicitHeight: 32
        implicitWidth: specialWorkspaceSectionWidth + workspacesShown * workspaceButtonWidth + workspaceGroupBoundaries.length * workspaceGroupSpacing
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

    // Helper to get x position for a regular workspace index (accounting for group spacing and special workspace offset)
    function wsX(idx) {
        return specialWorkspaceSectionWidth + idx * workspaceButtonWidth + boundariesBefore(idx) * workspaceGroupSpacing;
    }

    // Helper to get x position for a special workspace index (with spacing between them)
    function specialWsX(idx) {
        return idx * (workspaceButtonWidth + specialWorkspaceSpacing);
    }

    ///// Special Workspaces - backgrounds (individual, not connected) /////
    Item {
        id: specialRowLayout
        z: 1
        anchors.fill: parent
        visible: specialWorkspaceCount > 0

        Repeater {
            model: specialWorkspaces

            Rectangle {
                z: 1
                x: specialWsX(index)
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceButtonWidth
                height: workspaceButtonWidth
                radius: workspaceBackgroundRadius
                color: "#2e3440"
                opacity: 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 30
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    // Special workspace active indicator
    Rectangle {
        z: 2
        implicitHeight: workspaceButtonWidth
        implicitWidth: workspaceButtonWidth
        radius: workspaceBackgroundRadius
        color: "#81a1c1"
        anchors.verticalCenter: parent.verticalCenter

        property int activeSpecialIndex: {
            for (let i = 0; i < specialWorkspaces.length; i++) {
                if (specialWorkspaces[i].name === "special:" + activeSpecialWorkspace) {
                    return i;
                }
            }
            return -1;
        }

        // Track the last valid position to avoid animating from 0
        property int lastValidIndex: 0
        onActiveSpecialIndexChanged: {
            if (activeSpecialIndex >= 0) {
                lastValidIndex = activeSpecialIndex;
            }
        }

        // Use lastValidIndex for position so we don't animate from x=0
        x: specialWsX(activeSpecialIndex >= 0 ? activeSpecialIndex : lastValidIndex)
        opacity: activeSpecialIndex >= 0 ? 1 : 0

        // Only animate x when actively switching between special workspaces
        Behavior on x {
            enabled: activeSpecialIndex >= 0
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }

    // Special workspaces icons
    Item {
        id: specialRowLayoutIcons
        z: 3
        anchors.fill: parent
        visible: specialWorkspaceCount > 0

        Repeater {
            model: specialWorkspaces

            Button {
                id: specialButton
                property string workspaceName: modelData.name
                property string shortName: workspaceName.replace("special:", "")
                x: specialWsX(index) + 0.5
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceButtonWidth
                height: workspaceButtonWidth
                onPressed: Hyprland.dispatch(`togglespecialworkspace ${shortName}`)
                hoverEnabled: true
                onHoveredChanged: {
                    if (hovered) {
                        specialIndicator.width = workspaceIndicatorSizeHover;
                        specialIndicator.height = workspaceIndicatorSizeHover;
                        specialAppIcon.width = workspaceIconSizeHover;
                        specialAppIcon.height = workspaceIconSizeHover;
                    } else {
                        specialIndicator.width = workspaceIndicatorSize;
                        specialIndicator.height = workspaceIndicatorSize;
                        specialAppIcon.width = workspaceIconSizeDefault;
                        specialAppIcon.height = workspaceIconSizeDefault;
                    }
                }
                background: Item {
                    id: specialButtonBackground
                    implicitWidth: workspaceButtonWidth
                    implicitHeight: workspaceButtonWidth
                    property var biggestWindow: {
                        const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.name === specialButton.workspaceName);
                        return windowsInThisWorkspace.reduce((maxWin, win) => {
                            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0);
                            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
                            return winArea > maxArea ? win : maxWin;
                        }, null);
                    }
                    property var mainAppIconPath: AppSearch.guessIcon(biggestWindow?.class)
                    property var mainAppIconSource: Quickshell.iconPath(mainAppIconPath, "image-missing")

                    Rectangle {
                        id: specialIndicator
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 0
                        anchors.horizontalCenterOffset: 0.1
                        width: workspaceIndicatorSize
                        height: workspaceIndicatorSize
                        radius: workspaceBackgroundRadius
                        color: "#d8dee9"

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on height {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Item {
                        anchors.centerIn: parent
                        width: workspaceButtonWidth
                        height: workspaceButtonWidth
                        IconImage {
                            id: specialAppIcon
                            anchors.centerIn: parent
                            opacity: specialButtonBackground.mainAppIconPath == "image-missing" ? 0 : 1
                            visible: specialButtonBackground.mainAppIconSource == "image-missing" ? 0 : 1
                            source: specialButtonBackground.mainAppIconSource
                            implicitSize: workspaceIconSize

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on width {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Separator between special and regular workspaces
    Rectangle {
        z: 4
        visible: specialWorkspaceCount > 0
        x: specialWorkspaceSectionWidth - workspaceGroupSpacing / 2 - 0.5
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 16
        color: "#4c566a"
        opacity: 0.6
    }

    ///// Workspaces - background /////
    Item {
        id: rowLayout
        z: 1
        anchors.fill: parent

        Repeater {
            model: workspacesShown

            Rectangle {
                z: 1
                x: wsX(index)
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceButtonWidth
                height: workspaceButtonWidth
                // Don't connect backgrounds across group boundaries
                property bool atGroupStart: workspaceGroupBoundaries.includes(index)
                property bool atGroupEnd: workspaceGroupBoundaries.includes(index + 1)
                property var leftOccupied: !atGroupStart && (workspaceOccupied[index - 1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index))
                property var rightOccupied: !atGroupEnd && (workspaceOccupied[index + 1] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index + 2))
                property var radiusLeft: leftOccupied ? 0 : workspaceBackgroundRadius
                property var radiusRight: rightOccupied ? 0 : workspaceBackgroundRadius

                topLeftRadius: radiusLeft
                bottomLeftRadius: radiusLeft
                topRightRadius: radiusRight
                bottomRightRadius: radiusRight

                color: "#2e3440"
                opacity: (workspaceOccupied[index] && !(!activeWindow?.activated && monitor.activeWorkspace?.id === index + 1)) ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 30
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on radiusLeft {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on radiusRight {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    //////////

    // Active workspace indicator (for regular workspaces)
    // Sliding circle behind active icon
    Rectangle {
        z: 2
        implicitHeight: workspaceButtonWidth
        radius: workspaceBackgroundRadius
        // Dimmed when a special workspace is active, full opacity otherwise
        color: activeSpecialWorkspace === "" ? "#81a1c1" : "#4c566a"

        anchors.verticalCenter: parent.verticalCenter

        // Target position based on current workspace
        property real targetX: wsX(workspaceIndexInGroup)

        // Two x positions that animate at different speeds for stretching effect
        property real x1: targetX
        property real x2: targetX

        x: Math.min(x1, x2)

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
        implicitWidth: Math.abs(x1 - x2) + workspaceButtonWidth

        Behavior on x1 {
            // Leading anim (faster)
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutSine
            }
        }
        Behavior on x2 {
            // Following anim (slower, creates stretch)
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutSine
            }
        }
    }

    // Group separator lines
    Item {
        z: 4
        anchors.fill: parent

        Repeater {
            model: workspaceGroupBoundaries

            Rectangle {
                x: wsX(modelData) - workspaceGroupSpacing / 2 - 0.5
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 16
                color: "#4c566a"
                opacity: 0.6
            }
        }
    }

    // Workspaces icons and white color
    Item {
        id: rowLayoutNumbers
        z: 3
        anchors.fill: parent

        Repeater {
            model: workspacesShown

            Button {
                id: button
                property int workspaceValue: workspaceGroup * workspacesShown + index + 1
                x: wsX(index) + 0.5
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceButtonWidth
                height: workspaceButtonWidth
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

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on height {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Item {
                        anchors.centerIn: parent
                        width: workspaceButtonWidth
                        height: workspaceButtonWidth
                        IconImage {
                            id: mainAppIcon
                            anchors.centerIn: parent
                            opacity: workspaceButtonBackground.mainAppIconPath == "image-missing" ? 0 : 1
                            visible: workspaceButtonBackground.mainAppIconSource == "image-missing" ? 0 : 1
                            source: workspaceButtonBackground.mainAppIconSource
                            implicitSize: workspaceIconSize

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on implicitSize {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on width {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
