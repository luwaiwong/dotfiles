pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

MouseArea{

    implicitWidth: Math.max(100, layout.width+20)
    implicitHeight: 25


    hoverEnabled: true
    propagateComposedEvents: true
    
    onEntered: root.hovering = true;
    onExited: root.hovering = false;
    
    Rectangle {
        id: root

        anchors.fill: parent
        clip: true
        visible: width > 0 && height > 0

        color: "#2e3440"
        radius: 20

        property bool hovering: false
            Row {
                id: layout
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                spacing: 2
                
                add: Transition {
                    NumberAnimation {
                        properties: "scale"
                        from: 0
                        to: 1
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                move: Transition {
                    NumberAnimation {
                        properties: "scale"
                        from: 0
                        to: 1
                        duration: 400
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        properties: "x,y"
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
                // Sort for only nm-applet
                Repeater {
                    model: SystemTray.items

                    TrayItem {
                        width: modelData.id == "nm-applet" ? 23: 0

                        Layout.alignment: Qt.AlignCenter
                    }
                }   
                Bluetooth {}
                Power {
                    Layout.alignment: Qt.AlignCenter
                }

                // Show rest of tray
                Repeater {
                    model: SystemTray.items
                    TrayItem {
                        width: (modelData.id != "nm-applet" && root.hovering)? 23: 0
                    }
                }
                Behavior on width{
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic //
                    }
                }
            }
    }

    // Behavior on implicitWidth{
    //     NumberAnimation {
    //         duration: 500
    //         easing.type: Easing.OutCubic //
    //     }
    // }
}