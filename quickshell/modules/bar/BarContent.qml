import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "widgets"
import "widgets/tray"

Rectangle {
    id : barContent
    required property var root
    required property BarState barState
    
    // anchors.centerIn: parent
    anchors.horizontalCenter: parent.horizontalCenter
    // anchors.topMargin: -20
    clip: true
    color: "transparent"

    implicitWidth: (barContent.barState.isClockVisible ? main.implicitWidth: workspace.implicitWidth)+20
    implicitHeight: 40


    Workspaces {
        id: workspace
        bar: barContent.root
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: false  // Don't fill width to keep centered

        anchors.centerIn: parent
        enabled: !barContent.barState.isClockVisible

        hoverEnabled: true
                propagateComposedEvents: true 
        onEntered: barContent.barState.onWorkspaceHovered(true);
        onExited: barContent.barState.onWorkspaceHovered(false);

        z: barContent.barState.isClockVisible ? 0 : 100

    }

    RowLayout {

        id: main        
        anchors.centerIn: parent

        // width: enabled ? contentText.implicitWidth : 0
        opacity: barContent.barState.isClockVisible ? 1 : 0
        z: barContent.barState.isClockVisible ? 100 : 0


        Tray {
            Layout.alignment: Qt.AlignRight
        }
        Date {
            Layout.alignment: Qt.AlignCenter
        }

        Clock {
            Layout.alignment: Qt.AlignCenter
        }

        Behavior on opacity {
            NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

}