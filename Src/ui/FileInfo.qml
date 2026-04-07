import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

ApplicationWindow {
    property int maxLength: 0
    property int totalIssuesFound: 0
    property bool solveInProgress: false

    property var infoStream: null
    property var aiStream: null
    property var selectedIssue: null
    property string selectedIssueType: ""

    id: windowRoot
    width: screen.width * 0.8  
    height: screen.height * 0.8 
    visible: false

    title: ""
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    Rectangle {
        id: windowFiller
        radius: 15
        anchors.fill: parent
        color: colorWay.backgroundcolor
        border.color: colorWay.backgroundcolor2
        border.width: 1
        clip: true

        InfoTitleBar {
            id: infoTitleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 1
            }
        }

        RectangularShadow {
            anchors.fill: sourceCodeRect
            offset.x: 5 
            offset.y: 5 
            radius: sourceCodeRect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: sourceCodeRect
            anchors {
                top: infoTitleBar.bottom
                left: parent.left
                margins: 15
            }
            border.color: colorWay.accent1color
            border.width: {
                if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                else {0}
            }

            width: 0.55 * parent.width
            height: 0.55 * parent.height
            radius: 15
            color: colorWay.backgroundcolor2

            ScrollView {
                id: viewSourceCode
                anchors.fill: parent
                anchors.margins: 6
                clip: true 

                ScrollBar.vertical: ScrollBar {
                    id: vBar
                    parent: viewSourceCode
                    x: viewSourceCode.mirrored ? 0 : viewSourceCode.width - width
                    y: viewSourceCode.topPadding
                    height: viewSourceCode.availableHeight
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    visible: vBar.size < 1.0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: vBar.visible
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        color: colorWay.backgroundcolor2
                        visible: vBar.visible
                    }
                }
                
                ScrollBar.horizontal: ScrollBar {
                    id: hBar
                    parent: viewSourceCode
                    x: viewSourceCode.leftPadding
                    y: viewSourceCode.height - height
                    width: viewSourceCode.availableWidth
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    visible: hBar.size < 1.0

                    contentItem: Rectangle {
                        implicitHeight: 7
                        radius: height / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: hBar.visible
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        color: colorWay.backgroundcolor2
                        visible: hBar.visible
                    }
                }

                background: Rectangle {
                    color: colorWay.backgroundcolor2
                    radius: sourceCodeRect.radius
                }

                contentWidth: contentContainer.width
                contentHeight: contentContainer.height
                
                Item {
                    id: contentContainer
                    height: savedList.contentHeight
                    
                    property real maxLineWidth: 0
                    width: Math.max(viewSourceCode.availableWidth, maxLineWidth)

                    ListView {
                        id: savedList
                        anchors.fill: parent
                        interactive: false  
                        orientation: Qt.Vertical
                        model: codeModel
                        boundsBehavior: Flickable.StopAtBounds
                        
                        delegate: Item {
                            property real contentRealWidth: lineNum.implicitWidth + lineNum_separatorbar.width + codeLine.implicitWidth + 20

                            width: Math.max(viewSourceCode.availableWidth, contentRealWidth)
                            height: 35
                            
                            // 3. When this row loads, check if it's the widest one yet
                            Component.onCompleted: {
                                if (width > contentContainer.maxLineWidth) {
                                    contentContainer.maxLineWidth = width
                                }
                            }

                            Rectangle {
                                id: delegateRect
                                anchors.fill: parent
                                color: colorWay.backgroundcolor2
                                
                                // 4. Ensure the background fills the full scrolling width
                                width: Math.max(parent.width, contentContainer.maxLineWidth)

                                Text {
                                    id: lineNum
                                    anchors { left: parent.left; leftMargin: 2; verticalCenter: parent.verticalCenter }
                                    text: line_index
                                    font.family: "Consolas"
                                    font.pixelSize: 25
                                    color: colorWay.textColor
                                    z: 3
                                }

                                Rectangle {
                                    id: lineNum_separatorbar
                                    anchors { left: lineNum.right; leftMargin: 5; top: parent.top; bottom: parent.bottom }  
                                    width: 3
                                    color: colorWay.separatorColor
                                    z: 1
                                }

                                Text {
                                    id: codeLine
                                    anchors { left: lineNum_separatorbar.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                    text: code_line
                                    font.pixelSize: 25
                                    color: colorWay.textColor
                                    wrapMode: Text.NoWrap
                                    z: 3
                                }

                                Rectangle {
                                    id: codeHighlight
                                    //anchors.fill: codeLine
                                    anchors {
                                        top: lineNum.top
                                        left: lineNum.left
                                        bottom: codeLine.bottom
                                    }
                                    width: lineNum.width + contentContainer.width
                                    height: codeLine.height
                                    color: code_color
                                    z:2
                                }
                            }
                        }
                    }
                }     
            }
        }

        ListModel {
            id: codeModel
        }

        RectangularShadow {
            anchors.fill: issuesRect
            offset.x: 5 
            offset.y: 5 
            radius: sourceCodeRect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: issuesRect
            anchors {
                top: infoTitleBar.bottom
                left: sourceCodeRect.right
                right: parent.right
                margins: 15
            }
            border.color: accent1color
            border.width: {
                if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                else {0}
            }

            height: 0.55 * parent.height
            radius: 10
            color: backgroundcolor2

            ScrollView {
                id: viewIssues
                anchors.fill: parent
                anchors.margins: 6
                clip: true 

                ScrollBar.vertical: ScrollBar {
                    id: vBar2
                    parent: viewIssues
                    x: viewIssues.mirrored ? 0 : viewIssues.width - width
                    y: viewIssues.topPadding
                    height: viewIssues.availableHeight 
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    visible: vBar2.size < 1.0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: vBar2.visible
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        color: backgroundcolor2
                        visible: vBar2.visible
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    id: hBar2
                    parent: viewIssues
                    x: viewIssues.leftPadding
                    y: viewIssues.height - height
                    width: viewIssues.availableWidth
                    policy: ScrollBar.AsNeeded
                    hoverEnabled: false
                    active: hovered || pressed

                    visible: hBar2.size < 1.0

                    contentItem: Rectangle {
                        implicitHeight: 6
                        radius: height / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: hBar2.visible
                    } 
                    background: Rectangle {
                        implicitHeight: 10
                        color: colorWay.backgroundcolor2
                        opacity: 1
                        visible: hBar2.visible
                    }
                }

                background: Rectangle {
                    color: colorWay.backgroundcolor2
                    radius: issuesRect.radius
                }

                contentHeight: contentColumn.implicitHeight + 20

                ColumnLayout {
                    id: contentColumn
                    width: Math.max(viewIssues.availableWidth, implicitWidth)
                    spacing: 0
                
                    IssuePane {
                        id: maskFiltPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                        aiWorking: solveInProgress
                        onIssueSelected: (textStr) => showAISolution("mask_filt", textStr)
                    }

                    IssuePane {
                        id: rtrPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                        aiWorking: solveInProgress
                        onIssueSelected: (textStr) => showAISolution("rtr", textStr)
                    }

                    IssuePane {
                        id: idLenPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                        aiWorking: solveInProgress
                        onIssueSelected: (textStr) => showAISolution("idLen", textStr)
                    }

                    IssuePane {
                        id: dlcPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                        aiWorking: solveInProgress
                        onIssueSelected: (textStr) => showAISolution("dlc", textStr)
                    }

                    IssuePane {
                        id: bytePackingPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                        aiWorking: solveInProgress
                        onIssueSelected: (textStr) => showAISolution("dataPack", textStr)
                    }
                }
            }
        }

        RectangularShadow {
            anchors.fill: suggestionRect
            offset.x: 5 
            offset.y: 5 
            radius: suggestionRect.radius
            blur: 20 // Shadow softness
            spread: 0 // Shadow size relative to source
            color: "#80000000" // Shadow color with alpha (black, 50% opacity)
            antialiasing: true // Smooth the edges
        }

        Rectangle {
            id: suggestionRect
            anchors {
                top: sourceCodeRect.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 15
            }
            border.color: accent1color
            border.width: {
                if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                else {0}
            }

            color: backgroundcolor2
            radius: 15

            Rectangle {
                id: suggestionTextRect
                width: suggestionTextBox.contentWidth + 10
                height: suggestionTextBox.contentHeight + 10
                color: "transparent"
                visible: false

                Text {
                    id: suggestionTextBox
                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: 5
                    }
                    text: ""
                    font.pixelSize: 25
                    color: colorWay.textColor
                }
            }

            Rectangle {
                id: issueSelectionRect
                anchors {
                    fill: parent
                }
                color: "transparent"
                visible: ((root.aiEnabled === true) && (totalIssuesFound > 0)) ? true : false

                Rectangle {
                    id: issueFixSolutions

                    x: 0
                    height: parent.height
                    width: parent.width * 0.20
                    color: "transparent"

                    Text {
                        id: activeIssueText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "No Issue Selected"
                        color: colorWay.textColor
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 12
                        font.pixelSize: 30
                        wrapMode: Text.Wrap
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: menuArrowRect
                    width: 20
                    height:parent.height
                    anchors {
                        top: parent.top
                        left: issueFixSolutions.right
                    }
                    color: hideMenuArea.containsMouse ? colorWay.focusColor : "transparent"
                    radius: 10

                    Rectangle {
                        id: leftBar
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: parent.bottom
                            topMargin: 10
                            bottomMargin: 10
                        }
                        width: 2
                        radius: 1
                        color: colorWay.separatorColor
                    }

                    MouseArea {
                        id: hideMenuArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(arrowText.text == "˃") {
                                console.log("showing menu...")
                                showAIMenu.running = true
                            }
                            else if(arrowText.text == "˂") { 
                                console.log("hiding menu...")
                                hideAIMenu.running = true
                                
                            }
                        }
                    }

                    Text {
                        id: arrowText
                        anchors.centerIn: parent
                        font.pixelSize: 25
                        font.bold: true
                        text: issueFixSolutions.x < 0 ? "˃" : "˂" 
                        color: colorWay.accent1color
                    }

                    Rectangle {
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            topMargin: 10
                            bottomMargin: 10
                        }
                        width: 2
                        radius: 1
                        color: colorWay.separatorColor
                    }
                }

                Rectangle {
                    id: issueSolutionRect
                    anchors {
                        top: parent.top
                        left: menuArrowRect.right
                        right:parent.right
                        bottom: parent.bottom
                    }
                    color: "transparent"

                    Text {
                        id: issuePlaceholderText
                        anchors.centerIn: parent
                        text: "Select an issue to view potential solutions"
                        font.pixelSize: 30
                        color: textColor
                        visible: true
                    }

                    Text {
                        id: issueSolutionText
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            leftMargin: 10
                            margins: 6
                        }

                        text: ""
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 12
                        font.pixelSize: 30
                        wrapMode: Text.WordWrap
                        visible: false
                        color: colorWay.textColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }

                    Rectangle {
                        id: loadingIssueRect
                        anchors.centerIn: parent
                        width: 80 + generatingText.contentWidth
                        height: 80

                        color: "transparent"
                        visible: solveInProgress
                        
                        Rectangle {
                            id: solvingIndicatorRect
                            width: 80
                            height: 80
                            color: "transparent"

                            LoadingIndicator {
                                id: solvingIssueIndicator
                                anchors.fill: parent
                                isRunning: solveInProgress
                                visible: solveInProgress
                            }
                        }

                        Rectangle {
                            id: solvingStatusRect
                            anchors {
                                top: solvingIndicatorRect.top
                                bottom: solvingIndicatorRect.bottom
                                left: solvingIndicatorRect.right
                                leftMargin: 5
                            }
                            color: "transparent"

                            Text {
                                id: generatingText
                                anchors {   
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                } 
                                text: "Generating solution..."
                                font.pixelSize: 30
                                color: colorWay.textColor
                                visible: solveInProgress
                            }
                        }
                    }
                } 
            }   

            Rectangle {
                id: noAiRect
                width: (aiIconImg.width) 
                height: 80
                color: "transparent"
                visible: ((root.aiEnabled === false) && (totalIssuesFound > 0)) ? true : false
                x: (suggestionRect.width - width) / 2
                y: (suggestionRect.height - height) / 2

                Rectangle {
                    id: aiIconImg
                    width: 100 + Math.max(aiTopText.contentWidth, aiBottomText.contentWidth)
                    height: 100
                    color: "transparent"

                    Image {
                        id: aiImg
                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                        width: 100
                        height: 100
                        source: colorWay.noAiIconSrc
                        mipmap: true
                    }

                    Text {
                        id: aiTopText
                        anchors {
                            top: aiImg.top
                            left: aiImg.right
                            topMargin: 10
                        }

                        text: "AI suggestions are turned off!"
                        font.pixelSize: 30
                        color: colorWay.textColor
                    }

                    Text {
                        id: aiBottomText
                        anchors {
                            bottom: aiImg.bottom
                            left: aiImg.right
                            bottomMargin: 15
                        }

                        text: "Enable suggestions: 'Settings>LLM Model'"
                        font.pixelSize: 25
                        color: colorWay.secondaryTextColor
                    }
                }
            }

            Rectangle {
                id: noIssueRect
                width: (noIssueIconImg.width) 
                height: 80
                color: "transparent"
                visible: totalIssuesFound === 0 ? true : false
                x: (suggestionRect.width - width) / 2
                y: (suggestionRect.height - height) / 2

                Rectangle {
                    id: noIssueIconImg
                    width: 100 + Math.max(noIssueTopText.contentWidth, noIssueBottomText.contentWidth)
                    height: 100
                    color: "transparent"

                    Image {
                        id: noIssueImg
                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                        width: 100
                        height: 100
                        mipmap: true
                        source: colorWay.noIssueSrc
                    }

                    Text {
                        id: noIssueTopText
                        anchors {
                            top: noIssueImg.top
                            left: noIssueImg.right
                            topMargin: 10
                        }

                        text: "No Issues detected!"
                        font.pixelSize: 30
                        color: colorWay.textColor
                    }

                    Text {
                        id: noIssueBottomText
                        anchors {
                            bottom: noIssueImg.bottom
                            left: noIssueImg.right
                            bottomMargin: 15
                        }

                        text: "Yippiee!"
                        font.pixelSize: 25
                        color: colorWay.secondaryTextColor
                    }
                }
            }
        }
    }
    
    ListModel {
        id: issueModel
    }

    TextMetrics {
        id: textMeasurer
        font.pixelSize: 28
    }

    PropertyAnimation {
        id: hideAIMenu
        target: issueFixSolutions
        property: "x"
        to: -1 * issueFixSolutions.width
        duration: 150
        onFinished: {
            issueFixSolutions.visible = false
            leftBar.visible = false
        }
    }

    PropertyAnimation {
        id: showAIMenu
        target:  issueFixSolutions
        property: "x"
        to: 0
        duration: 150
        onStarted: {
            issueFixSolutions.visible = true
            leftBar.visible = true
        }
    }

    function setFileInfo(code, dataStream) {
        console.log("setFileInfo called...")
        var temp = ""

        infoStream = dataStream.data
        aiStream = dataStream.AI_solutions
        windowRoot.title = infoStream.file_name
        infoTitleBar.setTitleText(infoStream.file_name)
        for (var i = 0; i < code.length; i++) {
            var hilightColor = "transparent"
            infoStream.mask_filt.mf_lineNums.forEach(function(item) {
                if(item === i+1) {
                    hilightColor = '#80FF0000'
                }
            })   

            infoStream.rtr.rtr_lineNums.forEach(function(item) {
                if(item === i+1) {
                    hilightColor = '#80FF0000'
                }
            })

            infoStream.idLen.idLen_lineNums.forEach(function(item) {
                if(item === i+1) {
                    hilightColor = '#80FF0000'
                }
            })
            
            var line = {
                "line_index": (i+1).toString().padStart(4, " "),
                "code_line": code[i],
                "code_color": hilightColor
            }

            textMeasurer.text = "    " + line.code_line
            var currentWidth = textMeasurer.width + 18
            maxLength = Math.max(maxLength, currentWidth)
            codeModel.append(line)
        }
        viewSourceCode.contentWidth = maxLength

        //infoStream.mask_filt.mf_messages.forEach(function(item) {
        //    temp += ("• " + item) + "\n"
        //})  
        maskFiltPane.populateModule("Mask and Filter (" + infoStream.mask_filt.mf_issues + ")", infoStream.mask_filt.mf_messages)
        if(infoStream.mask_filt.mf_issues !== 0) {
            temp = ""
            /*
            aiStream.mask_filt.solution.forEach(function(item){
                temp += item
            })
            issueModel.append({
                "issue_name": "Mask and Filter", 
                "abbreviation": "mask_filt",
                "previously_solved": aiStream.mask_filt.cached,
                "issue_solution": temp
            })
            */
        }

        temp = ""
        //infoStream.rtr.rtr_messages.forEach(function(item) {
        //    temp += ("• " + item) + "\n"
        //})
        rtrPane.populateModule("Remote Transmission Request (" + infoStream.rtr.rtr_issues + ")", infoStream.rtr.rtr_messages)
        if(infoStream.rtr.rtr_issues !== 0) {
            temp = ""
            /*
            aiStream.rtr.solution.forEach(function(item){
                temp += item
            })
            issueModel.append({
                "issue_name": "Remote Transmission Request",
                "abbreviation": "rtr", 
                "previously_solved": aiStream.rtr.cached,
                "issue_solution": temp
            })
            */
        }

        temp = ""
        //infoStream.idLen.idLen_messages.forEach(function(item) {
        //    temp += ("• " + item) + "\n"
        //})
        idLenPane.populateModule("ID Length (" + infoStream.idLen.idLen_issues + ")", infoStream.idLen.idLen_messages)
        if(infoStream.idLen.idLen_issues !== 0) {
            temp = ""
            /*
            aiStream.idLen.solution.forEach(function(item){
                temp += item
            })
            issueModel.append({
                "issue_name": "ID Bitlength", 
                "abbreviation": "idLen",
                "previously_solved": aiStream.idLen.cached,
                "issue_solution": temp
            })
            */
        }

        temp = ""
        //infoStream.dlc.dlc_messages.forEach(function(item) {
        //    temp += ("• " + item) + "\n"
        //})
        dlcPane.populateModule("Data Length Code (" + infoStream.dlc.dlc_issues + ")", infoStream.dlc.dlc_messages)
        if(infoStream.dlc.dlc_issues !== 0) {
            temp = ""
            /*
            aiStream.dlc.solution.forEach(function(item){
                temp += item
            })
            issueModel.append({"
                issue_name": "Data Length", 
                "abbreviation": "dlc",
                "previously_solved": aiStream.dlc.cached,
                "issue_solution": temp
            })
            */ 
        }

        temp = ""
        //infoStream.dataPack.dataPack_messages.forEach(function(item) {
        //   temp += ("• " + item) + "\n"
        //})
        bytePackingPane.populateModule("Data Byte Packing (" + infoStream.dataPack.dataPack_issues + ")", infoStream.dataPack.dataPack_messages)
        if(infoStream.dataPack.dataPack_issues !== 0) {
            temp = ""
            /*
            aiStream.dataPack.solution.forEach(function(item){
                temp += item
            })
            issueModel.append({
                "issue_name": "Byte Packing", 
                "abbreviation": "dataPack",
                "previously_solved": aiStream.dataPack.cached,
                "issue_solution": temp
            })
            */
        }
        totalIssuesFound = infoStream.totalIssues
        windowRoot.visible = true
    }

    function showAISolution(type, issueText) {
        selectedIssue = aiStream[type]["solution"][issueText] 
        activeIssueText.text = issueText
        selectedIssueType = type
        if(selectedIssue.cached) {
            solveInProgress = false
            issueSolutionText.text = selectedIssue.answer
            issuePlaceholderText.visible = false
            issueSolutionText.visible = true
        }
        else {
            issuePlaceholderText.visible = false
            issueSolutionText.visible = false
            solveInProgress = true
            if(type == "mask_filt") {
                var errorMsgs = "mf_messages"
            }
            else {
                var errorMsgs = type + "_messages"
            }
            root.generateAISolution(type, issueText, infoStream.file_name)
        }
    }

    function scanCompleted(solutionText) {
        selectedIssue.cached = true
        selectedIssue.answer = solutionText
        solveInProgress = false
        issueSolutionText.text = selectedIssue.answer
        issuePlaceholderText.visible = false
        issueSolutionText.visible = true
    }
}