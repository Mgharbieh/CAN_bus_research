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
        height: parent.height
        width: 0.5 * parent.width
        color: colorWay.backgroundcolor2
        x: parent.x
        radius: 15
        z:3

         Rectangle {
            anchors {
                top: parent.top
                right: parent.right
            }
            width: parent.radius
            height: parent.radius
            color: colorWay.backgroundcolor2
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.radius
            height: parent.radius
            color: colorWay.backgroundcolor2
        }

        Rectangle {
            id: helpTitleBar
            color: colorWay.accent1color
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
                    color: "#FFFFFF" 
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
                        closeButtonText.color = "#FFFFFF" 
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
                    color: colorWay.titleTextColor
                    font.pixelSize: 30
                    fontSizeMode: Text.Fit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Rectangle {
            id: helpPageBody
            anchors {
                top: helpTitleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 4
            }
            color: "transparent"

            Column {
                id: helpColumn
                anchors.fill: parent
                spacing: 4
                topPadding: 5

                Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"

                    Text {
                        id: howToUseTitle
                        anchors.fill: parent
                        text: "How to Use"                        
                        color: colorWay.textColor
                        font.pixelSize: 35
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: howToUseText1.contentHeight
                    color: "transparent"

                    Text {
                        id: dash1
                        anchors {
                            left: parent.left
                            //top: howToUseTitle.bottom
                            leftMargin: 4
                            //topMargin: 4
                        }
                        text: "-"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: howToUseText1
                        anchors {
                            left: dash1.right
                            leftMargin: 2
                            //top: howToUseTitle.bottom
                            //topMargin: 4
                        }
                        width: parent.width - dash1.width
                        text: "Select 'upload file' to open the file browser"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: howToUseText2.contentHeight
                    color: "transparent"

                    Text {
                        id: dash2
                        anchors {
                            left: parent.left
                            //top: howToUseText1.bottom
                            leftMargin: 4
                            //topMargin: 2
                        }
                        text: "-"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: howToUseText2
                        anchors {
                            left: dash2.right
                            leftMargin: 2
                            //top: howToUseText1.bottom
                            //topMargin: 2
                        }
                        width: parent.width - dash2.width
                        text: "Select Arduino (.ino) source code file"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: howToUseText3.contentHeight
                    color: "transparent"

                    Text {
                        id: dash3
                        anchors {
                            left: parent.left
                            //top: howToUseText2.bottom
                            leftMargin: 4
                            //topMargin: 2
                        }
                        text: "-"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: howToUseText3
                        anchors {
                            left: dash3.right
                            leftMargin: 2
                            //top: howToUseText2.bottom
                            //topMargin: 2
                        }
                        width: parent.width - dash3.width
                        text: "Wait for file analysis to complete on the newly appeared card"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: howToUseText4.contentHeight
                    color: "transparent"

                    Text {
                        id: dash4
                        anchors {
                            left: parent.left
                            //top: howToUseText2.bottom
                            leftMargin: 4
                            //topMargin: 2
                        }
                        text: "-"
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: howToUseText4
                        anchors {
                            left: dash4.right
                            leftMargin: 2
                        }
                        width: parent.width - dash4.width
                        text: "Click on the card to view file information and analysis results" 
                        color: colorWay.textColor
                        font.pixelSize: 20
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
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
        color: colorWay.focusColor 
        visible: false
        radius: 15
    }

    PropertyAnimation {
        id: helpPageSlideIn
        target: helpPageRect
        property: "x"
        to: 0
        duration: 150

        onStarted: focusEmphasis.visible = true
    }

    PropertyAnimation {
        id: helpPageSlideOut
        target: helpPageRect
        property: "x"
        to: -1 * helpPageRect.width
        duration: 150

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
            root.focused = true
        }
    }
}