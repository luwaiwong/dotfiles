// modules/bar/widgets/BarBackgroundShapeRotated.qml
import QtQuick 2.15
import QtQuick.Shapes 1.15
import Qt5Compat.GraphicalEffects
import "root:"

Shape {
    id: root

    // Properties to be set by the parent (Bar.qml)
    property real barWidth
    property real barHeight
    property real leftMargin
    property alias barColor: customBarPath.fillColor

    property real curveOffset: 0
    readonly property real rounding: Style.radius
    readonly property real realWidth: root.width - curveOffset
    readonly property bool flatten: (realWidth) < rounding * 2
    readonly property real roundingX: flatten ? (realWidth) / 2 : rounding

    property real margin // Gives extra margin for bounce animation
    
    anchors.leftMargin: leftMargin-margin

    width: barWidth
    height: barHeight

    ShapePath {
        id: customBarPath
        strokeWidth: -1 // No stroke
        fillColor: "white" // Default color, will be overridden by barColor alias
        startX: root.curveOffset+root.margin
        startY: -root.rounding
        // Path definition, using 'root' for dimensions as this ShapePath is its direct child
        // and 'rounding' and 'roundingX' from the outer Shape (root)

        PathArc {
            relativeX: root.roundingX 
            relativeY: root.rounding
            radiusX: Math.min(root.rounding, root.realWidth)
            radiusY: root.rounding
            direction: PathArc.Counterclockwise
            
        }

        PathLine {
            relativeX: (root.realWidth - root.roundingX * 2)
            relativeY: 0
        }

        PathArc {
            relativeX: root.roundingX
            relativeY: root.rounding
            radiusX: Math.min(root.rounding, root.realWidth)
            radiusY: root.rounding
            direction: PathArc.Clockwise
        }

        PathLine {
            relativeX: 0
            relativeY: root.height - root.rounding * 2
        }

        PathArc {
            relativeX: -root.roundingX
            relativeY: root.rounding
            radiusX: Math.min(root.rounding, root.realWidth)
            radiusY: root.rounding
            direction: PathArc.Clockwise
        }

        PathLine {
            relativeX: -(root.realWidth - root.roundingX * 2)
            relativeY: 0
        }

        PathArc {
            relativeX: -root.roundingX
            relativeY: root.rounding
            radiusX: Math.min(root.rounding, root.realWidth)
            radiusY: root.rounding
            direction: PathArc.Counterclockwise
        }
    }
}