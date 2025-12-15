import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "widgets"
import "widgets/tray"

Rectangle {
    id: content
    required property var root
    required property BarState state

    // anchors.centerIn: parent
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    // anchors.bottomMargin: -10
    clip: true
    color: "transparent"

    implicitWidth: (content.state.isClockVisible ? main.implicitWidth : workspace.implicitWidth) + 20
    implicitHeight: 40

    Workspaces {
        id: workspace
        bar: content.root
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: false  // Don't fill width to keep centered

        anchors.centerIn: parent
        enabled: !content.state.isClockVisible

        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: content.state.onWorkspaceHovered(true)
        onExited: content.state.onWorkspaceHovered(false)

        z: content.state.isClockVisible ? 0 : 100

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        id: main
        anchors.centerIn: parent

        // width: enabled ? contentText.implicitWidth : 0
        opacity: content.state.isClockVisible ? 1 : 0
        z: content.state.isClockVisible ? 100 : 0

        Tray {
            Layout.alignment: Qt.AlignRight
            z: 100
        }
        MediaAndDate {
            Layout.alignment: Qt.AlignCenter
            // z: content.barState.isClockVisible: 100
        }

        Clock {
            Layout.alignment: Qt.AlignCenter
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
