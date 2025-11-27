// PowerItem.qml
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets // Still useful for QsMenuAnchor
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls // For Menu, MenuItem
import Quickshell.Io

MouseArea {
    id: root

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Math.max(powerText.width, 21)
    implicitHeight: 18

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            console.log("BRUH")
            executeBlueberry.running = true
        }
    }

    // --- Visual Icon/Text (using Text instead of IconImage) ---
    Text {
        id: powerText
        text: "󰂯" // Display the dynamically formatted string
        font.family: "Martian Mono Nerd Font" // You MUST have Nerd Font installed on your system
        font.pixelSize: 15 // Adjust size
        color: "#d8dee9" // Or your panel's text color
        anchors.centerIn: parent

        anchors.topMargin: 3
    }

    Process {
        id: executeBlueberry
        command: [
            "/bin/sh",    // Or "/bin/bash" if you prefer bash-specific features
            "-c",         // The -c option tells the shell to read commands from the string argument
            "killall blueberry; blueberry" // The actual command string to execute
        ]

        stdout: StdioCollector {
            // onStreamFinished: root.time = this.text
        }
    }
}