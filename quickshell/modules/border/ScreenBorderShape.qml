// components/ScreenBorderShape.qml
import QtQuick 2.15
import QtQuick.Shapes 1.15
import Qt5Compat.GraphicalEffects // For DropShadow

Shape {
    id: rootBorderShape
    // The parent (PanelWindow) will set these
    property alias borderColor: borderPath.fillColor // This will be the color of the frame
    property alias borderWidth: rootBorderShape.width
    property alias borderHeight: rootBorderShape.height
    property real borderThickness: 5 // This is the thickness of the black frame
    property real cornerRounding: 20 // Radius for the corners of the frame

    // Crucial for the DropShadow to work
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#e1000000" // Your desired shadow color (e.g., semi-transparent black)
        radius: 10
        samples: 17
        // offsetX: 0 // Keep offsets 0 if you want the shadow to be centered on the frame
        // offsetY: 0
    }

    ShapePath {
        id: borderPath
        strokeWidth: 0 // No stroke, we're filling an area
        fillColor: rootBorderShape.borderColor // Fill the defined path with the frame color

        // --- OUTER LOOP: Defines the outermost edge of the frame (around the screen) ---
        // Start top-left (0,0 of this Shape component)
        startX: 0
        startY: rootBorderShape.cornerRounding

        // Move across the top edge
        PathLine { x: rootBorderShape.width; y: rootBorderShape.cornerRounding }
        // Top-right outer corner
        PathArc {
            x: rootBorderShape.width - rootBorderShape.cornerRounding
            y: 0
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Clockwise
        }

        // Move down the right edge
        PathLine { x: rootBorderShape.width; y: rootBorderShape.height - rootBorderShape.cornerRounding }
        // Bottom-right outer corner
        PathArc {
            x: rootBorderShape.width - rootBorderShape.cornerRounding
            y: rootBorderShape.height
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Clockwise
        }

        // Move across the bottom edge
        PathLine { x: rootBorderShape.cornerRounding; y: rootBorderShape.height }
        // Bottom-left outer corner
        PathArc {
            x: 0
            y: rootBorderShape.height - rootBorderShape.cornerRounding
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Clockwise
        }

        // Move up the left edge
        PathLine { x: 0; y: rootBorderShape.cornerRounding }
        // Top-left outer corner (back to start) - Close the outer path by implicitly connecting to startX, startY
        PathArc {
            x: rootBorderShape.cornerRounding
            y: 0
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Clockwise
        }


        // --- INNER LOOP: Defines the transparent "hole" inside the frame ---
        // Crucial: Start the inner path by moving to its first point.
        // The direction of this inner path (Clockwise vs. Counter-Clockwise)
        // relative to the outer path determines the filled region.
        // We typically use Counter-Clockwise for holes when the outer path is Clockwise.

        // Start at the top-left of the inner transparent area
        PathMove {
            x: rootBorderShape.borderThickness + rootBorderShape.cornerRounding
            y: rootBorderShape.borderThickness
        }

        // Move across the top edge (inner edge of the frame)
        PathLine { x: rootBorderShape.width - rootBorderShape.borderThickness - rootBorderShape.cornerRounding; y: rootBorderShape.borderThickness }
        // Top-right inner rounded corner
        PathArc {
            x: rootBorderShape.width - rootBorderShape.borderThickness
            y: rootBorderShape.borderThickness + rootBorderShape.cornerRounding
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Counterclockwise // Important for hole!
        }

        // Move down the right edge
        PathLine { x: rootBorderShape.width - rootBorderShape.borderThickness; y: rootBorderShape.height - rootBorderShape.borderThickness - rootBorderShape.cornerRounding }
        // Bottom-right inner rounded corner
        PathArc {
            x: rootBorderShape.width - rootBorderShape.borderThickness - rootBorderShape.cornerRounding
            y: rootBorderShape.height - rootBorderShape.borderThickness
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Counterclockwise // Important for hole!
        }

        // Move across the bottom edge
        PathLine { x: rootBorderShape.borderThickness + rootBorderShape.cornerRounding; y: rootBorderShape.height - rootBorderShape.borderThickness }
        // Bottom-left inner rounded corner
        PathArc {
            x: rootBorderShape.borderThickness
            y: rootBorderShape.height - rootBorderShape.borderThickness - rootBorderShape.cornerRounding
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Counterclockwise // Important for hole!
        }

        // Move up the left edge
        PathLine { x: rootBorderShape.borderThickness; y: rootBorderShape.borderThickness + rootBorderShape.cornerRounding }
        // Top-left inner rounded corner (back to start of inner path)
        PathArc {
            x: rootBorderShape.borderThickness + rootBorderShape.cornerRounding
            y: rootBorderShape.borderThickness
            radiusX: rootBorderShape.cornerRounding
            radiusY: rootBorderShape.cornerRounding
            direction: PathArc.Counterclockwise // Important for hole!
        }
    }
}