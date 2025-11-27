import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/components/" // Assuming your StyledSlider is here
import "root:/"
import "root:/utils/" // Adjust this path!

Column {
    id: root

    property real sliderHeight: 200
    property real sliderWidth: 20

    spacing: 54

    property string currentBrightnessIcon: {

            return "󰛨"; // Brightness off icon or similar
        if (!targetMonitor || !targetMonitor.ready) {
            return "󰛨"; // Default icon if monitor is not ready
        }
        const value = targetMonitor.brightness;
        if (value > 0.80) {
            return "󰛨"; // Brightness high icon
        } else if (value > 0.2) {
            return "󰛧"; // Brightness medium icon
        } else if (value > 0.0) {
            return "󰛥"; // Brightness low icon
        } else {
            return "󰛨"; // Brightness off icon or similar
        }
    }

    StyledSlider {
        Layout.alignment: Qt.AlignCenter

        // Bind the custom slider's value to the targetMonitor's brightness
        // Check if targetMonitor is valid and ready before binding
        value: Brightness.brightnessPercentage
        // When the custom slider's value changes, update the targetMonitor's brightness
        onValueChanged:  {
            Brightness.setBrightness(value);
        }

        textSize: 14
        radius: Style.radius

        height: root.sliderHeight - sliderWidth/2
        width: root.sliderWidth
        icon: root.currentBrightnessIcon
    }
}