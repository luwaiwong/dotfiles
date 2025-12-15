import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/utils"

Item {
    id: root
    // --- State Variables ---
    property bool show: false
    property bool hovering: false
    property int lastNotifiedPercentage: -1 // Track last percentage that triggered a notification

    // --- Show/Hide Functions ---
    function onMainBottomBarHovered(value) {
        hovering = value;
        if (value == true) {
            stopTimers();
            showTimer.start();
        } else {
            startHideTimer();
            showTimer.stop();
        }
    }

    function stopTimers() {
        showTimer.stop();
        hideTimer.stop();
        popupHideTimer.stop();
    }

    function showDrawer() {
        stopTimers();
        show = true;
    }

    function hideDrawer() {
        show = false;
    }

    function startPopup() {
        stopTimers();
        showDrawer();
        show = true;
        popupHideTimer.restart();
    }

    function startShowTimer() {
        showTimer.restart();
    }
    function startHideTimer() {
        hideTimer.restart();
    }

    function checkLowBattery() {
        if (!UPower.displayDevice.isLaptopBattery) {
            return;
        }

        let percentage = UPower.displayDevice.percentage;
        let percentageInt = Math.floor(percentage * 100);
        let isCharging = UPower.displayDevice.state == UPowerDeviceState.Charging;
        let isDischarging = UPower.displayDevice.state == UPowerDeviceState.Discharging;

        // Reset notification tracking when charging
        if (isCharging) {
            root.lastNotifiedPercentage = -1;
            return;
        }

        // Only show notifications when discharging
        if (!isDischarging) {
            return;
        }

        let shouldNotify = false;

        // Determine if we should notify based on battery level
        if (percentageInt <= 5) {
            // Below 5%: notify every 1%
            if (percentageInt < root.lastNotifiedPercentage || root.lastNotifiedPercentage == -1) {
                shouldNotify = true;
            }
        } else if (percentageInt <= 20) {
            // Between 6% and 20%: notify every 5%
            let notificationThreshold = Math.floor(percentageInt / 5) * 5;
            if (root.lastNotifiedPercentage == -1 || percentageInt <= notificationThreshold && root.lastNotifiedPercentage > notificationThreshold) {
                shouldNotify = true;
            }
        } else {
            // Above 20%: notify every 20%
            let notificationThreshold = Math.floor(percentageInt / 20) * 20;
            if (root.lastNotifiedPercentage == -1 || percentageInt <= notificationThreshold && root.lastNotifiedPercentage > notificationThreshold) {
                shouldNotify = true;
            }
        }

        if (shouldNotify) {
            console.log("Battery notification triggered at " + percentageInt + "%");
            root.lastNotifiedPercentage = percentageInt;
            root.startPopup();
        }
    }

    Timer {
        id: showTimer
        interval: 500
        repeat: false
        onTriggered: root.showDrawer()
    }
    Timer {
        id: hideTimer
        interval: 200
        repeat: false
        onTriggered: root.hideDrawer()
    }

    Timer {
        id: popupHideTimer
        interval: 3000 // Show low battery warning for 3 seconds
        repeat: false
        onTriggered: root.hideDrawer()
    }

    // Monitor battery percentage changes
    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() {
            root.checkLowBattery();
        }
        function onStateChanged() {
            root.checkLowBattery();
        }
        function onReadyChanged() {
            if (UPower.displayDevice.ready) {
                root.checkLowBattery();
            }
        }
    }

    Component.onCompleted: {
        // Initial check when component loads
        if (UPower.displayDevice.ready) {
            root.checkLowBattery();
        }
    }
}
