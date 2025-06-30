// modules/bar/widgets/BarBackgroundShape.qml
import QtQuick 2.15
import QtQuick.Shapes 1.15

Shape {
    id: root

    // Properties to be set by the parent (Bar.qml)
    property alias barWidth: root.width
    property alias barHeight: root.height
    property alias barColor: customBarPath.fillColor

    property real topCurveOffset: 0
    readonly property real rounding: 20 // Example rounding value
    readonly property real realHeight: root.height - topCurveOffset
    readonly property bool flatten: (realHeight) < rounding * 2
    readonly property real roundingY: flatten ? (realHeight) / 2 : rounding
    
    // Rectangle {
    //     id: topOffsetRect
    //     x: 0
    //     y: 0
    //     anchors.horizontalCenter: root.horizontalCenter // Center the rectangle in the Shape
    //     width: root.width+root.rounding*2// Extend the rectangle to cover the full width
    //     height: root.topCurveOffset
    //     color: root.barColor // The black color for the offset area
    //     visible: root.topCurveOffset > 0 // Only visible when there's an offset
    // }
    ShapePath {
        id: customBarPath
        strokeWidth: -1 // No stroke
        fillColor: "white" // Default color, will be overridden by barColor alias
        startX: -root.rounding
        startY: root.topCurveOffset
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