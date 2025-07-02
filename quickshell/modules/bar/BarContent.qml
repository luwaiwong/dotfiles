import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "widgets"
import "widgets/tray"

Item {
    id : barContent
    required property var root
    required property BarState barState
    
    // anchors.centerIn: parent
    anchors.horizontalCenter: parent.horizontalCenter
    // anchors.topMargin: -20
    clip: true

    implicitWidth: barContent.barState.isClockVisible ? main.implicitWidth: workspace.implicitWidth
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

    }

    RowLayout {

        id: main        
        anchors.centerIn: parent

        // width: enabled ? contentText.implicitWidth : 0
        opacity: barContent.barState.isClockVisible ? 1 : 0

        Tray {
            Layout.alignment: Qt.AlignLeft
        }
        Date {
            Layout.alignment: Qt.AlignCenter
        }

        Clock {
            Layout.alignment: Qt.AlignCenter
        }

        Behavior on opacity {
            NumberAnimation {
            duration: 30
            easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

}