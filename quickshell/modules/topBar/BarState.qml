// State.qml
// pragma Singletonimport Quickshell
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../utils"

Item {
    id: root

    property bool debug: false

    // --- State Variables ---
    property bool showTopBar: true
    property bool isClockVisible: true
    property bool hoveringTopBar: false
    property bool hoveringWorkspaces: false
    property bool hoveringWorkspaceArea: false
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
                    if (root.debug)
                        console.log("openwindow event triggered");

                    root.startHideTimer();
                }

                // check if last window in workspace was just closed, show top bar
                if (event.name === "closewindow") {
                    // window count sometimes lags behind, if there was one window and you
                    // closed one, then there's probably 0 now

                    if (debug)
                        console.log("closewindow event triggered");

                    const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == root.curWorkspace);
                    if (windowsInThisWorkspace.length <= 1)
                        root.showBar();
                }
                if (event.name === "workspace" || event.name === "movewindow") {
                    root.curWorkspace = event.data;
                    root.showBar();

                    if (debug)
                        console.log("workspace event triggered");
                    // Find the biggest window in the current workspace
                    const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == event.data);
                    // Check if there are windows in this workspace
                    if (windowsInThisWorkspace.length > 1 && !root.hoveringTopBar) {
                        if (debug)
                            console.log("workspace has windows, hiding");

                        // Only if there are windows, hide the bar
                        root.startLongHideTimer();
                    }

                    root.showWorkspaces();
                }

                // Handle special workspace toggle - show bar and workspaces
                if (event.name === "activespecialv2") {
                    root.showBar();
                    root.showWorkspaces();

                    if (debug)
                        console.log("special workspace toggle triggered");

                    // Check if special workspace is being opened (non-empty name)
                    const parts = event.data.split(",");
                    const wsName = parts[1] || "";
                    if (wsName && !root.hoveringTopBar) {
                        root.startLongHideTimer();
                    }
                }
            }
        }
    }

    // --- Launcher Functions ---
    function openLauncher() {
        hideBarTimer.stop();
        longHideBarTimer.stop();
        showTopBar = true;
        isClockVisible = false;
        isLauncherOpen = true;
        searchQuery = "";
        selectedIndex = 0;
    }

    function closeLauncher() {
        isLauncherOpen = false;
        searchQuery = "";
        selectedIndex = 0;
        shortShowClockTimer.start();
    }

    function setSearchQuery(query) {
        searchQuery = query;
        selectedIndex = 0;
    }

    function selectNext(maxItems) {
        if (selectedIndex < maxItems - 1) {
            selectedIndex++;
        }
    }

    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--;
        }
    }

    // --- Show/Hide Functions ---
    function onMainTopBarHovered(value) {
        if (debug) {
            console.log("onMainTopBarHovered", value);
        }

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
        if (debug) {
            console.log("onWorkspaceAreaHovered", value);
        }

        hoveringWorkspaceArea = value;
        if (value) {
            hoveringWorkspaces = true;
            showWorkspaceTimer.start();
            shortShowClockTimer.stop();
            showClockTimer.stop();
        } else {
            showWorkspaceTimer.stop();
        }
    }

    function onWorkspaceHovered(value) {
        if (debug) {
            console.log("onWorkspaceHovered", value);
            console.log("hoveringWorkspaceArea", hoveringWorkspaceArea);
        }

        // value is true if hovering over workspaces
        hoveringWorkspaces = value;
        if (value || hoveringWorkspaceArea) {
            shortShowClockTimer.stop();
            showClockTimer.stop();
        } else if (!hoveringWorkspaceArea) {
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
        // isClockVisible = true;
        hideBarClockTimer.start();
    }

    function startHideTimer() {
        hideBarTimer.restart();
    }

    function startLongHideTimer() {
        longHideBarTimer.restart();
    }

    Timer {
        id: hideBarTimer
        interval: 100
        repeat: false
        onTriggered: root.hideBar()
    }

    Timer {
        id: longHideBarTimer
        interval: 1000
        repeat: false
        onTriggered: root.hideBar()
    }

    function showClock() {
        isClockVisible = true;
    }

    Timer {
        id: showWorkspaceTimer
        interval: 50
        repeat: false
        onTriggered: root.showWorkspaces()
    }
    function showWorkspaces() {
        isClockVisible = false;
        stopTimers();

        if (!hoveringWorkspaces && !hoveringWorkspaceArea) {
            showClockTimer.start();
            longHideBarTimer.start();
        }
    }

    function stopTimers() {
        hideBarTimer.stop();
        longHideBarTimer.stop();
        shortShowClockTimer.stop();
        showClockTimer.stop();
        showWorkspaceTimer.stop();
    }

    Timer {
        id: hideBarClockTimer
        interval: 100
        repeat: false
        onTriggered: root.showClock()
    }
    Timer {
        id: shortShowClockTimer
        interval: 250
        repeat: false
        onTriggered: root.showClock()
    }
    Timer {
        id: showClockTimer
        interval: 2000
        repeat: false
        onTriggered: root.showClock()
    }
}
