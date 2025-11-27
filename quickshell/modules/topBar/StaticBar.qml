// Your main QML file (e.g., in your project root or wherever PanelWindow is defined)
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "widgets"

Scope{
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id : barRoot
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            property bool isShown: false // Initially hidden

            color: "white"
            implicitHeight: 40 // Total height of the PanelWindow
            // implicitWidth: modelData.width/2


            Rectangle {
                id: barShape
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                // --- THE FIX STARTS HERE ---

                // Drive the bar's position directly from effectiveVerticalOffset
                // When effectiveVerticalOffset is 0, bar is at top.
                // When effectiveVerticalOffset is negative, bar moves up.
                anchors.topMargin: 0

                // --- THE FIX ENDS HERE ---

                width: parent.width
                height: implicitHeight
                color: "white"

                Workspaces {
                    bar: barRoot
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: false  // Don't fill width to keep centered
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressed: (event) => {
                            if (event.button === Qt.RightButton) {
                                safeDispatch('global quickshell:overviewToggle')
                            }
                        }
                    }
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "windowh"
                    color: "black"
                    
                }
            }

        }
    }
}