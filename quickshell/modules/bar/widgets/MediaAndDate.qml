// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Mpris
import "root:/utils"

MouseArea {
    id: root
    property bool enabled: true
    property bool showingMedia: false

    opacity: enabled ? 1 : 0
    implicitWidth: (showingMedia ? mediaContent.width : date.width )

    property MprisPlayer player: MprisController.activePlayer
    property string title: root.player ? root.player.trackTitle : ""
    property string albumArtUrl: root.player ? root.player.trackArtUrl : ""

    Connections {
        target: MprisController

        function onActivePlayerChanged() {
            root.player = MprisController.activePlayer
            if (root.player) {
                root.title = root.player.trackTitle
                root.albumArtUrl = root.player.trackArtUrl
                if (root.player.isPlaying) {
                    root.showMedia()
                    timeout.stop()
                } else {
                    timeout.start()
                }
            } else {
                root.title = ""
                root.albumArtUrl = ""
                timeout.start() // No player, show date after timeout
            }
        }

        function onTrackChanged() {
            if (root.player) {
                root.title = root.player.trackTitle
                root.albumArtUrl = root.player.trackArtUrl
                if (root.player.isPlaying) {
                    root.showMedia()
                    timeout.stop()
                } else {
                    timeout.start()
                }
            }
        }

        function onPlaybackStateChanged() {
            if (root.player) {
                if (root.player.isPlaying) {
                    root.showMedia()
                    timeout.stop()
                } else {
                    timeout.start()
                }
            } else {
                timeout.start() // If player becomes null, revert to date
            }
        }
    }

    Row {
        id: mediaContent
        anchors.centerIn: parent
        opacity: root.showingMedia ? 1 : 0
        width: childrenRect.width
        spacing: 10

        // Previous button
        // MouseArea {
        //     id: prevButtonArea
        //     width: 20
        //     height: 20
        //     visible: root.player && root.player.canGoPrevious
        //     onClicked: root.player.previous()
        //     onEntered: prevButtonText.font.pixelSize = 24 // Enlarge on hover
        //     onExited: prevButtonText.font.pixelSize = 20 // Revert on exit
        //     anchors.verticalCenter: parent.verticalCenter
        //     Rectangle {
        //         anchors.fill: parent
        //         color: prevButtonArea.pressed ? "#6272a4" : (prevButtonArea.containsMouse ? "#4c566a" : "transparent") // Hover effect
        //         radius: 3
        //         Text {
        //             id: prevButtonText
        //             anchors.centerIn: parent
        //             text: "󰒮"
        //             color: "#d8dee9"
        //             font.pixelSize: 20 // Default size
        //             Behavior on font.pixelSize {
        //                 NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        //             }
        //         }
        //     }
        // }

        // Previous button
        MouseArea {
            id: prevButton
            width: 25
            height: 25
            visible: root.player && root.player.canGoPrevious
            onClicked: root.player.previous()
            hoverEnabled: true
            onEntered: hovered = true
            onExited: hovered = false 
            anchors.verticalCenter: parent.verticalCenter

            property bool hovered: false
            Rectangle {
                anchors.fill: parent
                // color: nextButton.pressed ? "#nextButton" : (nextButton.hovered ? "#4c566a" : "transparent") // Hover effect
                color: "transparent"
                radius: 20
                Text {
                    id: prevButtonText
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: "#d8dee9"
                    font.pixelSize: prevButton.hovered?25:20 // Default size
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }


        // MouseArea wrapped around the Text component
        MouseArea {
            id: contentTextMouseArea // Give the MouseArea an ID
            width: childrenRect.width // Set width for the MouseArea, which will contain the text
            implicitHeight: contentText.implicitHeight+20 // MouseArea height adapts to text height
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true // Enable hover events if you plan to add them later
            Row {
                anchors.centerIn: parent
                spacing: 8
                Image {
                    id: albumArt
                    width: 20
                    height: 20
                    // anchors.fill: parent // Fill the parent Rectangle

                    source: root.albumArtUrl
                    fillMode: Image.PreserveAspectFit
                    // sourceSize: Qt.size(parent.width, parent.height) // Optional: Hint for loading size
                    visible: root.albumArtUrl !== ""
                    opacity: root.albumArtUrl !== "" && albumArt.status === Image.Ready ? 1 : 0

                    // Fade in/out when image loads or becomes unavailable
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
            
                // The Text component is now a child of the MouseArea
                Text {
                    id: contentText
                    // anchors.fill: parent // Make the text fill the MouseArea
                    text: root.title.length > 24 ? root.title.substring(0, 24) + "..." : root.title
                    color: root.player && root.player.isPlaying? "#a3be8c":"#eceff4"
                    font.pixelSize: 14
                    font.family: "Martian Mono Nerd Font"
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignHCenter // Center text content
                    height: contentHeight
                    anchors.verticalCenter: parent.verticalCenter
                    font.italic: root.player && root.player.isPlaying // Italicize when playing

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Rectangle {
                    //     anchors.fill: parent
                    // }
                }
            }


            // Click handler is on the MouseArea itself
            onClicked: handleTextClick(mouse)

            function handleTextClick(mouseEvent) {
                // if (mouseEvent.button === Qt.RightButton) {
                    if (root.player) {
                        root.player.togglePlaying()
                    }
                // }
            }
        }
        

        // Next button
        MouseArea {
            id: nextButton
            width: 25
            height: 25
            visible: root.player && root.player.canGoNext
            onClicked: root.player.next()
            hoverEnabled: true
            onEntered: hovered = true
            onExited: hovered = false 
            anchors.verticalCenter: parent.verticalCenter

            property bool hovered: false
            Rectangle {
                anchors.fill: parent
                // color: nextButton.pressed ? "#nextButton" : (nextButton.hovered ? "#4c566a" : "transparent") // Hover effect
                color: "transparent"
                radius: 20
                Text {
                    id: nextButtonText
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: "#d8dee9"
                    font.pixelSize: nextButton.hovered?25:20 // Default size
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }

    Date {
        id: date
        enabled: !root.showingMedia
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 30
            easing.type: Easing.OutCubic
        }
    }

    function showDate() {
        root.showingMedia = false
    }

    function showMedia() {
        root.showingMedia = true
    }

    Timer {
        id: timeout
        interval: 10000 // Show media for 10 seconds, then switch back to date
        repeat: false
        onTriggered: root.showDate()
    }

    // Initialize state on component creation
    Component.onCompleted: {
        if (root.player && root.player.isPlaying) {
            root.showMedia()
            timeout.stop()
        } else {
            timeout.start()
        }
    }
}