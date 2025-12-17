pragma Singleton

import "./fuzzysort.js" as Fuzzy
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Sorted list of all desktop applications (filtered to exclude hidden)
    readonly property list<DesktopEntry> appList: Array.from(DesktopEntries.applications.values)
        .filter(app => !app.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    // Prepared names for fuzzy search (cached for performance)
    readonly property var preppedApps: appList.map(app => ({
        name: Fuzzy.prepare(app.name),
        entry: app
    }))

    // Search function returning filtered/sorted results
    function search(query, limit) {
        if (limit === undefined) limit = 8
        if (!query || query.trim() === "") {
            // Return top apps when no query
            return appList.slice(0, limit)
        }

        const results = Fuzzy.go(query, preppedApps, {
            all: false,
            key: "name",
            limit: limit,
            threshold: -10000
        })

        return results.map(r => r.obj.entry)
    }

    // Launch an application
    function launch(app) {
        // Clean exec string by removing field codes (%f, %u, etc.)
        const cleanExec = app.exec
            .replace(/%[fFuUdDnNickvm]/g, "")
            .trim()

        launchProcess.command = ["/bin/sh", "-c", cleanExec]
        launchProcess.running = true
    }

    Process {
        id: launchProcess
        stdout: StdioCollector {}
    }
}
