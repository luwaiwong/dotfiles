// CustomVerticalSlider.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "root:/"

Slider {
    id: root
    // Set orientation to vertical
    orientation: Qt.Vertical

    // Default range for clarity, these are overridden by the parent if set.
    from: 0.0
    to: 1.0
    value: 0.5
    stepSize: 0.01

    property string backgroundColor: "#2e3440"
    property string grooveColor: "#2e3440"
    property string grooveActiveColor: "#3b4252"
    property string handleColor: "#4c566a" // Tomato red for example
    property string handleHoverColor: "#5e81ac"
    property string textColor: "#eceff4"
    property real grooveMargin: 8
    property real handleSize: root.width-grooveMargin/2
    property real handleHoverSize: root.width
    property real textSize: 12

    property real radius: 8
    property string icon: ""

    // Custom background for the slider groove
    background: Rectangle {
        id: groove
        // The groove should take the full width and height of the Slider itself
        // as determined by the layout, and its dimensions are handled by the Slider.
        width: root.width-root.grooveMargin
        implicitHeight: root.height
        color: root.grooveColor
        radius: root.radius // Rounded groove
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle{
            anchors.left: parent.left
            anchors.right: parent.right

            y: root.handle.y
            implicitHeight: parent.height - y

            color: root.grooveActiveColor

            radius: root.radius // Rounded groove
        }
    }

    // Custom handle
    handle: Rectangle {
        id: handleRect
        // IMPORTANT: Do NOT manually set x or y here.
        // The Slider control will automatically position this handle delegate
        // based on its 'value' and 'orientation'.
        // We only define its size using implicitWidth/Height.
        implicitWidth: root.pressed ? root.handleHoverSize : root.handleSize
        implicitHeight:root.pressed ? root.handleHoverSize : root.handleSize
        radius: width/2// Rounded groove
        color: root.handleColor

        property bool moving
        property bool hovering

        y: root.visualPosition * (root.availableHeight-height/2+2)
        anchors.horizontalCenter: root.horizontalCenter

        // Animation for size change on hover
        width: handleRect.implicitWidth // Bind actual width to implicit width for animation
        height: handleRect.implicitHeight // Bind actual height to implicit height for animation
        Behavior on width { NumberAnimation { duration: 100 } }
        Behavior on height { NumberAnimation { duration: 100 } }

        // Change size and color on hover
        MouseArea {
            // Fill the handleRect to capture hover events{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: event => event.accepted = false
            hoverEnabled: true
            onEntered: {
                handleRect.hovering = true
                handleRect.implicitWidth = root.handleHoverSize
                handleRect.implicitHeight = root.handleHoverSize
                handleRect.color = root.handleHoverColor
            }
            onExited: {
                handleRect.hovering
                handleRect.implicitWidth = root.handleSize
                handleRect.implicitHeight = root.handleSize
                handleRect.color = root.handleColor
            }
        }

        // Value label that appears when moved
        Text {
            id: valueLabel
            // Reference the 'root' (which is the Slider itself) for its value.
            text: Math.round(root.value * 100).toString() 
            // text: "BRUH"
            font.pixelSize: root.textSize
            color: root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            // anchors.verticalCenterOffset: 1
            // anchors.horizontalCenterOffset: -1
            z: 100

            opacity: root.pressed ?1: 0 // Start invisible

            // Show only when the slider is pressed (being moved)
            // visible: handleRect.moving // 'root' refers to the Slider component

            scale: root.pressed? 1: 0


            Behavior on opacity { NumberAnimation { duration: 50 } }
            Behavior on scale { NumberAnimation { duration: 50 } }

            // Animate opacity based on root.pressed state
            // states: [
            //     State {
            //         when: root.pressed
            //         PropertyChanges { target: valueLabel; opacity: 1 }
            //     },
            //     State {
            //         when: !root.pressed
            //         PropertyChanges { target: valueLabel; opacity: 0 }
            //     }
            // ]
        }

        // Value label that appears when moved
        Text {
            // Reference the 'root' (which is the Slider itself) for its value.
            text: root.icon
            // text: "BRUH"
            font.pixelSize: root.textSize
            color: root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            // anchors.verticalCenterOffset: 1
            anchors.horizontalCenterOffset: -root.textSize/5
            z: 100

            opacity: root.pressed ?0: 1 // Start invisible

            // Show only when the slider is pressed (being moved)
            // visible: handleRect.moving // 'root' refers to the Slider component

            scale: root.pressed? 0: 1


            Behavior on opacity { NumberAnimation { duration: 50 } }
            Behavior on scale { NumberAnimation { duration: 50 } }
        }
    }
}