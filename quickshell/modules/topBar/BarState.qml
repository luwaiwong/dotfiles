// State.qml
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
    property real curWorkspace: 0

    // Launcher state
    property bool isLauncherOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            // console.log(event.name, event.data)
            // Only trigger event if the focused monitor is right
            if (Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)) {
                // Check if there are windows in this workspace, if one was opened hide bar
                if (event.name === "openwindow" && !root.hoveringTopBar) {
                    root.startHideTimer();
                }

                // check if last window in workspace was just closed, show top bar
                if (event.name === "closewindow") {
                    // window count sometimes lags behind, if there was one window and you
                    // closed one, then there's probably 0 now

                    const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == root.curWorkspace);
                    if (windowsInThisWorkspace.length <= 1)
                        root.showBar();
                }
                if (event.name === "workspace" || event.name === "movewindow") {
                    root.curWorkspace = event.data;
                    root.showBar();

                    // Find the biggest window in the current workspace
                    const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == event.data);
                    // Check if there are windows in this workspace
                    if (windowsInThisWorkspace.length > 0 && !root.hoveringTopBar) {
                        // ONly if there are windows,  hide the bar
                        root.startLongHideTimer();
                    }

                    root.showWorkspaces();
                }
            }
        }
    }

    // --- Launcher Functions ---
    function openLauncher() {
        hideBarTimer.stop()
        longHideBarTimer.stop()
        showTopBar = true
        isClockVisible = false
        isLauncherOpen = true
        searchQuery = ""
        selectedIndex = 0
    }

    function closeLauncher() {
        isLauncherOpen = false
        searchQuery = ""
        selectedIndex = 0
        shortShowClockTimer.start()
    }

    function setSearchQuery(query) {
        searchQuery = query
        selectedIndex = 0
    }

    function selectNext(maxItems) {
        if (selectedIndex < maxItems - 1) {
            selectedIndex++
        }
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--
        }
    }

    // --- Show/Hide Functions ---
    function onMainTopBarHovered(value) {
        hoveringTopBar = value;
        if (value == true) {
            showBar();
        } else if (isLauncherOpen) {
            // Don't auto-hide when launcher is open
        } else if (!isClockVisible) {
            startLongHideTimer();
        } else {
            startHideTimer();
        }
    }

    function onWorkspaceAreaHovered(value) {
        hoveringTopTopBar = value;
        if (value) {
            hoveringWorkspaces = true;
            showWorkspaceTimer.start();
            // showWorkspaces()
            shortShowClockTimer.stop();
            showClockTimer.stop();
        } else {
            showWorkspaceTimer.stop();
        }
    }

    function onWorkspaceHovered(value) {
        // value is true if hovering over workspaces
        hoveringWorkspaces = value;
        if (value || hoveringTopTopBar) {
            showClockTimer.stop();
            shortShowClockTimer.stop();
        } else if (!hoveringTopTopBar) {
            shortShowClockTimer.start();
        }
    }

    function showBar() {
        hideBarTimer.stop();
        longHideBarTimer.stop();
        showTopBar = true;
    }

    function hideBar() {
        showTopBar = false;
        // isClockVisible = true
        shortShowClockTimer.start();
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
        interval: 200
        repeat: false
        onTriggered: hideBar()
    }
    Timer {
        id: longHideBarTimer
        interval: 1000
        repeat: false
        onTriggered: hideBar()
    }

    function showClock() {
        isClockVisible = true;
    }

    Timer {
        id: showWorkspaceTimer
        interval: 50
        repeat: false
        onTriggered: showWorkspaces()
    }
    function showWorkspaces() {
        isClockVisible = false;
        shortShowClockTimer.stop();
        showClockTimer.stop();
        if (!hoveringWorkspaces)
            showClockTimer.start();
    }

    Timer {
        id: shortShowClockTimer
        interval: 250
        repeat: false
        onTriggered: showClock()
    }
    Timer {
        id: showClockTimer
        interval: 2000
        repeat: false
        onTriggered: showClock()
    }
}
