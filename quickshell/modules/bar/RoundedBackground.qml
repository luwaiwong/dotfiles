// modules/bar/widgets/BarBackgroundShape.qml
import QtQuick 2.15
import QtQuick.Shapes 1.15
import Qt5Compat.GraphicalEffects
import "root:"

Shape {
    id: root

    // Properties to be set by the parent (Bar.qml)
    property real barWidth
    property real barHeight
    property real topMargin
    property alias barColor: customBarPath.fillColor

    property real topCurveOffset: 0
    readonly property real rounding: Style.radius // Example rounding value
    readonly property real realHeight: root.height - topCurveOffset
    readonly property bool flatten: (realHeight) < rounding * 2
    readonly property real roundingY: flatten ? (realHeight) / 2 : rounding
    
    
    property real margin: 10 // Gives extra margin for bounce animation
    
    anchors.topMargin: -margin+topMargin
    width: barWidth
    height: barHeight

    ShapePath {
        
        id: customBarPath
        strokeWidth: -1 // No stroke
        fillColor: "white" // Default color, will be overridden by barColor alias
        startX: -root.rounding
        startY: root.topCurveOffset+root.margin
        // Path definition, using 'root' for dimensions as this ShapePath is its direct child
        // and 'rounding' and 'roundingY' from the outer Shape (root)
        
        PathArc {
            relativeX: root.rounding
            relativeY: root.roundingY
            radiusX: root.rounding
            radiusY: Math.min(root.rounding, root.realHeight)
        }

        PathLine {
            relativeX: 0
            relativeY: root.realHeight - root.roundingY * 2
        }

        PathArc {
            relativeX: root.rounding
            relativeY: root.roundingY
            radiusX: root.rounding
            radiusY: Math.min(root.rounding, root.realHeight)
            direction: PathArc.Counterclockwise
        }

        PathLine {
            relativeX: root.width - root.rounding * 2
            relativeY: 0
        }

        PathArc {
            relativeX: root.rounding
            relativeY: -root.roundingY
            radiusX: root.rounding
            radiusY: Math.min(root.rounding, root.realHeight)
            direction: PathArc.Counterclockwise
        }

        PathLine {
            relativeX: 0
            relativeY: -(root.realHeight - root.roundingY * 2)
        }

        PathArc {
            relativeX: root.rounding
            relativeY: -root.roundingY
            radiusX: root.rounding
            radiusY: Math.min(root.rounding, root.realHeight)
        }
    }
}