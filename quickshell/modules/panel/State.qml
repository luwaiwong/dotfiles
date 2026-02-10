import QtQuick

Item {
    id: root
    
    required property var screen
    
    property bool showTopBar: true
    property bool showLeftDrawer: false
    property bool showRightDrawer: false
    property bool hoveringTopBar: false
    property bool hoveringLeftDrawer: false
    property bool hoveringRightDrawer: false
    property bool isClockVisible: true
    property bool hoveringWorkspaces: false
    property bool hoveringWorkspaceArea: false
    property bool isLauncherOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property real curWorkspace: 0
    
    // Top bar functions
    function onMainTopBarHovered(value) {
        hoveringTopBar = value
        if (value) {
            showTopBarNow()
        } else if (!isClockVisible) {
            startTopBarLongHideTimer()
        } else {
            startTopBarHideTimer()
        }
    }
    
    function onWorkspaceAreaHovered(value) {
        hoveringWorkspaceArea = value
        if (value) {
            hoveringWorkspaces = true
            topBarShowWorkspaceTimer.start()
            topBarShortShowClockTimer.stop()
            topBarShowClockTimer.stop()
        } else {
            topBarShowWorkspaceTimer.stop()
        }
    }
    
    function onWorkspaceHovered(value) {
        hoveringWorkspaces = value
        if (value || hoveringWorkspaceArea) {
            topBarShortShowClockTimer.stop()
            topBarShowClockTimer.stop()
        } else if (!hoveringWorkspaceArea) {
            topBarShortShowClockTimer.start()
        }
    }
    
    function showTopBarNow() {
        topBarHideTimer.stop()
        topBarLongHideTimer.stop()
        showTopBar = true
    }
    
    function hideTopBar() {
        showTopBar = false
        topBarHideClockTimer.start()
    }
    
    function startTopBarHideTimer() { topBarHideTimer.restart() }
    function startTopBarLongHideTimer() { topBarLongHideTimer.restart() }
    function showClock() { isClockVisible = true }
    
    function showWorkspaces() {
        isClockVisible = false
        stopTopBarTimers()
        if (!hoveringWorkspaces && !hoveringWorkspaceArea) {
            topBarShowClockTimer.start()
            topBarLongHideTimer.start()
        }
    }
    
    function stopTopBarTimers() {
        topBarHideTimer.stop()
        topBarLongHideTimer.stop()
        topBarShortShowClockTimer.stop()
        topBarShowClockTimer.stop()
        topBarShowWorkspaceTimer.stop()
    }
    
    function openLauncher() {
        topBarHideTimer.stop()
        topBarLongHideTimer.stop()
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
        topBarShortShowClockTimer.start()
    }
    
    function setSearchQuery(query) { searchQuery = query; selectedIndex = 0 }
    function selectNext(maxItems) { if (selectedIndex < maxItems - 1) selectedIndex++ }
    function selectPrevious() { if (selectedIndex > 0) selectedIndex-- }
    
    // Top bar timers
    Timer { id: topBarHideTimer; interval: 100; onTriggered: root.hideTopBar() }
    Timer { id: topBarLongHideTimer; interval: 1000; onTriggered: root.hideTopBar() }
    Timer { id: topBarHideClockTimer; interval: 100; onTriggered: root.showClock() }
    Timer { id: topBarShortShowClockTimer; interval: 250; onTriggered: root.showClock() }
    Timer { id: topBarShowClockTimer; interval: 2000; onTriggered: root.showClock() }
    Timer { id: topBarShowWorkspaceTimer; interval: 50; onTriggered: root.showWorkspaces() }
    
    // Left drawer functions
    function onLeftDrawerHovered(value) {
        hoveringLeftDrawer = value
        if (value) {
            leftDrawerShowTimer.restart()
        } else {
            leftDrawerHideTimer.restart()
            leftDrawerShowTimer.stop()
        }
    }
    
    function showLeftDrawerNow() { leftDrawerHideTimer.stop(); showLeftDrawer = true }
    function hideLeftDrawer() { showLeftDrawer = false }
    
    Timer { id: leftDrawerShowTimer; interval: 500; onTriggered: root.showLeftDrawerNow() }
    Timer { id: leftDrawerHideTimer; interval: 200; onTriggered: root.hideLeftDrawer() }
    
    // Right drawer functions
    function onRightDrawerHovered(value) {
        hoveringRightDrawer = value
        if (value) {
            stopRightDrawerTimers()
            rightDrawerShowTimer.start()
        } else {
            rightDrawerHideTimer.restart()
            rightDrawerShowTimer.stop()
        }
    }
    
    function stopRightDrawerTimers() {
        rightDrawerShowTimer.stop()
        rightDrawerHideTimer.stop()
        rightDrawerPopupTimer.stop()
    }
    
    function showRightDrawerNow() { stopRightDrawerTimers(); showRightDrawer = true }
    function hideRightDrawer() { showRightDrawer = false }
    function startRightDrawerPopup() { stopRightDrawerTimers(); showRightDrawerNow(); rightDrawerPopupTimer.restart() }
    
    Timer { id: rightDrawerShowTimer; interval: 500; onTriggered: root.showRightDrawerNow() }
    Timer { id: rightDrawerHideTimer; interval: 200; onTriggered: root.hideRightDrawer() }
    Timer { id: rightDrawerPopupTimer; interval: 1500; onTriggered: root.hideRightDrawer() }
}
