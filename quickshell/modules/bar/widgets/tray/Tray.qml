pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Rectangle {
    id: root

    clip: true
    visible: width > 0 && height > 0

    implicitWidth: 100
    implicitHeight: 25
    color: "#2e3440"
    radius: 20

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: 10

        // Sort for only nm-applet
        Repeater {
            model: SystemTray.items

            TrayItem {
                width: modelData.id == "nm-applet" ? 16: 0
            }
        }   
        Power {}

        // Show rest of tray
        Repeater {
            model: SystemTray.items

            TrayItem {
                width: modelData.id != "nm-applet" ? 16: 0
            }
        }

    }

    Component.onCompleted: {
        sortTrayItems()
    }
}