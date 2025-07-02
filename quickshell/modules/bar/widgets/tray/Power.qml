// PowerItem.qml
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets // Still useful for QsMenuAnchor
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls // For Menu, MenuItem

MouseArea {
    id: root

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 20 
    implicitHeight: 20

    // --- Configuration for Icons and Formatting (from your provided snippet) ---
    // These are now properties of the PowerItem itself for easy access/modification
    property var iconFormats: [
        "󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" // 0-100% in 10 steps, plus full
    ]
    property string chargingIcon: ""
    property string pluggedIcon: "󱘖"
    property string formatString: "{icon} {capacity}%"
    property string formatDischargingString: " {capacity}%"
    property string formatPluggedString: "󱘖 {capacity}%"
    property string formatFullString: "{icon} Full"
    property string formatBatteryString: "{icon} {time}"
    property string formatTimeString: "{H}h {M}min"
    property int batteryIconLevelSteps: 10 // Your format-icons array has 11 elements (0-100, 10 steps)

    property int mode: 0

    property string currentIconChar: {
        if (!UPower.displayDevice.isLaptopBattery) {
            return root.pluggedIcon; // No battery, just show plugged icon
        }

        if (UPower.displayDevice.timeToFull != 0) {
            return root.chargingIcon;
        }

        // Determine battery icon based on level
        // map 0-100% to indices 0-10 of format-icons (11 elements)
        let index = Math.floor(UPower.batteryLevel / root.batteryIconLevelSteps);
        // Ensure index is within bounds [0, iconFormats.length - 1]
        index = Math.max(0, Math.min(index, root.iconFormats.length - 1));
        return root.iconFormats[index];
    }

    property string formattedBatteryText: {
        let text = "";

        if (!UPower.displayDevice.isLaptopBattery) { // If there is no battery connected
            text = root.pluggedIcon; 
        } 
        else if (UPower.displayDevice.timeToFull != 0) { // If Charging
            text = root.formatPluggedString.arg("capacity", UPower.displayDevice.percentage.toFixed(0));
        } 
        else if (UPower.displayDevice.timeToEmpty != 0) { // If Discharging
            text = root.formatDischargingString.arg("capacity", UPower.displayDevice.percentage.toFixed(0));
        } 
        return text;
    }

    // Connections to update displayed text and icon character
    Connections {
        target: UPower
        // Re-evaluate currentIconChar and formattedBatteryText on any relevant UPower change
        function onBatteryLevelChanged() { root.currentIconChar = root.currentIconChar; root.formattedBatteryText = root.formattedBatteryText; }
        function onIsChargingChanged() { root.currentIconChar = root.currentIconChar; root.formattedBatteryText = root.formattedBatteryText; }
        function onStateChanged() { root.currentIconChar = root.currentIconChar; root.formattedBatteryText = root.formattedBatteryText; }
        function onHasBatteryChanged() { root.currentIconChar = root.currentIconChar; root.formattedBatteryText = root.formattedBatteryText; }
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton || event.button === Qt.RightButton) {
            powerMenu.open();
        }
    }

    // --- Visual Icon/Text (using Text instead of IconImage) ---
    Text {
        id: powerText
        text: root.formattedBatteryText // Display the dynamically formatted string
        font.family: "Nerd Font" // You MUST have Nerd Font installed on your system
        font.pixelSize: parent.height * 0.8 // Adjust size
        color: "white" // Or your panel's text color
        anchors.centerIn: parent
        // Ensure text doesn't clip if implicitWidth/Height is too small
        // Might need to make parent (MouseArea) bigger or scale text
    }

    // --- Power Menu ---
    // QsMenuAnchor {
    //     id: powerMenu

    //     menu: Menu {
    //         title: "Power Options"

    //         MenuItem {
    //             text: "Suspend"
    //             // No icon.name/source for these if you only have unicode for battery
    //             // If your system supports standard theme icons, you can use icon.name: "system-suspend"
    //             onTriggered: UPower.suspend()
    //         }

    //         MenuItem {
    //             text: "Hibernate"
    //             onTriggered: UPower.hibernate()
    //         }

    //         MenuItem {
    //             text: "Reboot"
    //             onTriggered: UPower.reboot()
    //         }

    //         MenuItem {
    //             text: "Shutdown"
    //             onTriggered: UPower.powerOff()
    //         }

    //         MenuSeparator {}

    //         // Display current battery status/level
    //         MenuItem {
    //             text: root.formattedBatteryText // Use the same formatted string for the menu item
    //             enabled: false // Make this item non-clickable, just for display
    //         }
    //     }
    //     anchor.window: this.QsWindow.window
    // }

    Component.onCompleted: {
        console.log("PowerItem initialized with UPower service and string icons.");
        // Trigger initial update
        root.formattedBatteryText = root.formattedBatteryText;
    }
}