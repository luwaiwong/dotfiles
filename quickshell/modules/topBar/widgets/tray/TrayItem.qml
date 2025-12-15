pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 18
    implicitHeight: 18
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    // anchors.leftMargin: 10
    // anchors.rightMargin: 10

    onClicked: event => {
        console.log(modelData.id);
        if (event.button === Qt.LeftButton)
            modelData.activate();
        else if (modelData.hasMenu)
            menu.open();
    }

    // TODO custom menu
    QsMenuAnchor {
        id: menu

        menu: root.modelData.menu
        anchor.item: root
        // anchor

    }

    // Clipping image
    Rectangle {
        id: circle
        anchors.fill: parent
        color: "transparent"
        radius: width / 2
        clip: true

        // Optional: antialiased border to smooth edges
        border.width: 0 // set to 1 for a ring
        border.color: "#00000000" // or a visible color

        IconImage {
            id: icon

            source: {
                let icon = root.modelData.icon;
                if (icon.includes("?path=")) {
                    const [name, path] = icon.split("?path=");
                    icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                }
                return icon;
            }
            asynchronous: true
            anchors.fill: parent
            anchors.centerIn: parent

            smooth: true
            mipmap: true
        }
    }
}
