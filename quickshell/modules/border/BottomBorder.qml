import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import QtQuick.Shapes 

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            property var modelData
            screen: modelData
            anchors {
                bottom: true
            }

            implicitHeight: 20
            implicitWidth: modelData.width
            color: "transparent"

            Shape {
                id: borderShape
                anchors.bottom: parent.bottom
                width: parent.width
                height: 10 // same as your Rectangle's implicitHeight

                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#000000"
                    radius: 13
                    samples: 17
                }

                ShapePath {
                    strokeWidth: 0
                    // strokeColor: "white"
                    fillColor: "black"
                    startX: 0
                    startY: 0

                    // Right line
                    PathLine { x: 0; y: borderShape.height }
                    PathLine { x: borderShape.width; y: borderShape.height}
                    // Corner

                    PathLine { x: borderShape.width; y: borderShape.height-10}
                    PathLine { x: borderShape.width-5; y: borderShape.height-10}
                    PathArc {
                        x: borderShape.width-10
                        y: borderShape.height-5
                        radiusX: 5
                        radiusY: 5
                        direction: PathArc.Clockwise
                    }
                    // Bottom Line
                    PathLine { x: 10; y: borderShape.height-5 }
                    // Corner
                    PathArc {
                        x: 5
                        y: borderShape.height-10
                        radiusX: 5
                        radiusY: 5
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: borderShape.height-10 }
                    // Leftline
                    PathLine { x: 0; y: borderShape.height}
                }
            }
        }
    }
}