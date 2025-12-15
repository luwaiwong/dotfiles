// modules/bottomBar/Background.qml
import QtQuick 2.15
import QtQuick.Shapes 1.15
import Qt5Compat.GraphicalEffects
import "root:"

Shape {
    id: root

    // Properties to be set by the parent (Bar.qml)
    property real barWidth
    property real barHeight
    property real bottomMargin
    property alias barColor: customBarPath.fillColor

    property real bottomCurveOffset: 0
    readonly property real rounding: Style.radius // Rounding radius: 15
    readonly property real realHeight: root.height - bottomCurveOffset
    readonly property bool flatten: (realHeight) < rounding * 2
    readonly property real roundingY: flatten ? (realHeight) / 2 : rounding

    property real margin: 10 // Gives extra margin for bounce animation

    anchors.bottomMargin: -margin + bottomMargin
    width: barWidth
    height: barHeight

    ShapePath {
        id: customBarPath
        strokeWidth: -1 // No stroke
        fillColor: "white" // Default color, will be overridden by barColor alias

        // Start at bottom left, just after the outer corner arc
        startX: 0
        startY: root.height - root.bottomCurveOffset - root.margin

        // Draw the path counter-clockwise from bottom left to bottom right

        // Left edge going up
        PathLine {
            x: 0
            y: root.roundingY
        }

        // Top left corner arc (inner curve)
        PathArc {
            x: root.rounding
            y: 0
            radiusX: root.rounding
            radiusY: root.roundingY
        }

        // Top edge going right
        PathLine {
            x: root.width - root.rounding
            y: 0
        }

        // Top right corner arc (inner curve)
        PathArc {
            x: root.width
            y: root.roundingY
            radiusX: root.rounding
            radiusY: root.roundingY
        }

        // Right edge going down
        PathLine {
            x: root.width
            y: root.height - root.bottomCurveOffset - root.margin
        }

        // Bottom right outer corner arc
        PathArc {
            x: root.width - root.rounding
            y: root.height - root.bottomCurveOffset - root.margin + root.roundingY
            radiusX: root.rounding
            radiusY: root.roundingY
            direction: PathArc.Clockwise
        }

        // Bottom edge going left
        PathLine {
            x: root.rounding
            y: root.height - root.bottomCurveOffset - root.margin + root.roundingY
        }

        // Bottom left outer corner arc
        PathArc {
            x: 0
            y: root.height - root.bottomCurveOffset - root.margin
            radiusX: root.rounding
            radiusY: root.roundingY
            direction: PathArc.Clockwise
        }
    }
}
