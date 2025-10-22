
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import "root:/components/"
import "root:/"
Column {
	required property PwNode node;
    id :root

    property real sliderHeight: 200
    property real sliderWidth: 20

	// bind the node so we can read its properties
	PwObjectTracker { objects: [ node ] }

    spacing: 54

    property string currentVolumeIcon: {
        if (node.audio.muted){
            return "";
        }
        const volume = node.audio.volume;
        if (volume > 0.80) {
            return "";
        } else if (volume > 0.2) {
            return "";
        } else if (volume > 0.0) {
            return "";
        } else {
            return "";
        }
    }
	// 	Label {
	// 		text: {
	// 			// application.name -> description -> name
	// 			const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
	// 			const media = node.properties["media.name"];
	// 			return media != undefined ? `${app} - ${media}` : app;
	// 		}
	// 	}

	// 	Button {
	// 		text: node.audio.muted ? "unmute" : "mute"
	// 		onClicked: node.audio.muted = !node.audio.muted
	// 	}
	// }

	// ColumnLayout {
		// Label {
        //     Layout.alignment: Qt.AlignCenter
		// 	text: `${Math.floor(node.audio.volume * 100)}%`
        //     color: "white"
		// }

        // Integrate the CustomVerticalSlider here
    StyledSlider {
        // Layout properties to make it fill available height
        // Layout.fillHeight: true
        // anchors.centerIn: parent
        Layout.alignment: Qt.AlignCenter

        // Bind the custom slider's value to the PwNode's volume
        value: root.node.audio.volume
        // When the custom slider's value changes, update the PwNode's volume
        onValueChanged: {
            root.node.audio.volume = value
            root.node.audio.muted = false
            }

        // onRightClicked: {
        //     node.audio.muted = !node.audio.muted
        //     console.log("bruh")
        // }
        textSize: 14
        radius: Style.radius

        height: root.sliderHeight - sliderWidth/2
        width: root.sliderWidth
        icon: root.currentVolumeIcon
        // Optionally, you can customize its appearance here:
        // backgroundColor: "#333333"
        // grooveColor: "#555555"
        // handleColor: "#FF6347" // Tomato red for example
        // handleHoverColor: "#CD5C5C"
        // textColor: "yellow"
        // handleSize: 18
        // handleHoverSize: 26
    }

    // Image {
    //     Layout.alignment: Qt.AlignCenter
    //     visible: source != ""
    //     source: {
    //         const icon = node.properties["application.icon-name"] ?? "audio-symbolic";
    //         return `image://icon/${icon}`;
    //     }

    //     sourceSize.width: sliderWidth/2
    //     sourceSize.height: sliderWidth/2
    // }
	// }
}