pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string baseDir: `${Quickshell.env("HOME")}/Mathématiques/Polys`
    property bool sloppySearch: Config.options?.search.sloppy ?? false
    property real scoreThreshold: 0.2
    property list<var> entries: []
    readonly property var preparedEntries: entries.map(pdf => ({
        name: Fuzzy.prepare(`${pdf.relativePath} ${pdf.name}`),
        entry: pdf
    }))

    function fuzzyQuery(search: string): var {
        if (search.trim() === "")
            return entries;

        if (root.sloppySearch) {
            const results = entries.map(pdf => ({
                entry: pdf,
                score: Levendist.computeTextMatchScore(`${pdf.relativePath} ${pdf.name}`.toLowerCase(), search.toLowerCase())
            })).filter(item => item.score > root.scoreThreshold)
                .sort((a, b) => b.score - a.score)
            return results.map(item => item.entry)
        }

        return Fuzzy.go(search, preparedEntries, {
            all: true,
            key: "name"
        }).map(r => r.obj.entry);
    }

    function refresh() {
        pdfProc.buffer = [];
        pdfProc.running = true;
    }

    Process {
        id: pdfProc
        property list<string> buffer: []
        command: ["bash", "-c", "base_dir=\"$HOME/Mathématiques/Polys\"; [ ! -d \"$base_dir\" ] || fd --base-directory \"$base_dir\" -tf -e pdf . --strip-cwd-prefix"]

        stdout: SplitParser {
            onRead: line => {
                if (line.trim().length > 0)
                    pdfProc.buffer.push(line.trim());
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.entries = pdfProc.buffer.map(relativePath => {
                    const parts = relativePath.split("/");
                    const fileName = parts[parts.length - 1] || relativePath;
                    const directory = parts.length > 1 ? parts.slice(0, -1).join("/") : "";
                    return {
                        relativePath: relativePath,
                        absolutePath: `${root.baseDir}/${relativePath}`,
                        name: fileName.replace(/\.pdf$/i, ""),
                        directory: directory
                    };
                });
            } else {
                root.entries = [];
                console.error("[PdfSearch] Failed to refresh with code", exitCode, "and status", exitStatus);
            }
        }

        Component.onCompleted: root.refresh()
    }
}
