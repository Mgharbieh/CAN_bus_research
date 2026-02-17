import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10

Rectangle {
    id: titleBar
    height: 30
    width: parent.width
    color: colorWay.backgroundcolor // Custom color
    radius: 15
    clip: true

    Rectangle {
        id: closeButtonRect
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        width: 30
        radius: 15
        color: colorWay.backgroundcolor

        Rectangle {
            width: parent.radius
            height: parent.radius
            color: parent.color
            anchors {
                left: parent.left
                top: parent.top
            }
        }

        Rectangle {
            width: parent.radius
            height: parent.radius
            color: parent.color
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
        }

        Rectangle {
            width: parent.radius
            height: parent.radius
            color: parent.color
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
        }

        Text {
            id: closeButtonText
            text: "✕"
            font.pixelSize: 20
            anchors.centerIn: parent
            color: colorWay.textColor
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        
            onEntered: { closeButtonRect.color = "#FF0000"; closeButtonText.color = "#FFFFFF" }
            onExited: { closeButtonRect.color = colorWay.backgroundcolor; closeButtonText.color = colorWay.textColor }
            onClicked: root.close()
        }
    }

    Rectangle {
        id: minimizeButtonRect
        anchors {
            right: closeButtonRect.left
            bottom: parent.bottom
            top: parent.top
        }

        width: 30
        color: colorWay.backgroundcolor

        Text {
            id: minimizeButtonText
            text: "—"
            font.pixelSize: 15
            anchors.centerIn: parent
            color: colorWay.textColor
        }

        MouseArea {
            id: mouseArea2
            anchors.fill: parent
            hoverEnabled: true

            onEntered: minimizeButtonRect.color = colorWay.backgroundcolor2
            onExited: minimizeButtonRect.color = colorWay.backgroundcolor
            onClicked: root.showMinimized()
        }
}

    DragHandler {
        onActiveChanged: if (active) root.startSystemMove()
        target: null // The entire Rectangle acts as the drag area
    }   

}