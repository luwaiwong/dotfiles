// Your main QML file (e.g., in your project root or wherever PanelWindow is defined)
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "widgets"

Scope{
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id : root
            property var modelData
            screen: modelData
            anchors {
                top: true
            }

            // --- THE FIX STARTS HERE ---

            // This single property will drive both the bar's position and its topCurveOffset
            property real effectiveVerticalOffset: -  (barShape.implicitHeight - 10) // 0 means fully visible, negative means moving up

            // Behavior for the new effectiveVerticalOffset property
            Behavior on effectiveVerticalOffset {
                NumberAnimation {
                    // Use a single, consistent duration for the entire show/hide animation
                    duration: 200 // Adjust this for your desired speed
                    easing.type: Easing.OutCubic // A smoother easing curve for movement
                }
            }

            // --- THE FIX ENDS HERE ---

            property bool isShown: false // Initially hidden

            color: "transparent"
            implicitHeight: 40 // Total height of the PanelWindow
            implicitWidth: modelData.width/2

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: root.showBar();
                onExited: root.startHideTimer();
                z: 100
                propagateComposedEvents: true // Ensure events propagate to children
                
                BarBackgroundShape {
                    id: barShape
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    // --- THE FIX STARTS HERE ---

                    // Drive the bar's position directly from effectiveVerticalOffset
                    // When effectiveVerticalOffset is 0, bar is at top.
                    // When effectiveVerticalOffset is negative, bar moves up.
                    anchors.topMargin: root.effectiveVerticalOffset

                    // Drive the BarBackgroundShape's internal topCurveOffset
                    // When effectiveVerticalOffset goes from 0 to -X, topCurveOffset goes from 0 to X
                    // This makes the black rectangle grow downwards as the bar moves up,
                    // creating a smooth "disappearing" effect of the curved top.
                    topCurveOffset: Math.max(0, -root.effectiveVerticalOffset)

                    // --- THE FIX ENDS HERE ---

                    barWidth: childrenRect.width + 40
                    barHeight: 40 // Keep this constant, the topCurveOffset handles the visual change
                    barColor: "black"

                    // We no longer need separate Behaviors on topCurveOffset or anchors.topMargin here,
                    // as their values are now directly bound to and driven by effectiveVerticalOffset.
                    // The single Behavior on effectiveVerticalOffset handles all the animation.

                    BarContent {
                        root: root
                    }
                }
            }



            // --- Auto-hide Timer ---
            Timer {
                id: hideBarTimer
                interval: 800
                repeat: false
                onTriggered: root.hideBar()
            }

            // --- Show/Hide Functions ---
            function showBar() {
                if (root.isShown) return;
                root.isShown = true;
                root.effectiveVerticalOffset = 0; // Set to 0 to show the bar (animates via Behavior)
                hideBarTimer.stop();
            }

            function hideBar() {
                if (!root.isShown) return;
                root.isShown = false;
        
                var hideAmount = barShape.implicitHeight - 10; // Adjust '10' for how much you want to remain visible
                root.effectiveVerticalOffset = -hideAmount; // Animate to this negative value (animates via Behavior)
            }

            function startHideTimer() {
                hideBarTimer.restart();
            }
        }
    }
}