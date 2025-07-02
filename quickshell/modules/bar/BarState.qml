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
    property bool showTopBar: true
    property bool isClockVisible: true
    property bool hoveringTopBar: false
    property bool hoveringWorkspaces: false
    property bool hoveringTopTopBar: false
    

    Connections {
        target: Hyprland
        function onRawEvent(event) { 
            // console.log(event.name, event.data)
            if ((event.name === "workspace" || 
                event.name === "movewindow")
                && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)
            ) {
                root.showBar()

                // Find the biggest window in the current workspace
                const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == event.data)
                // Check if there are windows in this workspace
                if (windowsInThisWorkspace.length > 0 && !root.hoveringTopBar) {
                    // ONly if there are windows,  hide the bar
                    root.startLongHideTimer(); 
                }

                root.showWorkspaces()
            }
        }
    }

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
        console.log("hovered")
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
        } else {
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
        interval: 1500
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
        interval: 200
        repeat: false
        onTriggered: showClock()
    }
    Timer {
        id: showClockTimer
        interval: 1000
        repeat: false
        onTriggered: showClock()
    }
}