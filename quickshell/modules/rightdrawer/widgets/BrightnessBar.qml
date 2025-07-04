import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/components/" // Assuming your StyledSlider is here
import "root:/"
import "root:/utils/Brightness.qml" as BrightnessSingleton // Adjust this path!

Column {
    id: root

    property real sliderHeight: 200
    property real sliderWidth: 20

    spacing: 54

    // Access the Brightness singleton
    // You typically don't instantiate singletons with "id:" directly in QML
    // You access them via their exposed 'qmlName' (defined by 'pragma Singleton')
    // and the file's alias.
    // For a singleton named Brightness.qml with pragma Singleton, you can access it as BrightnessSingleton.
    // However, since it's a pragma Singleton and accessible by its file name as a type,
    // you can directly use `BrightnessSingleton.monitors` etc.

    // If you need a specific monitor, you'll want to pass it as a property
    // or determine it dynamically, for example, based on the focused Hyprland monitor.
    // For simplicity, let's assume we're controlling the brightness of the *first* monitor
    // or the one associated with the focused screen for now.

    property var targetMonitor: {
        // This will attempt to find the monitor object from your Brightness singleton
        // corresponding to the currently focused Hyprland monitor.
        // If Hyprland is not active or you want to control a fixed monitor,
        // you might adjust this logic.
        const focusedScreenName = Hyprland.focusedMonitor.name;
        return BrightnessSingleton.monitors.find(m => m.screen.name === focusedScreenName)
               || BrightnessSingleton.monitors[0]; // Fallback to the first monitor
    }

    property string currentBrightnessIcon: {
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
        value: targetMonitor && targetMonitor.ready ? targetMonitor.brightness : 0
        // When the custom slider's value changes, update the targetMonitor's brightness
        onValueChanged: {
            if (targetMonitor) {
                targetMonitor.setBrightness(value);
            }
        }

        // Listen for brightness changes from the singleton to update the slider
        Connections {
            target: BrightnessSingleton
            function onBrightnessChanged() {
                // Force update of the slider's value if the brightness changes externally
                // This ensures the slider reflects changes made by global shortcuts, etc.
                if (targetMonitor && targetMonitor.ready) {
                    root.StyledSlider.value = targetMonitor.brightness;
                }
            }
        }

        textSize: 14
        radius: Style.radius

        height: root.sliderHeight - sliderWidth/2
        width: root.sliderWidth
        icon: root.currentBrightnessIcon
    }
}