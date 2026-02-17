import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

Item {
    property bool viewing: false

    id: settingsRoot
    width: parent.width
    height: parent.height
    visible: false

    RectangularShadow {
        anchors.fill: settingsPageRect
        offset.x: 5 
        offset.y: 5 
        radius: settingsPageRect.radius
        blur: 20 // Shadow softness
        spread: 0 // Shadow size relative to source
        color: "#80000000" // Shadow color with alpha (black, 50% opacity)
        antialiasing: true // Smooth the edges
    }

    Rectangle {
        id: settingsPageRect
        height: parent.height
        width: 0.5 * parent.width
        color: backgroundcolor2
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
            id: settingsTitleBar
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
                id: closeSettingsButton
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
                    onClicked: settingsPagePressed()
                } 
            }
    
            Rectangle {
                id: contentContainer
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: closeSettingsButton.right
                    right: parent.right
                }
                color: "transparent"

                Text {
                    id: settingsTitleText
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        margins: 5
                    }
                    text: "Settings"
                    color: "#FFFFFF" //change to titleTextColor variable later
                    font.pixelSize: 30
                    fontSizeMode: Text.Fit
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Rectangle {
            id: settingsPageBody
            color: "transparent"
            anchors {
                top: settingsTitleBar.bottom
                bottom: parent.bottom
                left: settingsPageRect.left
                right: settingsPageRect.right
                margins: 4
            }

            Column {
                id: settingsColumn
                anchors.fill: parent
                spacing: 4
                topPadding: 5

                Rectangle {
                    id: lightDarkModeRect
                    width: parent.width
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    height: 40
                    color: "transparent"

                    Text {
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: 5
                        }
                        text: "Theme "
                        color: colorWay.textColor
                        minimumPixelSize: 12
                        font.pixelSize: 20
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter 
                    }

                    CustomComboBox {
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: 5
                        }
                        id: lightDarkModeSelect
                        height: parent.height * 0.6
                        width: 120
                        model: ["Light", "Dark"]
                        editable: false
                        onActivated: { 
                            displayText = currentText
                            colorWay.switchColorMode(lightDarkModeSelect.currentIndex) 
                            root.configUpdated("theme", lightDarkModeSelect.currentIndex)
                        }
                    }
                }

                Rectangle {
                    anchors {
                        left:parent.left
                        right:parent.right
                        margins: 2
                    }
                    height: 3
                    radius: 3
                    color: colorWay.separatorColor
                } 

                Rectangle {
                    id: highContrastRect
                    width: parent.width
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    height: 40
                    color: "transparent"

                    Text {
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: 5
                        }
                        text: "High Contrast "
                        color: colorWay.textColor
                        minimumPixelSize: 12
                        font.pixelSize: 20
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter 
                    }

                    CustomComboBox {
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: 5
                        }
                        id: highContrastSelect
                        height: parent.height * 0.6
                        width: 120
                        model: ["Off", "On"]
                        editable: false
                        onActivated: { 
                            displayText = currentText
                            root.configUpdated("contrast", highContrastSelect.currentIndex)
                        }
                    }      
            }

                Rectangle {
                    anchors {
                        left:parent.left
                        right:parent.right
                        margins: 2
                    }
                    height: 3
                    radius: 3
                    color: colorWay.separatorColor
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
        color: colorWay.focusColor //save as focusColor
        visible: false
        radius: 15
    }

    PropertyAnimation {
        id: settingsPageSlideIn
        target: settingsPageRect
        property: "x"
        to: 0
        duration: 150

        onStarted: focusEmphasis.visible = true
        //onFinished: focusEmphasis.visible = true
    }

    PropertyAnimation {
        id: settingsPageSlideOut
        target: settingsPageRect
        property: "x"
        to: -1 * settingsPageRect.width
        duration: 150

        onStarted: focusEmphasis.visible = false
        onFinished: settingsRoot.visible = false
    }

    function init(theme, contrast) {
        lightDarkModeSelect.currentIndex = theme
        theme === 0 ? lightDarkModeSelect.displayText = "Light" :  lightDarkModeSelect.displayText = "Dark"
        highContrastSelect.currentIndex = contrast
        contrast === 0 ? highContrastSelect.displayText = "Off" :  highContrastSelect.displayText = "On"
        colorWay.switchColorMode(theme)
    }

    function settingsPagePressed() {
        if(viewing === false) {
            settingsPageRect.x = -1 * settingsPageRect.width
            settingsRoot.visible = true
            settingsPageSlideIn.running = true
            viewing = true
        } else {
            settingsPageSlideOut.running = true
            viewing = false
            root.focused = true
        }
    }
}