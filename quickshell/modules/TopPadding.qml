import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland

import QtQuick.Shapes 
pragma ComponentBehavior: Bound
import "../"

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }

            property real borderWidth: Style.borderWidth
            property real radius: Style.radius

            implicitHeight: 2
            color: "transparent"

        }
    }
}