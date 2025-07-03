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
    implicitWidth: Math.max(powerText.width, 21)
    implicitHeight: 18

    // --- Configuration for Icons and Formatting (from your provided snippet) ---
    // These are now properties of the PowerItem itself for easy access/modification
    property var iconFormats: [
        "󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" // 0-100% in 10 steps, plus full
    ]
    property string chargingIcon: ""
    property string pluggedIcon: "󱘖"

    property int batteryIconLevelSteps: 10 // Your format-icons array has 11 elements (0-100, 10 steps)

    property int mode: 0
    property int maxMode: 3

    function getCurrentIconChar() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return root.pluggedIcon; // No battery, just show plugged icon
        }

        if (UPower.displayDevice.timeToFull != 0) {
            return root.pluggedIcon;
        }

        // Determine battery icon based on level
        // map 0-100% to indices 0-10 of format-icons (11 elements)
        let index = Math.floor(getRealPercentage()*100 / root.batteryIconLevelSteps);
        // Ensure index is within bounds [0, iconFormats.length - 1]
        index = Math.max(0, Math.min(index, root.iconFormats.length - 1));
        return root.iconFormats[index];
    }

    property string formattedBatteryText: "󱘖"
    
    function setFormattedBatteryText() {
        if (UPower.displayDevice.isLaptopBattery){

            switch (mode) {
                case 0: 
                    formattedBatteryText = getCurrentIconChar();
                    break
                case 1: 
                    formattedBatteryText = getRealPercentage()*100 + "%"
                    break
                case 2:
                    formattedBatteryText = getTime()
                    break
                case 3:
                    formattedBatteryText = UPower.displayDevice.changeRate.toFixed(2)
                    break
            }
        } else {
            formattedBatteryText = getCurrentIconChar();
        }
    }

    function getRealPercentage() {
        if (UPower.displayDevice.healthSupported){

            return UPower.displayDevice.percentage / UPower.displayDevice.healthPercentage
        }
        else {
            return UPower.displayDevice.percentage
        }
    }

    function getTime(){
        if (UPower.displayDevice.state == UPowerDeviceState.Discharging){
            return formatTime(UPower.displayDevice.timeToEmpty)
        } else if (UPower.displayDevice.state == UPowerDeviceState.Charging){
            return formatTime(UPower.displayDevice.timeToFull)
        }
    }

    function formatTime(seconds) {
        if (seconds <= 0) return "—:—";
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        return Qt.formatTime(new Date(0, 0, 0, h, m, 0), "hh:mm");
    }
    // Connections to update displayed text and icon character
    Connections {
        target: UPower.displayDevice // Target the displayDevice object directly
        function onPercentageChanged() {
            root.setFormattedBatteryText()
        }
        function onTimeToFullChanged() { // This will implicitly cover charging state changes
            root.setFormattedBatteryText()
        }
        function onTimeToEmptyChanged() { // This will implicitly cover discharging state changes
            root.setFormattedBatteryText()
        }
        function onIsLaptopBatteryChanged() { // If a battery is connected/disconnected
            root.setFormattedBatteryText()
        }
        function onStateChanged() { // Generic state changes if the above don't cover everything
            root.setFormattedBatteryText()
        }
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            root.mode = (root.mode + 1) % (root.maxMode + 1);
            console.log(mode)
            root.setFormattedBatteryText(); 
        }
    }

    // --- Visual Icon/Text (using Text instead of IconImage) ---
    Text {
        id: powerText
        text: root.formattedBatteryText // Display the dynamically formatted string
        font.family: "Martian Mono Nerd Font" // You MUST have Nerd Font installed on your system
        font.pixelSize: 15 // Adjust size
        color: "#d8dee9" // Or your panel's text color
        anchors.centerIn: parent

        anchors.topMargin: 3
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