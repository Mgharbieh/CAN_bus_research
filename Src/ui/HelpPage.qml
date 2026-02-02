import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

Item {
    property bool viewing: false

    id: helpRoot
    width: parent.width
    height: parent.height
    visible: false

    RectangularShadow {
        anchors.fill: helpPageRect
        offset.x: 5 
        offset.y: 5 
        radius: helpPageRect.radius
        blur: 20 // Shadow softness
        spread: 0 // Shadow size relative to source
        color: "#80000000" // Shadow color with alpha (black, 50% opacity)
        antialiasing: true // Smooth the edges
    }

    Rectangle {
        id: helpPageRect
        /*
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        */
        
        height: parent.height
        width: 0.5 * parent.width
        color: backgroundcolor2
        x: parent.x
        z:3

        Rectangle {
            id: helpTitleBar
            color: accent1color
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 5
            }
            height: 40
            radius: 10

            Rectangle {
                id: closeHelpButton
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    topMargin: -10
                    leftMargin: 5
                }
                width: 50
                height: 40
                radius: 10
                color: "transparent"

                Text {
                    id: closeButtonText
                    anchors.fill: parent
                    text: "←"
                    color: textColor 
                    styleColor: "#FFFFFF"
                    font.pixelSize: 50
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        closeButtonText.color = '#adadad' 
                        //closeButtonText.style = Text.Sunken
                    } 
                    onExited: {
                        closeButtonText.color = textColor 
                        //closeButtonText.style = Text.Normal
                    } 
                    //onClicked: helpRoot.visible = false
                    onClicked: helpPagePressed()
                } 
            }
    
            Rectangle {
                id: contentContainer
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: closeHelpButton.right
                    right: parent.right
                }
                color: "transparent"

                Text {
                    id: helpTitleText
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        margins: 5
                    }
                    text: "Help"
                    color: "#FFFFFF" //change to titleTextColor variable later
                    font.pixelSize: 30
                    fontSizeMode: Text.Fit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Rectangle {
        id: focusEmphasis
        anchors {
            top:parent.top
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }
        color: '#808b8b8b' //save as focusColor
        visible: false
        radius: 15
    }

    PropertyAnimation {
        id: helpPageSlideIn
        target: helpPageRect
        property: "x"
        to: 0
        duration: 200

        onStarted: focusEmphasis.visible = true
        //onFinished: focusEmphasis.visible = true
    }

    PropertyAnimation {
        id: helpPageSlideOut
        target: helpPageRect
        property: "x"
        to: -1 * helpPageRect.width
        duration: 200

        onStarted: focusEmphasis.visible = false
        onFinished: helpRoot.visible = false
    }

    function helpPagePressed() {
        if(viewing === false) {
            helpPageRect.x = -1 * helpPageRect.width
            helpRoot.visible = true
            helpPageSlideIn.running = true
            viewing = true
        } else {
            helpPageSlideOut.running = true
            viewing = false
        }
    }
}