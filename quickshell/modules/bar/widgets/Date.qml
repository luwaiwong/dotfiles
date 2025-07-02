// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "../../../utils/"
Item {
  property bool enabled: true
  

  // width: enabled ? contentText.implicitWidth : 0
  opacity: enabled ? 1 : 0
  implicitWidth: contentText.implicitWidth + 20 // Add padding for aesthetics

  Text {
    id: contentText
    anchors.centerIn: parent
    text : Time.date
    color: "#eceff4"
    font.pixelSize: 16

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
