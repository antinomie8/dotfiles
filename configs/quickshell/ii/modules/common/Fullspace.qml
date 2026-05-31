pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: fullspace

    property var fullspaceState: ({})

    function applyFullspace(id) {
        Quickshell.execDetached([
            "hyprctl", "eval",
            `hl.workspace_rule({
                workspace = ${id},
                gaps_in = 0,
                gaps_out = 0,
                no_rounding = true,
                decorate = false,
                border = false,
            })`,
        ])
        GlobalStates.workspacesWithBarClosed[id] = true;
        fullspace.fullspaceState[id] = true;
    }

    function revertFullspace(id) {
        Quickshell.execDetached([
            "hyprctl", "eval",
            `hl.workspace_rule({
                workspace = ${id},
                gaps_in = hl.get_config("general.gaps_in"),
                gaps_out = hl.get_config("general.gaps_out"),
                no_rounding = false,
                decorate = true,
                border = true,
            })`
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
                        fullspace.revertFullspace(wsId);
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
                fullspace.revertFullspace(id);
            } else {
                fullspace.applyFullspace(id);
            }
        }
    }
}
