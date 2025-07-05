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
    property bool isClockVisible: true
    property bool hoveringTopBar: false
    property bool hoveringWorkspaces: false
    property bool hoveringTopTopBar: false
    property real curWorkspace: 0

    // --- Show/Hide Functions ---
    function onMainTopBarHovered(value) {
        hoveringTopBar = value
        if (value == true){
            showBar()
        } else if (!isClockVisible) {
            startLongHideTimer()    
        }
        else {
            startHideTimer()
        }
    }


    function onTopMainTopBarHovered(value) {
        hoveringTopTopBar = value
        if (value){
            hoveringWorkspaces = true
            showWorkspaces()
            showClockTimer.stop()
        }
    }

    function onWorkspaceHovered(value){
        hoveringWorkspaces = value
        if (value || hoveringTopTopBar){
            showClockTimer.stop()
            shortShowClockTimer.stop()
        } else if (!hoveringTopTopBar){
            shortShowClockTimer.start()

        }
    }

    function showBar() {
        hideBarTimer.stop();
        longHideBarTimer.stop();
        showTopBar = true
    }

    function hideBar() {
        showTopBar = false
        isClockVisible = true
    }

    function startHideTimer() {
        hideBarTimer.restart();
    }

    function startLongHideTimer() {
        longHideBarTimer.restart();
    }
    function startMediumHideBarTimer() {
        mediumHideBarTimer.restart();
    }



    Timer {
        id: hideBarTimer
        interval: 200
        repeat: false
        onTriggered: hideBar()
    }


    Timer {
        id: mediumHideBarTimer
        interval: 800
        repeat: false
        onTriggered: hideBar()
    }
    Timer {
        id: longHideBarTimer
        interval: 1800
        repeat: false
        onTriggered: hideBar()
    }

    function showClock() {
        isClockVisible = true;

    }

    function showWorkspaces() {
        isClockVisible = false;
        showClockTimer.stop();
        if (!hoveringWorkspaces) showClockTimer.start();

    }

    Timer {
        id: shortShowClockTimer
        interval: 300
        repeat: false
        onTriggered: showClock()
    }
    Timer {
        id: showClockTimer
        interval: 2500
        repeat: false
        onTriggered: showClock()
    }
}