import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "widgets"

Item {
    id : barContent
    anchors.centerIn: parent
    clip: true

    implicitWidth: isClockVisible ? clock.implicitWidth: workspace.implicitWidth
    implicitHeight: childrenRect.height

    required property var root
    
    property bool isClockVisible: true
    
    Workspaces {
        id: workspace
        bar: barContent.root
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: false  // Don't fill width to keep centered

        anchors.centerIn: parent
        enabled: !barContent.isClockVisible
        // MouseArea {
        //     anchors.fill: parent
        //     acceptedButtons: Qt.RightButton
        //     onPressed: (event) => {
        //         if (event.button === Qt.RightButton) {
        //             safeDispatch('global quickshell:overviewToggle')
        //         }
        //     }
        // }
    }
    Clock {
        id: clock
        color: "white"
        enabled: barContent.isClockVisible
        anchors.centerIn: parent

    }

    Connections {
        target: Hyprland
        function onRawEvent(event) { 
            if (event.name === "workspace") {
                showWorkspaces();
            }
        }
    }

    function showClock() {
        barContent.isClockVisible = true;

    }



    function showWorkspaces() {
        barContent.isClockVisible = false;
        showClockTimer.stop();
        showClockTimer.start();
        console.log(barContent.isClockVisible);

    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    Timer {
        id: showClockTimer
        interval: 1000
        repeat: false
        onTriggered: barContent.showClock()
    }

}