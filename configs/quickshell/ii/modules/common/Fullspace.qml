pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.services
import qs.modules.common.models.hyprland
import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: fullspace

    function load() {
        console.log("[Fullspace] Initialized");
    }

    HyprlandConfigOption { id: defaultGapsIn; key: "general:gaps_in" }
    HyprlandConfigOption { id: defaultGapsOut; key: "general:gaps_out" }

    property var fullspaceState: ({})

    function applyFullspace(id) {
        Quickshell.execDetached([
            "hyprctl", "-r", "keyword", "workspace",
            `${id},gapsin:0,gapsout:0,rounding:false,decorate:false,border:false`
        ])
        GlobalStates.workspacesWithBarClosed[id] = true;
        fullspace.fullspaceState[id] = true;
    }

    function revertWorkspace(id) {
        Quickshell.execDetached([
            "hyprctl", "-r", "keyword", "workspace",
            `${id},gapsin:${defaultGapsIn.value},gapsout:${defaultGapsOut.value},rounding:true,decorate:true,border:true`
        ])
        delete GlobalStates.workspacesWithBarClosed[id];
        delete fullspace.fullspaceState[id];
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "closewindow") {
                const activeFullspaces = Object.keys(fullspace.fullspaceState);
                
                activeFullspaces.forEach(wsId => {
                    const id = parseInt(wsId)
                    const clients = HyprlandData.hyprlandClientsForWorkspace(id);
                    
                    if (!clients || clients.length <= 1) { // need check <= 1 because the window being closed is counted
                        console.log(`[Fullspace] Last window closed on workspace ${wsId}. Reverting rules.`);
                        fullspace.revertWorkspace(wsId);
                    }
                });
            }
        }
    }

    GlobalShortcut {
        name: "fullspaceToggle"
        description: "toggle fullspace"

        onPressed: {
            const id = HyprlandData.activeWorkspace?.id;
            if (!id) return;

            if (fullspace.fullspaceState[id]) {
                fullspace.revertWorkspace(id);
            } else {
                fullspace.applyFullspace(id);
            }
        }
    }
}
