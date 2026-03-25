import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

ApplicationWindow {
    property int maxLength: 0

    id: windowRoot
    width: screen.width * 0.8  
    height: screen. height * 0.8 
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
                    }

                    IssuePane {
                        id: rtrPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                    }

                    IssuePane {
                        id: idLenPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                    }

                    IssuePane {
                        id: dlcPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
                    }

                    IssuePane {
                        id: bytePackingPane
                        Layout.fillWidth: true
                        scrollRef: viewIssues
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

            ScrollView {
                id: viewSuggestions
                anchors.fill: parent
                anchors.margins: 6
                clip: true 

                contentWidth: suggestionTextRect.width
                contentHeight: suggestionTextRect.height

                ScrollBar.vertical: ScrollBar {
                    id: vBar3
                    parent: viewSuggestions
                    x: viewSuggestions.mirrored ? 0 : viewSuggestions.width - width
                    y: viewSuggestions.topPadding
                    height: viewSuggestions.availableHeight 
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    visible: vBar3.size < 1.0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: vBar3.visible
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        color: backgroundcolor2
                        visible: vBar3.visible
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    id: hBar3
                    parent: viewSuggestions
                    x: viewSuggestions.leftPadding
                    y: viewSuggestions.height - height
                    width: viewSuggestions.availableWidth
                    policy: ScrollBar.AsNeeded
                    hoverEnabled: false
                    active: hovered || pressed

                    visible: hBar3.size < 1.0

                    contentItem: Rectangle {
                        implicitHeight: 6
                        radius: height / 2
                        color: colorWay.itemColor
                        border.color: colorWay.accent1color
                        border.width: {
                            if(colorWay.colorMode === colorWay.lightModeHC || colorWay.colorMode === colorWay.darkModeHC) {1}
                            else {0}
                        }
                        visible: hBar3.visible
                    } 
                    background: Rectangle {
                        implicitHeight: 10
                        color: colorWay.backgroundcolor2
                        opacity: 1
                        visible: hBar3.visible
                    }
                }

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
                    id: noAiRect
                    width: (aiIconImg.width) 
                    height: 80
                    color: "transparent"
                    visible: false
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
                    visible: false
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
    }
    

    TextMetrics {
        id: textMeasurer
        font.pixelSize: 28
    }

    function setFileInfo(code, dataStream) {
        console.log("setFileInfo called...")
        var temp = ""

        var infoStream = dataStream.data
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

        infoStream.mask_filt.mf_messages.forEach(function(item) {
            temp += ("• " + item) + "\n"
        })   
        maskFiltPane.populateModule("Mask and Filter (" + infoStream.mask_filt.mf_issues + ")", temp)

        temp = ""
        infoStream.rtr.rtr_messages.forEach(function(item) {
            temp += ("• " + item) + "\n"
        })
        rtrPane.populateModule("Remote Transmission Request (" + infoStream.rtr.rtr_issues + ")", temp)

        temp = ""
        infoStream.idLen.idLen_messages.forEach(function(item) {
            temp += ("• " + item) + "\n"
        })
        idLenPane.populateModule("ID Length (" + infoStream.idLen.idLen_issues + ")", temp)

        temp = ""
        infoStream.dlc.dlc_messages.forEach(function(item) {
            temp += ("• " + item) + "\n"
        })
        dlcPane.populateModule("Data Length Code (" + infoStream.dlc.dlc_issues + ")", temp)

       temp = ""
        infoStream.dataPack.dataPack_messages.forEach(function(item) {
           temp += ("• " + item) + "\n"
        })
        bytePackingPane.populateModule("Data Byte Packing (" + infoStream.dataPack.dataPack_issues + ")", temp)

        if(infoStream.totalIssues === 0) {
            noIssueRect.visible = true
        }
        else {
            if(dataStream.AI_Enabled === false) {
                noAiRect.visible = true
            }
            else {
                var solutionText = ""
                dataStream.solutions.forEach(function(item) {
                    solutionText += (item + "\n")
                })
                suggestionTextBox.text = solutionText
                suggestionTextRect.visible = true
                console.log("width:", suggestionTextRect.width, suggestionRect.width)
            }
        }
        windowRoot.visible = true
    }
}