import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "widgets" // Assuming AudioBar.qml and BrightnessBar.qml are in this directory
import Quickshell.Hyprland // Required to get the focused monitor from Hyprland


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

        // Determine the target monitor for brightness control
        // This logic is copied from your BrightnessBar, but it's good to define
        // it once here if both the bar and the slider need it.
        // Or, you can just pass BrightnessSingleton directly to BrightnessBar
        // and let BrightnessBar figure out its targetMonitor.
        // For clarity, I'll pass a specific monitor object.
        // property var brightnessTargetMonitor: {
        //     const focusedScreenName = Hyprland.focusedMonitor.name;
        //     return BrightnessSingleton.monitors.find(m => m.screen.name === focusedScreenName)
        //            || BrightnessSingleton.monitors[0]; // Fallback to the first monitor
        // }

        BrightnessBar {
            // Pass the specific BrightnessMonitor object to your BrightnessBar
            // Note: Your BrightnessBar.qml needs a 'required property var targetMonitor'
            // instead of 'required property PwNode node;'
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