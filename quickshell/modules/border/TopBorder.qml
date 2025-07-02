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
                top: true
            }

            implicitHeight: 40
            implicitWidth: modelData.width
            color: "transparent"

            Shape {
                id: borderShape
                width: parent.width
                height: 10 // same as your Rectangle's implicitHeight

                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#000000"
                    radius: 10
                    samples: 17
                }

                ShapePath {
                    strokeWidth: 0
                    // strokeColor: "white"
                    fillColor: "black"
                    startX: 0
                    startY: 0

                    // Right line
                    PathLine { x: borderShape.width; y: 0 }
                    PathLine { x: borderShape.width; y: 10}
                    // Corner

                    PathLine { x: borderShape.width-5; y: 10}
                    PathArc {
                        x: borderShape.width-10
                        y: 5
                        radiusX: 5
                        radiusY: 5
                        direction: PathArc.Counterclockwise
                    }
                    // Bottom Line
                    PathLine { x: 10; y: 5 }
                    // Corner
                    PathArc {
                        x: 5
                        y: 10
                        radiusX: 5
                        radiusY: 5
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: 0; y: 10 }
                    // Leftline
                    PathLine { x: 0; y: 0}
                }
            }
        }
    }
}