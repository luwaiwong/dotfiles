// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "../../../utils/"
Rectangle {
  id: root
  property bool enabled: true
  

  // width: enabled ? contentText.implicitWidth : 0
  opacity: enabled ? 1 : 0
  implicitWidth: Math.max(contentText.implicitWidth + 20, 40)
  height: contentText.height+5
  // color: "#2e3440"
  color: "transparent"
  radius: 20

  Text {
    anchors.centerIn: parent
    id: contentText
    text : Time.time
    color: "#d8dee9"
    font.pixelSize: 14

    font.family: "Martian Mono Nerd Font"
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
