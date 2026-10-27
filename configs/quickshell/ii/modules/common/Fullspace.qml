pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: fullspace

    function load () {} // For forcing initialization

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

    /**
     * Reverts every fullspace workspace that has no mapped windows left
     * (e.g. the last window was closed or moved to another workspace).
     * Judged on the client list snapshot in HyprlandData.
     */
    function revertEmptyFullspaces() {
        for (const id of Object.keys(fullspace.fullspaceState).map(Number)) {
            const empty = !HyprlandData.windowList?.some(win => win.mapped && win.workspace?.id === id);
            if (empty) {
                console.log(`[Fullspace] Last window gone from workspace ${id}. Reverting rules.`);
                fullspace.revertFullspace(id);
            }
        }
    }

    /**
     * HyprlandData refreshes its window list on every Hyprland event that can
     * empty a workspace (closewindow, movewindow, ...). Hooking the check to
     * the data becoming fresh avoids racing a raw event with a still stale
     * hyprctl snapshot.
     */
    Connections {
        target: HyprlandData

        function onWindowListChanged() {
            fullspace.revertEmptyFullspaces();
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
