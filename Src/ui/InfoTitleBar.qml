import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10

Rectangle {
    id: titleBar
    height: 30
    width: parent.width
    color: colorWay.backgroundcolor 
    radius: 15
    clip: true

    Text {
        id: titleText
        text: ""
        font.pixelSize: 20
        color: colorWay.textColor

        anchors {
            top: parent.top
            left:parent.left
            topMargin: 5
            leftMargin: 10
        }
    }

    Rectangle {
        id: closeButtonRect
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            //rightMargin: 2
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
            onClicked: {
                windowRoot.close()
                windowRoot.destroy()
            } 
        }
    
    }

    Rectangle {
        id: maximizeButtonRect
        anchors {
            right: closeButtonRect.left
            bottom: parent.bottom
            top: parent.top
        }

        width: 30
        color: colorWay.backgroundcolor

        Text {
            id: maximizeButtonText
            text: windowRoot.visibility === Window.FullScreen ? "🗗" : "🗖"
            font.pixelSize: 15
            anchors.centerIn: parent
            color: colorWay.textColor
        }

        MouseArea {
            id: mouseArea2
            anchors.fill: parent
            hoverEnabled: true

            onEntered: maximizeButtonRect.color = colorWay.itemColor
            onExited: maximizeButtonRect.color = colorWay.backgroundcolor
            onClicked: windowRoot.visibility === Window.FullScreen ? windowRoot.visibility = Window.Windowed : windowRoot.visibility = Window.FullScreen
        }
    }

    Rectangle {
        id: minimizeButtonRect
        anchors {
            right: maximizeButtonRect.left
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
            id: mouseArea3
            anchors.fill: parent
            hoverEnabled: true

            onEntered: minimizeButtonRect.color = colorWay.itemColor
            onExited: minimizeButtonRect.color = colorWay.backgroundcolor
            onClicked: windowRoot.showMinimized()
        }
    }

    DragHandler {
        onActiveChanged: if (active) windowRoot.startSystemMove()
        target: null // The entire Rectangle acts as the drag area
    }   

    function setTitleText(title) {
        titleText.text = title
    }
}