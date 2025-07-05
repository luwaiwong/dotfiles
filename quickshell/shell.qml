//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import "modules/bar"
import "modules/border"
import "modules/leftdrawer"
import "modules/rightdrawer"
import "modules/"


ShellRoot {
    ReloadPopup {}
    TopPadding {}
    Border {}
    DynamicBar {}
    RightDrawer {}
    LeftDrawer {}

    // StaticBar {}
}
