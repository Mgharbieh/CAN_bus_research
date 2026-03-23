import QtQml 6.10
import QtQuick 6.10
import QtQuick.Window 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Dialogs 6.10

ApplicationWindow { 
    property string accent1color: colorWay.accent1color
    property string backgroundcolor: colorWay.backgroundcolor
    property string backgroundcolor2: colorWay.backgroundcolor2
    property string textColor: colorWay.textColor

    property bool scanInProgress: false
    property int itemBeingScanned: -1
    property int itemSelected: -1
    property int itemDeleted: -1
    property string path_to_file: ""
    property bool focused: true
    property bool generatingSuggestions: false

    property var fileInfoWindow: null
    property bool loadingWindow: false
    
    //temp, find better solution later
    property var details
    property var sourceCode 

    signal scanFile(string path)
    signal checkFileExists(string name)
    signal loadSelectedFile(string name)
    signal configUpdated(string key, var val)
    signal deleteFile(string path)
    signal deleteAllFiles()
    signal storeAPIKey(string keyName, string key)
    
    title: "StatiCAN"
    flags: Qt.Window | Qt.FramelessWindowHint

    id: root
    width: 800
    height: 640

    visible: true
    color: "transparent"

    ColorWay { id: colorWay }

    Connections {
        target: ISSUE_CHECKER

        function onFileExists(status, mode) {
            if(status === true) {
                showMessage("./assets/INFO.png", "No new changes detected for " + path_to_file.split("/").slice(-1)[0])
            }
            else {
                if(mode === "replace") {
                    replaceExistingFile()
                    processFile()
                }
                else {
                    processFile()
                }
                
            }
        } 

        function onStatusMessage(status) {
            generatingSuggestions = status
        }

        function onFileProcessed(issueCount) {
            savedModel.setProperty(itemBeingScanned, "issues", issueCount)
            scanInProgress = false
        }

        function onFileLoaded(code, data) {
            details = JSON.parse(data)
            sourceCode = code
            openFileInfo()
        }

        function onPopulateSavedFiles(fileList) {
            var data = JSON.parse(fileList)
            data.files.forEach(function(item) {
                var card = {
                    "file_name": item.file_name,
                    "issues": item.totalIssues,
                }
                savedModel.insert(0, card)
            }) 
        }

        function onConfigFileLoaded(theme, contrast, agent, key) {
            settingsPage.init(theme, contrast, agent, key)
        }

        function onFileDeleted(name) {
            if(name !== "allDeleted") {
                if(savedModel.get(itemDeleted).file_name === name) {
                    savedModel.remove(itemDeleted)
                }
            }
            else if(name === "allDeleted") {
                savedModel.clear()
            }
            
            
        }
    }

    property alias dataCount: savedModel.count
    ListModel {
        id: savedModel
    }

    Rectangle {
        id: windowFiller
        radius: 15
        anchors.fill: parent
        color: backgroundcolor
        border.color: backgroundcolor2
        border.width: 1
        clip: true

        TitleBar {
            id: title
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right:parent.right
            anchors.margins: 1
        }

        Rectangle {
            id: stati_Rect
            anchors {
                top:parent.top
                left: parent.left
                topMargin: 15
                leftMargin: 15
            }

            width: 90
            height: 55
            color: "transparent"
            radius: 10
            border.width: 0

            Text {
                id: text1
                color: accent1color
                text: qsTr("Stati")
                anchors.fill: parent
                font.pixelSize: 40
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }

        Rectangle {
            id: can_Rect
            anchors {
                top: parent.top
                left: stati_Rect.right
                topMargin:15
            }

            width: 95
            height: 55
            color: accent1color
            radius: 10
            border.width: 0

            Text {
                id: can_txt
                color: colorWay.titleTextColor
                text: qsTr("CAN")
                anchors.fill: parent
                font.pixelSize: 40
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }

        Rectangle {
            id: separatorBar
            color: colorWay.separatorColor
            width: 3
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: can_Rect.right

                topMargin: 15
                bottomMargin: 15
                leftMargin: 12
            }
        }

        Rectangle {
            id: rectangle2
            color: "transparent" 
            radius: 10

            anchors {
                top: title.bottom
                bottom: parent.bottom
                right: parent.right
                left: separatorBar.right
                rightMargin: 15
                topMargin: 15
                bottomMargin: 25
                leftMargin: 8
            }
            z: 1

            Rectangle {
                id: filler
                anchors.fill: parent
                anchors.margins: 3
                color: backgroundcolor

                Component {
                    id: savedDelegate
                    Item {
                        id: savedItem
                        width: parent.width; height: 40
                        Rectangle {
                            anchors.fill: parent
                            Text {
                                anchors {
                                    right: parent.right
                                    top: parent.top
                                    rightMargin: 5
                                    topMargin: 5
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: savedList
                    anchors.fill: parent
                    orientation: Qt.Vertical
                    model: savedModel
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    
                    delegate: Item {
                        width: parent.width; height: 120
                        RectangularShadow {
                            anchors.fill: delegateRect
                            radius: delegateRect.radius
                            offset.x: 5 
                            offset.y: 5
                            blur: 8 // Shadow softness
                            spread: 0 // Shadow size relative to source
                            color: '#80000000' // Shadow color with alpha 
                            antialiasing: true // Smooth the edges
                        }
                        
                        Rectangle {
                            id: delegateRect
                            anchors {
                                fill: parent
                                margins: 8
                            }
                            border.color: accent1color
                            border.width: {
                                if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                                else {0}
                            }
                            color: backgroundcolor2
                            radius: 10

                            Text {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    leftMargin: 10
                                    topMargin: 10
                                }

                                text: file_name
                                font.pixelSize: 30
                                color: textColor
                            }

                            Rectangle {
                                id: file_status_rect
                                anchors {
                                    left: parent.left
                                    bottom: parent.bottom
                                    leftMargin: 10
                                    bottomMargin: 8
                                }  
                                width: 40
                                height: 40
                                color: "transparent"

                                Image {
                                    id: symbol_img
                                    anchors.fill: parent

                                    source: {
                                        if(issues === 0) {"./assets/checkmark_icon.png"}
                                        else {"./assets/x_icon.png"}
                                    }

                                    visible: issues === -1 ? false : true
                                }

                                LoadingIndicator {
                                    id: loadingFileIndicator
                                    anchors.fill: parent
                                    isRunning: scanInProgress
                                    visible: issues === -1 ? true : false
                                }
                            }

                            Text {
                                anchors {
                                    left: file_status_rect.right
                                    bottom: parent.bottom
                                    leftMargin: 8
                                    bottomMargin: 12
                                }

                                text: {
                                    if(issues === -1) {
                                        if(generatingSuggestions) {"Generating potential solutions..."}
                                        else {"Processing file..."}
                                    }
                                    else if(issues === 0) {"No issues found"}
                                    else if(issues === 1 ) {"1 issue found"}
                                    else (issues + " issues found")
                                }
                                font.pixelSize: 26
                                color:  colorWay.secondaryTextColor
                            }

                            Rectangle {
                                id: deleteItemRect
                                anchors {
                                    top: parent.top
                                    right:parent.right
                                    bottom: parent.bottom
                                    margins: 5
                                }
                                width: 66
                                color: "transparent"

                                Rectangle {
                                    id: deleteIconBackground
                                    anchors.centerIn:parent
                                    width: 62
                                    height: 62
                                    color: deleteMouseArea.containsMouse ? "#FF0000" : textColor

                                    MouseArea {
                                        id: deleteMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onEntered: cursorShape = Qt.PointingHandCursor
                                        onExited: cursorShape = Qt.ArrowCursor
                                        onClicked: {
                                            itemDeleted = index
                                            deleteFile(savedModel.get(itemDeleted).file_name)
                                        } 
                                    }
                                }

                                Image {
                                    id: deleteIconImage
                                    anchors.centerIn: parent
                                    width: 64
                                    height: 64
                                    mipmap: true
                                    source: colorWay.deleteIconSrc //(colorWay.colorMode === colorWay.lightMode) ? "./assets/delete-light.png" : "./assets/delete-dark.png"
                                }

                            }

                            Button {
                                id: accessElement
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    left: parent.left
                                    right: deleteItemRect.left
                                    rightMargin: 1
                                }
                                flat: true
                                enabled: focused

                                HoverHandler {
                                    cursorShape: {
                                        if(loadingFileIndicator.visible === true) { return Qt.WaitCursor} 
                                        else if(loadingWindow === true) { return Qt.WaitCursor }
                                        else { return Qt.PointingHandCursor }
                                    } //cursorShape: loadingWindow === true ? Qt.WaitCursor : Qt.PointingHandCursor
                                }

                                onClicked: { 
                                    console.log("clicked")
                                    loadingWindow = true
                                    itemSelected = index
                                    busyTimer.start()
                                    //openFileInfo()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: placeholderListText
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "Scanned files will appear here. Click the '+' icon to upload a file."
                    font.pixelSize: 16
                    color: textColor
                    visible: savedList.count === 0 ? true : false
                }
            }
        }

        Timer {
            id: busyTimer
            interval: 200
            repeat: false
            onTriggered: {
                //openFileInfo()
                loadSelectedFile(savedModel.get(itemSelected).file_name)
            }
        }

        Rectangle {
            id: topShadowRect
            anchors {
                top: rectangle2.top
                left: rectangle2.left
                right: rectangle2.right
            }
            height: parent.height - rectangle2.height - 8
            radius: 5
            z:3
            gradient: Gradient {
                GradientStop { position: 0.0; color:  colorWay.gradientColor1 } 
                GradientStop { position: 1.0; color:  colorWay.gradientColor2 }
            }
            visible: savedList.atYBeginning === true ? false : true
        }

        Rectangle {
            id: bottomShadowRect
            anchors {
                bottom: rectangle2.bottom
                left: rectangle2.left
                right: rectangle2.right
            }

            height: parent.height - rectangle2.height - 8
            radius: 5
            z:3
            gradient: Gradient {
                GradientStop { position: 0.0; color:  colorWay.gradientColor2 } // Start color at the top (0.0)
                GradientStop { position: 1.0; color:  colorWay.gradientColor1 }
            }
            visible: savedList.atYEnd === true ? false : true
        }

        RectangularShadow {
            anchors.fill: upload_file_rect
            offset.x: 5 
            offset.y: 5 
            radius: upload_file_rect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: upload_file_rect
            color: accent1color
            radius: 20

            anchors {
                left: parent.left
                top: can_Rect.bottom
                right: separatorBar.left
                topMargin: 25
                rightMargin: 25
                leftMargin: 25
                bottomMargin: 25
            }
            z: 1
            height: 90
            Button {
                id: button
                anchors.fill: parent
                //radius: 45
                flat: true
                enabled: !loadingWindow && focused
                

                onClicked: if(!scanInProgress) {uploadFileDialog.open()}

                HoverHandler { 
                    id: buttonHoverUpload
                    cursorShape: scanInProgress === true ? Qt.ForbiddenCursor : Qt.PointingHandCursor 
                    enabled: focused
                }

                ToolTip {
                    id: uploadToolTip
                    visible: buttonHoverUpload.hovered
                    enabled: focused
                    text: {
                        if(scanInProgress) {"Please wait until file is scanned"}
                        else {"Upload File"}
                    } 

                    delay: 500

                    contentItem: Text {
                        text: uploadToolTip.text
                        color: textColor
                    }

                    background: Rectangle {
                        color: backgroundcolor
                        border.color: accent1color
                        radius: 5
                    }
                }
            }

            Rectangle {
                id: rectangle4
                width: 10
                height: 60
                color: colorWay.titleTextColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id: rectangle5
                width: 10
                height: 60
                color: colorWay.titleTextColor
                anchors.verticalCenter: parent.verticalCenter
                rotation: 90
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        RectangularShadow {
            anchors.fill: settings_rect
            offset.x: 5 
            offset.y: 5 
            radius: upload_file_rect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: settings_rect
            height: 90
            color: accent1color
            radius: 20

            anchors {
                left: parent.left
                top: upload_file_rect.bottom
                right: separatorBar.left
                leftMargin: 25
                rightMargin: 25
                topMargin: 25
            }
            z: 1

            Image {
                id: settings_img
                anchors.centerIn: parent
                source: colorWay.colorMode === colorWay.darkModeHC ? "./assets/settings_edit_darkHC.png" : "./assets/settings_edit.png"
            }
            
            Button {
                id: button_settings
                anchors.fill: parent
                flat: true
                enabled: focused

                HoverHandler { 
                    id: buttonHoverSettings
                    cursorShape: Qt.PointingHandCursor 
                    enabled: focused
                }

                ToolTip {
                    id: settingsToolTip
                    visible: buttonHoverSettings.hovered
                    enabled: focused
                    text: "Settings"
                    delay: 500

                    contentItem: Text {
                        text: settingsToolTip.text
                        color: textColor
                    }

                    background: Rectangle {
                        color: backgroundcolor
                        border.color: accent1color
                        radius: 5
                    }
                }
                onClicked: { settingsPage.settingsPagePressed(); focused = false }
            }
        }

        RectangularShadow {
            anchors.fill: help_rect
            offset.x: 5 
            offset.y: 5 
            radius: upload_file_rect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: help_rect
            height: 90
            color: accent1color
            radius: 20

            anchors {
                left: parent.left
                right: separatorBar.left
                top: settings_rect.bottom
                leftMargin: 25
                rightMargin: 25
                topMargin: 25
            }
            z: 1

            Text {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right:parent.right
                    left: parent.left
                    
                    topMargin: 8
                    bottomMargin: 12
                    leftMargin: 10
                    rightMargin: 10
                }

                text: "?"
                font.pixelSize: 70
                font.bold: true
                color: colorWay.titleTextColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                id: button_help
                anchors.fill: parent
                flat: true
                enabled: focused

                HoverHandler { 
                    id: buttonHoverHelp
                    cursorShape: Qt.PointingHandCursor 
                    enabled: focused
                }

                ToolTip {
                    id: helpToolTip
                    visible: buttonHoverHelp.hovered
                    enabled: focused
                    text: "Help"
                    delay: 500

                    contentItem: Text {
                        text: helpToolTip.text
                        color: textColor
                    }

                    background: Rectangle {
                        color: backgroundcolor
                        border.color: accent1color
                        radius: 5
                    }
                }

                onClicked: { helpPage.helpPagePressed(); focused = false }
            }
        }
    
        Rectangle {
            id: umDearbornCECS
            anchors {
                top: help_rect.bottom
                bottom: parent.bottom
                right: separatorBar.left
                left: parent.left

                margins: 25
            }
            z:1
            radius: 20
            color: colorWay.backgroundcolor

            Image {
                anchors.centerIn: parent
                source: colorWay.cecsIconSrc

                width: parent.width - 5
                height: parent.height -5
                fillMode: Image.PreserveAspectFit
                //smooth: true
                mipmap: true
            }
        }
    }

    RectangularShadow {
        anchors.fill: messageRect
        offset.x: 5 
        offset.y: 5 
        radius: messageRect.radius
        blur: 20 // Shadow softness
        spread: 0 // Shadow size relative to source
        color: "#80000000" // Shadow color with alpha (black, 50% opacity)
        antialiasing: true // Smooth the edges
    }

    Rectangle {
        property alias msgIcon: messageIcon.source
        property alias msgColor: msgText.color
        property alias msgContent: msgText.text

        id: messageRect
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.5
        height: 50
        radius: 10
        y: parent.height + 70
        z: 10

        color: backgroundcolor
        border.width: 2
        border.color: accent1color

        Image {
            id: messageIcon
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                margins: 5
            }
            width: 40
            height: 40
        }

        Text {
            id: msgText
            anchors {
                top:parent.top
                bottom: parent.bottom
                left: messageIcon.right
                right: parent.right 
                margins: 5
            }
            color: textColor
            text: ""
            minimumPixelSize: 12
            font.pixelSize: 30
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    PropertyAnimation {
        id: messageSlideIn
        target: messageRect
        property: "y"
        to: root.height - 70
        duration: 150

        onFinished: msgDisplayTimer.start()
    }

    PropertyAnimation {
        id: messageSlideOut
        target: messageRect
        property: "y"
        to: root.height + 70
        duration: 150
    }

    Timer {
        id: msgDisplayTimer
        interval: 2500
        onTriggered: messageSlideOut.start()
    }

    HelpPage { id: helpPage }
    SettingsPage { id: settingsPage }

    FileDialog {
        id: uploadFileDialog
        nameFilters: ["INO Files (*.ino)"]
        onAccepted: checkIfScanned(selectedFile)
    }

    Timer {
        id: uiDelay
        interval: 1000
        repeat: false
        onTriggered: {
            console.log("timer done")
            scanFile(path_to_file)
        }
    }

    function checkIfScanned(path) {
        path_to_file = new URL(path).pathname
        var name = path_to_file.split("/")
        console.log("checking if file exists:", name[name.length - 1])
        checkFileExists(name[name.length - 1])
    }

    function processFile() {
        //path_to_file = new URL(filePath).pathname
        var name = path_to_file.split("/")
        var newElem = {
            "file_name": name[name.length - 1],
            "issues": -1
        }
        scanInProgress = true
        savedModel.insert(0, newElem)
        itemBeingScanned = 0
        uiDelay.start()
    }

    function openFileInfo() {
        loadingWindow = true
        if (fileInfoWindow === null) {
            var component = Qt.createComponent("FileInfo.qml");        
            if (component.status === Component.Ready) {
                fileInfoWindow = component.createObject(null)
                fileInfoWindow.setFileInfo(sourceCode, details)
                fileInfoWindow.show()
                loadingWindow = false
                fileInfoWindow.closing.connect(function() {
                    fileInfoWindow = null;  
                });
            } else {
                console.error("Error loading component:", component.errorString());
            }
        } else {
            fileInfoWindow.raise();
            fileInfoWindow.requestActivate();
            loadingWindow = false
        }
    }

    function replaceExistingFile() {
        var name = path_to_file.split("/")
        for (var i = 0; i < savedModel.count; i++) {
            var item = savedModel.get(i)
            if(item.file_name === name[name.length - 1]) {
                savedModel.remove(i)
                break
            }
        }
    }

    function showMessage(icon, textContent) {
        messageRect.msgIcon = icon
        messageRect.msgContent = textContent
        messageSlideIn.start()
    }
}
