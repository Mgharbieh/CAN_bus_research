import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

Item {
    property bool viewing: false
    property bool keyRequired: false
    property int keyLength: 0

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
                    color: closeMouseArea.containsMouse ? '#adadad' : colorWay.titleTextColor
                    styleColor: "#FFFFFF"
                    font.pixelSize: 50
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(keyRequired === true) {
                            if(keyLength === 0) {
                                root.showMessage("./assets/WARN.png", "API key cannot be empty")
                            }
                            else {
                                settingsPagePressed()
                                cancelDeleteRect.visible = false
                                confirmDeleteRect.visible = false
                                deleteButton.visible = true
                            }
                        }
                        else {
                            settingsPagePressed()
                            cancelDeleteRect.visible = false
                            confirmDeleteRect.visible = false
                            deleteButton.visible = true
                        }
                    }
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
                            colorWay.changeTheme(lightDarkModeSelect.currentIndex, highContrastSelect.currentIndex)
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
                            colorWay.changeTheme(lightDarkModeSelect.currentIndex, highContrastSelect.currentIndex)
                            root.configUpdated("highContrast", highContrastSelect.currentIndex)
                            //colorWay.highContrastMode(highContrastSelect.currentIndex)
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
                    id: deleteAllFilesRect
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
                        text: "Delete all Files"
                        color: colorWay.textColor
                        minimumPixelSize: 12
                        font.pixelSize: 20
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter 
                    }

                    Rectangle {
                        id: deleteButton
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: 5
                        }
                        radius: 5
                        width: 120
                        border.width: 1
                        border.color: "#FF0000"
                        color: {
                            if(dataCount > 0 && mouseArea.containsMouse) {
                                "#FF0000" 
                            }
                            else if(dataCount === 0 &&  mouseArea.containsMouse) {
                                colorWay.backgroundcolor
                            }
                            else {
                                colorWay.backgroundcolor2
                            }
                        } 
                        visible: true

                        Text {
                            anchors.fill: parent
                            text: "Delete"
                            color: mouseArea.containsMouse ? "#FFFFFF" : "#FF0000"
                            minimumPixelSize: 12
                            font.pixelSize: 20
                            fontSizeMode: Text.Fit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter 
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.dataCount === 0 ? cursorShape = Qt.ForbiddenCursor : cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                            onClicked: {
                                if(root.dataCount > 0) {
                                    deleteButton.visible = false
                                    cancelDeleteRect.visible = true
                                    confirmDeleteRect.visible = true
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: cancelDeleteRect
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: 5
                        }
                        radius: 5
                        width: 70
                        border.width: 1
                        border.color: mouseArea2.containsMouse ? colorWay.accent1color : colorWay.textColor
                        color: mouseArea2.containsMouse ? colorWay.accent1color : colorWay.backgroundcolor
                        visible: false

                        Text {
                            anchors.fill: parent
                            anchors.margins: 2
                            text: "Cancel"
                            color: mouseArea2.containsMouse ? colorWay.titleTextColor : colorWay.textColor
                            minimumPixelSize: 12
                            font.pixelSize: 20
                            fontSizeMode: Text.Fit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter 
                        }

                        MouseArea {
                            id: mouseArea2
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                            onClicked: {
                                cancelDeleteRect.visible = false
                                confirmDeleteRect.visible = false
                                deleteButton.visible = true
                            }
                        }
                    }

                    Rectangle {
                        id: confirmDeleteRect
                        anchors {
                            top: parent.top
                            right: cancelDeleteRect.left
                            bottom: parent.bottom
                            margins: 5
                        }
                        radius: 5
                        width: 70
                        border.width: 1
                        border.color: "#FF0000"
                        color: mouseArea3.containsMouse ? "#FF0000" : colorWay.backgroundcolor
                        visible: false

                        Text {
                            anchors.fill: parent
                            anchors.margins: 2
                            text: "Confirm"
                            color: mouseArea3.containsMouse ? "#FFFFFF" : "#FF0000"
                            minimumPixelSize: 12
                            font.pixelSize: 20
                            fontSizeMode: Text.Fit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter 
                        }

                        MouseArea {
                            id: mouseArea3
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                            onClicked: {
                                root.deleteAllFiles()
                                cancelDeleteRect.visible = false
                                confirmDeleteRect.visible = false
                                deleteButton.visible = true
                            }
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
                    property alias selectedAgent: llmSelect.currentIndex
                    id: aiAgentRect
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
                        text: "LLM Model"
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
                        id: llmSelect
                        height: parent.height * 0.6
                        width: 120
                        model: ["Off (No AI)","Llama3", "DeepSeek", "ChatGPT", "Claude", "Gemini"]   //add others??
                        editable: false
                        onActivated: { 
                            displayText = currentText
                            llmSelect.currentIndex > 1 ? keyRequired = true : keyRequired = false
                            root.configUpdated("aiAgent", llmSelect.currentIndex)
                            apiKeyInput.text = ""
                            root.storeAPIKey("API_KEY", "")
                            if(llmSelect.currentIndex > 0) {
                                root.aiEnabled = true
                            }
                            else {
                                root.aiEnabled = false
                            }
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
                    id: aiAPIKeyRect
                    width: parent.width
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    height: 40
                    color: "transparent"
                    visible: llmSelect.currentIndex <= 1 ? false : true

                    Text {
                        id: apiKeyInputText
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            margins: 5
                        }
                        text: "API Key: "
                        color: colorWay.textColor
                        minimumPixelSize: 12
                        font.pixelSize: 20
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter 
                    }

                    Rectangle {
                        id: apiKeyBorder
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            left: apiKeyInputText.right
                            margins: 5
                        } 
                        border.width: 1
                        border.color: colorWay.separatorColor
                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.IBeamCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }

                        Text {
                            anchors {
                                top: parent.top
                                left: parent.left
                                bottom: parent.bottom
                                margins: 5
                            }
                            visible: apiKeyInput.length > 1 ? false : true
                            text: "Enter API key..."
                            color: colorWay.itemColor
                            minimumPixelSize: 12
                            font.pixelSize: 20
                            fontSizeMode: Text.Fit
                            verticalAlignment: Text.AlignVCenter 
                        }

                        TextInput {
                            id: apiKeyInput
                            anchors {
                                top: parent.top
                                left: parent.left
                                bottom: parent.bottom
                                right: parent.right
                                margins: 2
                            }
                            echoMode: TextInput.Password
                            selectByMouse: false
                            color: colorWay.textColor
                            font.pixelSize: 20
                            verticalAlignment: Text.AlignVCenter
                            onTextEdited: keyLength = apiKeyInput.length
                            onEditingFinished: {
                                if(apiKeyInput.length > 0) {
                                    console.log("api key edit finished")
                                    console.log(apiKeyInput.text)
                                    root.storeAPIKey("API_KEY", apiKeyInput.text)    
                                }
                            } 
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
                    visible: aiAgentRect.selectedAgent <= 1 ? false : true
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

    function init(theme, contrast, agent, key) {
        lightDarkModeSelect.currentIndex = theme
        theme === 0 ? lightDarkModeSelect.displayText = "Light" :  lightDarkModeSelect.displayText = "Dark"
        highContrastSelect.currentIndex = contrast
        contrast === 0 ? highContrastSelect.displayText = "Off" :  highContrastSelect.displayText = "On"
        colorWay.changeTheme(theme, contrast)
        llmSelect.currentIndex = agent
        apiKeyInput.text = key
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