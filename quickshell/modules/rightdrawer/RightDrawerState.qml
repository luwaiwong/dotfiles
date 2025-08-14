// BarState.qml
// pragma Singletonimport Quickshell
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/utils" 

Item {
    id: root
    // --- State Variables ---
    property bool showTopBar: false
    property bool hoveringTopBar: false
    property real curWorkspace: 0

    // --- Show/Hide Functions ---
    function onMainTopBarHovered(value) {
        hoveringTopBar = value
        if (value == true){
            showBarTimer.start()
        } 
        else {
            startHideTimer()
            showBarTimer.stop()
        }
    }


    function showBar() {
        hideBarTimer.stop();
        showTopBar = true
    }

    function hideBar() {
        showTopBar = false
    }

    function startShowTimer() {
        showBarTimer.restart();
    }
    function startHideTimer() {
        hideBarTimer.restart();
    }




    Timer {
        id: showBarTimer
        interval: 500
        repeat: false
        onTriggered: showBar()
    }
    Timer {
        id: hideBarTimer
        interval: 200
        repeat: false
        onTriggered: hideBar()
    }
}