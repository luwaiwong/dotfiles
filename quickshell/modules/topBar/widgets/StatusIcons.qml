// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "../../../utils/"
import "root:/"

Rectangle {
    id: root
    property bool enabled: true

    // width: enabled ? contentText.implicitWidth : 0
    opacity: enabled ? 1 : 0
    implicitWidth: Math.max(contentText.implicitWidth + 20, 40)
    height: contentText.height + 5
    // color: "#2e3440"
    color: "transparent"
    radius: 20

    Text {
        id: contentText
        anchors.centerIn: parent
        text: Time.time
        color: "#d8dee9"
        font.family: Style.fontFamily
        font.pixelSize: 14

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 30
            easing.type: Easing.OutCubic
        }
    }
}
