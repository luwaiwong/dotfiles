import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "widgets"


Rectangle {
    id : barContent
    required property var root
    required property RightDrawerState state
    
    // anchors.centerIn: parent
    anchors.verticalCenter: parent.verticalCenter
    // anchors.topMargin: -20
    clip: true
    color: "transparent"


    implicitWidth: main.implicitWidth+15
    implicitHeight: main.implicitHeight+20
    

    RowLayout {

        id: main        
        anchors.centerIn: parent
        z: 100
        anchors.leftMargin: 20

        AudioBar {
            node: Pipewire.defaultAudioSink
            sliderHeight: 250
            sliderWidth: 30
        }

        Behavior on opacity {
            NumberAnimation {
            duration: 100
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