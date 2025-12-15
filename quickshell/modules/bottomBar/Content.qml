import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

import "widgets"
import Quickshell.Hyprland

Rectangle {
    id: barContent
    required property var root
    required property BottomBarState state

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    clip: true
    color: "transparent"

    implicitWidth: main.implicitWidth + 15
    implicitHeight: main.implicitHeight + 20

    RowLayout {
        id: main
        anchors.centerIn: parent
        z: 100

        BatteryBar {}

        Behavior on opacity {
            NumberAnimation {
                duration: 100
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
