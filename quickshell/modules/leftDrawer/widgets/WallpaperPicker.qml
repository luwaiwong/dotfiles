import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 
import Quickshell.Io 
import Quickshell.Widgets

import Qt5Compat.GraphicalEffects
import "root:/"
// pragma ComponentBehavior: Bound

ClippingRectangle {
    id: root
    width: 300
    height: 350
    color: "#000000"
    radius: Style.radius/2
    clip: true

    property var imagePaths: []
    property int currentIndex: 0
    property real imageMargin: 10
    property string homePath: "" // New property to store the home path
    

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        // padding: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            Layout.leftMargin: root.imageMargin
            Layout.rightMargin: root.imageMargin
            Layout.topMargin: root.imageMargin
            Layout.bottomMargin: root.imageMargin
            radius: Style.radius
            color: "#2e3440"

            layer.enabled: true // Essential to apply effects
            layer.effect: DropShadow {
                color: "#8b000000" // Shadow color (80 is 50% opacity black)
                radius: 20      // Blur radius of the shadow
                // verticalOffset: 3
                samples: 17         // Quality of the blur (higher = smoother, slower)
            }

            Text {
                text: imagePaths.length > 0 ? imagePaths.length+" Wallpapers" : "No images / Loading..."
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.Center
                
                font.pixelSize: 14
                color: "white"

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        openFolder.running = true;
                    }
                }
            }

            MouseArea {
                id: reloadArea
                width: reloadText.width
                height: reloadText.height+10

                cursorShape: Qt.PointingHandCursor
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    loadImages();
                }
                Text {
                    id: reloadText
                    anchors.centerIn: parent

                anchors.horizontalCenterOffset: -10
                    text: "󰑓"
                    font.pixelSize: 20
                    color: "white"
                }
            }
            z: 100
        }
        

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            id: galleryListView
            model: root.imagePaths.length // Model is the count of image paths
            orientation: ListView.Vertical // Explicitly vertical
            spacing: 10 // Space between list items
            // clip: true // Ensure content doesn't draw outside bounds
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 15

            flickableDirection: Flickable.VerticalFlick
            interactive: true
            boundsBehavior: Flickable.DragAndOvershootBounds
            snapMode: ListView.SnapToItem // This helps in snapping to items after flicking
            // flickDeceleration: 0.0001
            maximumFlickVelocity: 10000
            synchronousDrag: false
            z: 0

            delegate: ClippingRectangle {

                property bool hovered: false
                id: image
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: (image.hovered? root.imageMargin: 0)
                anchors.horizontalCenter: parent.horizontalCenter
                // anchors.leftMargin: root.imageMargin/2
                width: galleryListView.width + (image.hovered? 0 : -root.imageMargin)
                height: galleryListView.height / 1.1  + (image.hovered? 0 : -root.imageMargin)
                // color: galleryListView.currentIndex === index ? "gray" : "#333333" 
                color: "transparent"

                radius: Style.radius/2
                clip: true

                Image {
                    id: imageDisplay
                    source: "file://" + root.imagePaths[index]
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {image.hovered = true}
                    onExited: {image.hovered= false}
                    onClicked: {
                        root.setWallpaper(root.imagePaths[index])
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                
            }
        }
    }


    function setWallpaper(value) { 

        // console.log(root.imagePaths[root.currentIndex])
        changeWallpaper.command = [
            "sh", "-c",
            "swww img "+value +" --transition-type grow --transition-duration 1 --transition-fps 60",
        ]
        changeWallpaper.running = true
    }


    Process {
        id: changeWallpaper
        stdout: StdioCollector {
            onStreamFinished: {
                console.log(text)
            }
        }
        
    }


    Process {
        id: openFolder
        command: ["sh", "-c", "nemo ~/pictures/wallpapers"] 
        stdout: StdioCollector {
            onStreamFinished: {
                console.log(text)
            }
        }
        
    }
    // Process to get the HOME directory
    Process {
        id: getHomeProcess
        command: ["sh", "-c", "echo $HOME"] // Execute 'echo $HOME' in a shell
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") {
                    root.homePath = text.trim(); // Store the home path
                    console.log("Detected HOME:", root.homePath);
                    // Once homePath is known, we can load images
                    root.loadImages();
                } else {
                    console.error("Failed to get HOME directory. Stderr:", getHomeProcess.stderr.text);
                }
            }
        }
        stderr: StdioCollector { // Always good to collect stderr
            id: getHomeStderr
        }

        Component.onCompleted: {
            running = true; // Start this process as soon as the component is ready
        }
    }

    Process {
        id: imageListProcess
        // Correct command format: list of strings.
        // Using 'sh -c' to run 'find' command with complex shell features like regex.
        command: [
            "sh",
            root.homePath+"/.config/quickshell/utils/findImages.sh",
        ]

        stdout: StdioCollector {
            id: stdoutCollector
            onStreamFinished: {
                console.log(text)
                var fullOutput = this.text; // Access collected text
                var paths = fullOutput.split('\n').filter(function(path) {
                    return path.trim() !== "";
                });
                root.imagePaths = paths; // Update root's property
                // root.currentIndex = 0; // Reset to first image
                // if (root.imagePaths.length > 0) {
                //     galleryFlickable.contentX = 0; // Flick to first image
                // }
                console.log("Loaded images:", root.imagePaths.length);
                    
            }
        }

        stderr: StdioCollector {
            id: stderrCollector
            onStreamFinished: {
                console.error("Stderr output:", this.text);
            }
        }
    }

    function loadImages() {
        imagePaths = []; // Clear current images
        imageListProcess.running = true; // Start the process
    }

    Component.onCompleted: {
        loadImages();
    }

}