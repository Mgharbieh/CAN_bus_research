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
        color: mouseArea.containsMouse ? "#FF0000" : colorWay.backgroundcolor

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
            color: mouseArea.containsMouse ? "#FFFFFF" : colorWay.textColor
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
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
        color: mouseArea2.containsMouse ? colorWay.backgroundcolor2 : colorWay.backgroundcolor

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
            onClicked: root.showMinimized()
        }
}

    DragHandler {
        onActiveChanged: if (active) root.startSystemMove()
        target: null // The entire Rectangle acts as the drag area
    }   

}