pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

/**
 * For managing brightness of monitors using brightnessctl.
 */
Singleton {
    id: root

    // signal brightnessChanged()

    property real brightness:0 
    property real maxBrightness: 255
    property real brightnessPercentage: {
        return (brightness/maxBrightness).toFixed(2)
    }


    // reloadableId: "brightness"

    // --- Brightness Device Discovery ---
    Component.onCompleted: {
        // Run the discovery process when the component is created
        getBrightness.running = true;
        brightnessMonitorTimer.start()
    }

    Process {
        id: getBrightness
        // List all detected backlight devices and their associated output names
        // e.g., "Device 'intel_backlight': Found 1 outputs (eDP-1,)"
        command: ["brightnessctl", "g"]
        stdout: SplitParser {
            splitMarker: "\n" // Split by line
            onRead: data => {
                if (root.brightness != data){
                    root.brightness = data
                }
            }
        }
    }

    Process {
        id: getMaxBrightness
        // List all detected backlight devices and their associated output names
        // e.g., "Device 'intel_backlight': Found 1 outputs (eDP-1,)"
        command: ["brightnessctl", "m"]
        stdout: SplitParser {
            splitMarker: "\n" // Split by line
            onRead: data => {
                root.maxBrightness = data
            }
        }
    }


    // Sets brightness
    Process {
        id: setProc

        // No command specified here, will be set by whoever calls.

        onExited: {
            if (setProc.exitCode !== 0) {
                console.error(`brightnessctl error: ${setProc.stderr}`);
            }
        }
    }

    // Timer to periodically check brightness
    Timer {
        id: brightnessMonitorTimer
        interval: 500 // Check every 500 milliseconds (0.5 seconds)
        running: false
        repeat: true
        onTriggered: {
            getBrightness.running = true; // Rerun the getBrightness process
        }
    }

        // Sets the brightness for the associated device
    function setBrightness(value: real): void {

        const realValue = Math.round(value * maxBrightness);

        // Avoid setting if the rounded percentage is already the same or is 0
        if (Math.round(brightness) === realValue || realValue == 0)
            return;

        brightness = value; // Optimistically update local property

        // Use the global setProc to avoid creating many processes
        // Ensure only one brightnessctl command runs at a time if possible
        setProc.command = ["brightnessctl", "set", `${realValue}`, "--quiet"];
        setProc.startDetached(); // Start the process without waiting for it to exit
        // Re-initialize after setting to get the true, updated brightness
        // A small delay might be useful if the system needs time to apply the change
        // Or just listen to some external brightness change signals if available (e.g. udev events)
        // For simplicity, we re-initialize immediately here.
        // A small timeout ensures the `set` command has a chance to execute before `info` is called.
        // Qt.callLater(getBrightness);
    }

}