// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "../../../utils/"
Item {
  id: root
  property string color : "white"
  property bool enabled: true
  

  // width: enabled ? contentText.implicitWidth : 0
  opacity: enabled ? 1 : 0
  implicitWidth: contentText.implicitWidth + 20 // Add padding for aesthetics

  Text {
    id: contentText
    anchors.centerIn: parent
    text : Time.time
    color: root.color
    font.pixelSize: 20

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
