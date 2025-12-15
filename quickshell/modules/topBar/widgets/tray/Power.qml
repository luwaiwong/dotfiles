// PowerItem.qml
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets // Still useful for QsMenuAnchor
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls // For Menu, MenuItem
import "root:/"

MouseArea {
    id: root

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: mode == 0 ? Math.max(powerText.width, 18) : Math.max(powerText.width, 18)
    implicitHeight: 18
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // --- Configuration for Icons and Formatting (from your provided snippet) ---
    // These are now properties of the PowerItem itself for easy access/modification
    property var iconFormats: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" // 0-100% in 10 steps, plus full
    ]
    property string chargingIcon: ""
    property string pluggedIcon: "󱘖"
    property string color: "#d8dee9" // Default battery color

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
        let index = Math.floor(getRealPercentage() * 100 / root.batteryIconLevelSteps);
        // Ensure index is within bounds [0, iconFormats.length - 1]
        index = Math.max(0, Math.min(index, root.iconFormats.length - 1));
        return root.iconFormats[index];
    }

    property string formattedBatteryText: "󱘖"

    function setFormattedBatteryText() {
        // Determine color based on battery level
        if (getRealPercentage() <= 0.1) {
            root.color = "#bf616a";
        } else if (getRealPercentage() <= 0.2) {
            root.color = "#d08770";
        } else if (getRealPercentage() <= 0.4) {
            root.color = "#ebcb8b";
        } else if (getRealPercentage() >= 0.8) {
            root.color = "#a3be8c";
        } else {
            root.color = "#d8dee9";
        }

        // Determine the text to display based on mode and battery status
        if (UPower.displayDevice.isLaptopBattery) {
            switch (mode) {
            case 0:
                formattedBatteryText = getCurrentIconChar();
                break;
            case 1:
                formattedBatteryText = (getRealPercentage() * 100).toFixed(0) + "%";
                break;
            case 2:
                formattedBatteryText = getTime();
                break;
            case 3:
                formattedBatteryText = (UPower.displayDevice.state == UPowerDeviceState.Discharging ? "-" : "+") + UPower.displayDevice.changeRate.toFixed(2);
                break;
            }
        } else {
            formattedBatteryText = getCurrentIconChar();
        }
    }

    function getRealPercentage() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return 100;
        }
        if (UPower.displayDevice.healthSupported) {
            return UPower.displayDevice.percentage / UPower.displayDevice.healthPercentage;
        } else {
            return UPower.displayDevice.percentage;
        }
    }

    function getTime() {
        if (UPower.displayDevice.state == UPowerDeviceState.Discharging) {
            return formatTime(UPower.displayDevice.timeToEmpty);
        } else if (UPower.displayDevice.state == UPowerDeviceState.Charging) {
            return formatTime(UPower.displayDevice.timeToFull);
        }
    }

    function formatTime(seconds) {
        if (seconds <= 0)
            return "—:—";
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        return Qt.formatTime(new Date(0, 0, 0, h, m, 0), "hh:mm");
    }
    // Connections to update displayed text and icon character
    Connections {
        target: UPower.displayDevice // Target the displayDevice object directly
        function onPercentageChanged() {
            root.setFormattedBatteryText();
        }
        function onTimeToFullChanged() { // This will implicitly cover charging state changes
            root.setFormattedBatteryText();
        }
        function onTimeToEmptyChanged() { // This will implicitly cover discharging state changes
            root.setFormattedBatteryText();
        }
        function onIsLaptopBatteryChanged() { // If a battery is connected/disconnected
            root.setFormattedBatteryText();
        }
        function onStateChanged() { // Generic state changes if the above don't cover everything
            root.setFormattedBatteryText();
        }
        function onReadyChanged() { // Generic state changes if the above don't cover everything
            root.setFormattedBatteryText();
        }
    }

    onClicked: event => {
        if (event.button === Qt.LeftButton || UPower.displayDevice.isLaptopBattery) {
            root.mode = (root.mode + 1) % (root.maxMode + 1);
            console.log(mode);
            root.setFormattedBatteryText();
        }
    }

    // --- Visual Icon/Text (using Text instead of IconImage) ---
    Text {
        id: powerText
        text: root.formattedBatteryText // Display the dynamically formatted string
        font.family: Style.iconFontFamily
        font.pixelSize: mode == 0 ? 17 : 17 // Adjust size
        color: root.color // Or your panel's text color
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1

        // anchors.verticalCenterOffset: mode == 0 ? 0 : 0
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
