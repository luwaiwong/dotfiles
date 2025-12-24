pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

/**

Provides access to some Hyprland data not available in Quickshell.Hyprland.*/
Singleton {
    id: root
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
    property var monitors: []
    property var specialWorkspaces: []  // List of active special workspaces
    property string activeSpecialWorkspace: ""  // Currently active special workspace name

    function updateWindowList() {
        getClients.running = true;
        getMonitors.running = true;
        getWorkspaces.running = true;
    }

    Component.onCompleted: {
        updateWindowList();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // Handle activespecialv2 event to track special workspace visibility
            // event.data format: "id,name" where name includes "special:" prefix, or "0," when closing
            if (event.name === "activespecialv2") {
                const parts = event.data.split(",");
                const wsName = parts[1] || "";
                // Remove "special:" prefix if present
                root.activeSpecialWorkspace = wsName.startsWith("special:") ? wsName.substring(8) : wsName;
                getWorkspaces.running = true;
                return;
            }
            // Filter out redundant old v1 events for the same thing
            if (event.name in ["activewindow", "focusedmon", "monitoradded", "createworkspace", "destroyworkspace", "moveworkspace", "activespecial", "movewindow", "windowtitle"])
                return;
            root.updateWindowList();
        }
    }

    Process {
        id: getClients
        command: ["bash", "-c", "hyprctl clients -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                root.windowList = JSON.parse(data);
                let tempWinByAddress = {};
                for (var i = 0; i < root.windowList.length; ++i) {
                    var win = root.windowList[i];
                    tempWinByAddress[win.address] = win;
                }
                root.windowByAddress = tempWinByAddress;
                root.addresses = root.windowList.map(win => win.address);
            }
        }
    }
    Process {
        id: getMonitors
        command: ["bash", "-c", "hyprctl monitors -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                root.monitors = JSON.parse(data);
            }
        }
    }

    Process {
        id: getWorkspaces
        command: ["bash", "-c", "hyprctl workspaces -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                const allWorkspaces = JSON.parse(data);
                // Special workspaces have negative IDs
                root.specialWorkspaces = allWorkspaces.filter(ws => ws.id < 0);
            }
        }
    }
}
