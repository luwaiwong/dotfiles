import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland

import QtQuick.Shapes 
pragma ComponentBehavior: Bound
import "../../"

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }


            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: 0
                y: 0
                width: 10000
                height: 10000
                intersection: Intersection.Xor

                regions: regions.instances
            }
            property real borderWidth: Style.borderWidth
            property real radius: Style.radius

            implicitHeight: borderWidth+radius
            implicitWidth: modelData.width
            color: "transparent"

            Shape {
                id: borderShape
                width: parent.width
                height: root.implicitHeight // same as your Rectangle's implicitHeight

                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#000000"
                    radius: 13
                    samples: 17
                }

                z: 0    
                ShapePath {
                    strokeWidth: 0
                    // strokeColor: "white"
                    fillColor: "black"
                    startX: 0
                    startY: 0

                    // Right line
                    PathLine { x: borderShape.width; y: 0 }
                    PathLine { x: borderShape.width; y: root.borderWidth+root.radius}
                    // Corner

                    PathLine { x: borderShape.width-root.borderWidth; y: root.borderWidth+root.radius}
                    PathArc {
                        x: borderShape.width-(root.borderWidth+root.radius)
                        y: root.borderWidth
                        radiusX: root.radius
                        radiusY: root.radius
                        direction: PathArc.Counterclockwise
                    }
                    // Bottom Line
                    PathLine { x: root.borderWidth+root.radius; y: root.borderWidth }
                    // Corner
                    PathArc {
                        x: root.borderWidth
                        y: root.borderWidth+root.radius
                        radiusX: root.radius
                        radiusY: root.radius
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: 0; y: root.borderWidth+root.radius }
                    // Leftline
                    PathLine { x: 0; y: 0}
                }
            }
        }
    }
}