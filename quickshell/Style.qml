pragma Singleton
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

Singleton {
    readonly property real borderWidth: 0
    readonly property real radius: 15

    // Font configuration
    // Set to empty string ("") to use system default font
    readonly property string fontFamily: ""
    readonly property string monoFontFamily: "" // For monospace text (clock, date, etc.)
    readonly property string iconFontFamily: "" // For icon/symbol fonts
}
