import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.UPower
import "root:/"
import "root:/components"

Rectangle {
    id: batteryBar

    property int sliderWidth: 150
    property int sliderHeight: 30

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    color: "transparent"

    RowLayout {
        id: mainLayout
        spacing: 10
        anchors.centerIn: parent

        // Battery icon/status
        Text {
            id: batteryIcon
            Layout.alignment: Qt.AlignVCenter
            font.family: Style.iconFontFamily
            font.pixelSize: 20
            color: getBatteryColor()
            text: getBatteryIcon()
        }

        // Battery percentage text
        Text {
            id: percentageText
            Layout.alignment: Qt.AlignVCenter
            font.family: Style.fontFamily
            font.pixelSize: 14
            font.bold: true
            color: getBatteryColor()
            text: (getBatteryPercentage() * 100).toFixed(0) + "%"
        }

        // Battery percentage slider (horizontal)
        Rectangle {
            id: sliderBackground
            Layout.alignment: Qt.AlignVCenter
            width: batteryBar.sliderWidth
            height: batteryBar.sliderHeight
            radius: Style.radius
            color: "#2e3440"

            Rectangle {
                id: sliderFill
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * getBatteryPercentage()
                height: parent.height
                radius: Style.radius
                color: getBatteryColor()

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }

        // Time remaining text
        Text {
            id: timeText
            Layout.alignment: Qt.AlignVCenter
            font.family: Style.fontFamily
            font.pixelSize: 12
            color: "#d8dee9"
            text: getTimeRemaining()
        }

        // Wattage text
        Text {
            id: wattageText
            Layout.alignment: Qt.AlignVCenter
            font.family: Style.fontFamily
            font.pixelSize: 12
            color: "#d8dee9"
            text: getWattage()
        }

        // Battery status text
        Text {
            id: statusText
            Layout.alignment: Qt.AlignVCenter
            font.family: Style.fontFamily
            font.pixelSize: 12
            color: "#d8dee9"
            text: getBatteryStatus()
        }
    }

    function getBatteryPercentage() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return 1.0;
        }
        if (UPower.displayDevice.healthSupported) {
            return UPower.displayDevice.percentage / UPower.displayDevice.healthPercentage;
        } else {
            return UPower.displayDevice.percentage;
        }
    }

    function getBatteryColor() {
        let percentage = getBatteryPercentage();
        if (percentage <= 0.1) {
            return "#bf616a"; // Red
        } else if (percentage <= 0.2) {
            return "#d08770"; // Orange
        } else if (percentage <= 0.4) {
            return "#ebcb8b"; // Yellow
        } else if (percentage >= 0.8) {
            return "#a3be8c"; // Green
        } else {
            return "#d8dee9"; // Default
        }
    }

    function getBatteryIcon() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return "󱘖"; // Plugged icon
        }

        if (UPower.displayDevice.state == UPowerDeviceState.Charging) {
            return ""; // Charging icon
        }

        // Battery level icons
        let percentage = getBatteryPercentage();
        let icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        let index = Math.floor(percentage * 10);
        index = Math.max(0, Math.min(index, icons.length - 1));
        return icons[index];
    }

    function getBatteryStatus() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return "AC Power";
        }

        switch (UPower.displayDevice.state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.Full:
            return "Full";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return "Unknown";
        }
    }

    function getTimeRemaining() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return "—:—";
        }

        let seconds = 0;
        if (UPower.displayDevice.state == UPowerDeviceState.Discharging) {
            seconds = UPower.displayDevice.timeToEmpty;
        } else if (UPower.displayDevice.state == UPowerDeviceState.Charging) {
            seconds = UPower.displayDevice.timeToFull;
        }

        if (seconds <= 0) {
            return "—:—";
        }

        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        return Qt.formatTime(new Date(0, 0, 0, h, m, 0), "hh:mm");
    }

    function getWattage() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return "—W";
        }

        let watts = UPower.displayDevice.energyRate;
        if (watts <= 0) {
            return "—W";
        }

        return watts.toFixed(1) + "W";
    }

    // Update UI when battery properties change
    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() {
            batteryBar.update();
        }
        function onStateChanged() {
            batteryBar.update();
        }
        function onTimeToFullChanged() {
            batteryBar.update();
        }
        function onTimeToEmptyChanged() {
            batteryBar.update();
        }
        function onEnergyRateChanged() {
            batteryBar.update();
        }
    }

    function update() {
        // Force update of all bindings
        batteryIcon.text = getBatteryIcon();
        batteryIcon.color = getBatteryColor();
        percentageText.text = (getBatteryPercentage() * 100).toFixed(0) + "%";
        percentageText.color = getBatteryColor();
        timeText.text = getTimeRemaining();
        wattageText.text = getWattage();
        statusText.text = getBatteryStatus();
    }

    Component.onCompleted: {
        update();
    }
}
