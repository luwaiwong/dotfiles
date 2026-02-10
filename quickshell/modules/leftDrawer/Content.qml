import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "widgets" // Assuming AudioBar.qml and BrightnessBar.qml are in this directory
import Quickshell.Hyprland // Required to get the focused monitor from Hyprland

Rectangle {
    id: barContent
    required property var root
    required property LeftDrawerState state

    // anchors.centerIn: parent
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    // anchors.topMargin: -20
    clip: true
    color: "transparent"

    implicitWidth: main.width
    implicitHeight: main.height

    WallpaperPicker {
        id: main
        anchors.centerIn: parent
        z: 100
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
