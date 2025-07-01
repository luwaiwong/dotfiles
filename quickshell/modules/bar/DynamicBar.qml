// Your main QML file (e.g., in your project root or wherever PanelWindow is defined)
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "widgets"
import "root:/utils" 

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

            // Show bar when workspace changes
            Connections {
                target: Hyprland
                function onRawEvent(event) { 
                    if (event.name === "workspace") {
                        root.showBar()

                        // Find the biggest window in the current workspace

                        const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == event.data)
                        // Check if there are windows in this workspace
                        if (windowsInThisWorkspace.length > 0) {
                            // ONly if there are windows,  hide the bar
                            root.startLongHideTimer(); 
                        }
                        console.log(windowsInThisWorkspace.length)
                    }
                }
            }
            
            property real effectiveVerticalOffset: -  (barShape.implicitHeight - 8) 

            Behavior on effectiveVerticalOffset {
                NumberAnimation {
                    duration: 200 
                    easing.type: Easing.OutCubic //
                }
            }

            property bool isShown: false // Initially hidden

            color: "transparent"
            implicitHeight: 40 // Total height of the PanelWindow
            implicitWidth: modelData.width/2

            MouseArea {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: barShape.implicitWidth
                height: childrenRect.height
                
                hoverEnabled: true
                    anchors.topMargin: root.effectiveVerticalOffset

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

                    // Drive the BarBackgroundShape's internal topCurveOffset
                    // When effectiveVerticalOffset goes from 0 to -X, topCurveOffset goes from 0 to X
                    // This makes the black rectangle grow downwards as the bar moves up,
                    // creating a smooth "disappearing" effect of the curved top.
                    topCurveOffset: Math.max(0, -root.effectiveVerticalOffset)

                    // --- THE FIX ENDS HERE ---

                    barWidth: barContent.implicitWidth + 40
                    barHeight: 40 // Keep this constant, the topCurveOffset handles the visual change
                    barColor: "black"

                    // We no longer need separate Behaviors on topCurveOffset or anchors.topMargin here,
                    // as their values are now directly bound to and driven by effectiveVerticalOffset.
                    // The single Behavior on effectiveVerticalOffset handles all the animation.

                    BarContent {
                        id: barContent
                        root: root
                    }
                }
            }



            // --- Auto-hide Timer ---
            Timer {
                id: hideBarTimer
                interval: 200
                repeat: false
                onTriggered: root.hideBar()
            }

            Timer {
                id: longHideBarTimer
                interval: 1500
                repeat: false
                onTriggered: root.hideBar()
            }

            // --- Show/Hide Functions ---
            function showBar() {
                hideBarTimer.stop();
                longHideBarTimer.stop();
                if (root.isShown) return;
                root.isShown = true;
                root.effectiveVerticalOffset = 0; // Set to 0 to show the bar (animates via Behavior)
            }

            function hideBar() {
                if (!root.isShown) return;
                root.isShown = false;
        
                var hideAmount = barShape.implicitHeight - 8; // Adjust '10' for how much you want to remain visible
                root.effectiveVerticalOffset = -hideAmount; // Animate to this negative value (animates via Behavior)
            }

            function startHideTimer() {
                hideBarTimer.restart();
            }

            function startLongHideTimer() {
                longHideBarTimer.restart();
            }
        }
    }
}