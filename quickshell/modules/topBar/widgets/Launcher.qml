import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "root:/utils"
import "root:/"

FocusScope {
    id: launcher
    required property var barState

    property bool enabled: barState.isLauncherOpen
    property var results: AppLauncher.search(barState.searchQuery, 8)

    opacity: enabled ? 1 : 0
    z: enabled ? 100 : 0
    focus: enabled

    implicitWidth: 320
    implicitHeight: enabled ? contentColumn.implicitHeight + 20 : 40

    // Block clicks from propagating to click-outside overlay
    MouseArea {
        anchors.fill: parent
        visible: launcher.enabled
        onClicked: {} // Absorb clicks
    }

    ColumnLayout {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 8

        // Search Input
        Rectangle {
            id: searchBox
            Layout.preferredWidth: 300
            Layout.preferredHeight: 36
            color: "#2e3440"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Search icon
                Text {
                    text: ""
                    color: "#4c566a"
                    font.pixelSize: 14
                    font.family: Style.iconFontFamily
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#eceff4"
                    font.pixelSize: 14
                    font.family: Style.fontFamily
                    focus: true
                    placeholderText: "Search applications..."
                    placeholderTextColor: "#4c566a"
                    background: Item {}

                    onTextChanged: launcher.barState.setSearchQuery(text)

                    // Focus when launcher opens
                    Connections {
                        target: launcher.barState
                        function onIsLauncherOpenChanged() {
                            if (launcher.barState.isLauncherOpen) {
                                searchInput.text = ""
                                focusTimer.start()
                            }
                        }
                    }

                    Timer {
                        id: focusTimer
                        interval: 100
                        onTriggered: searchInput.forceActiveFocus()
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            launcher.barState.closeLauncher()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            launcher.barState.selectNext(launcher.results.length)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            launcher.barState.selectPrevious()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (launcher.results.length > 0) {
                                AppLauncher.launch(launcher.results[launcher.barState.selectedIndex])
                                launcher.barState.closeLauncher()
                            }
                            event.accepted = true
                        }
                    }
                }
            }
        }

        // Results List
        Rectangle {
            id: resultsList
            Layout.preferredWidth: 300
            Layout.preferredHeight: resultsColumn.implicitHeight + 16
            color: "#2e3440"
            radius: 8
            visible: launcher.results.length > 0 && launcher.enabled

            ColumnLayout {
                id: resultsColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Repeater {
                    model: launcher.results

                    Rectangle {
                        id: resultItem
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: index === launcher.barState.selectedIndex ? "#3b4252" : "transparent"
                        radius: 6

                        required property var modelData
                        required property int index

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: launcher.barState.selectedIndex = resultItem.index
                            onClicked: {
                                AppLauncher.launch(resultItem.modelData)
                                launcher.barState.closeLauncher()
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 10

                            // App Icon
                            IconImage {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                source: Quickshell.iconPath(resultItem.modelData.icon, "application-x-executable")
                            }

                            // App Name
                            Text {
                                Layout.fillWidth: true
                                text: resultItem.modelData.name
                                color: "#eceff4"
                                font.pixelSize: 13
                                font.family: Style.fontFamily
                                elide: Text.ElideRight
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
