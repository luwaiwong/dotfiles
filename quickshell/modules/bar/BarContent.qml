import QtQuick 
import QtQuick.Layouts
import "widgets"

RowLayout {
    id : barRoot
    anchors.centerIn: parent

    required property var root
    // Clock {
    //     color: "white"
    //     opacity: 1
    // }
    
    Workspaces {
        bar: root
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: false  // Don't fill width to keep centered
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
}