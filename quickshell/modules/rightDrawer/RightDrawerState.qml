// BarState.qml
// pragma Singletonimport Quickshell
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import "root:/utils"

Item {
    id: root
    // --- State Variables ---
    property bool show: false
    property bool hovering: false
    property real curWorkspace: 0

    // bind the node so we can read its properties
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // --- Show/Hide Functions ---
    function onMainTopBarHovered(value) {
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
        interval: 1500
        repeat: false
        onTriggered: root.hideDrawer()
    }

    Connections {
        target: Pipewire.defaultAudioSink.audio
        onVolumeChanged: {
            console.log("Volume changed");
            root.startPopup();
        }
        onMutedChanged: {
            console.log("Muted changed");
            root.startPopup();
        }
    }

    Connections {
        target: Brightness
        onBrightnessPercentageChanged: {
            console.log("Brightness changed");
            root.startPopup();
        }
    }
}
