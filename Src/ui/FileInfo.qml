import QtQuick 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects 6.10
import QtQuick.Layouts 6.10

ApplicationWindow {
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
        color: backgroundcolor
        border.color: backgroundcolor2
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

            width: 0.55 * parent.width
            height: 0.55 * parent.height
            radius: 15
            color: backgroundcolor2

            ScrollView {
                id: viewSourceCode
                anchors.fill: parent
                anchors.margins: 6
                clip: true 

                ScrollBar.vertical: ScrollBar {
                    parent: viewSourceCode
                    x: viewSourceCode.mirrored ? 0 : viewSourceCode.width - width
                    y: viewSourceCode.topPadding
                    height: viewSourceCode.availableHeight
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: '#2e2e2e'
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        //radius: width / 2
                        color: backgroundcolor2
                    }
                }
                
                ScrollBar.horizontal: ScrollBar {
                    parent: viewSourceCode
                    x: viewSourceCode.leftPadding
                    y: viewSourceCode.height - height
                    width: viewSourceCode.availableWidth
                    policy: ScrollBar.AsNeeded
                    padding: 0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: '#2e2e2e'
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        //radius: width / 2
                        color: backgroundcolor2
                    }
                }

                background: Rectangle {
                    color: backgroundcolor2
                    radius: sourceCodeRect.radius
                }

                contentWidth: contentContainer.width
                contentHeight: contentContainer.height

                Item {
                    id: contentContainer
                    height: savedList.contentHeight 
                    width: Math.max(viewSourceCode.availableWidth, savedList.contentWidth) 

                    ListView {
                        id: savedList
                        anchors.fill: parent 
                        interactive: false  
                        orientation: Qt.Vertical
                        model: codeModel
                        boundsBehavior: Flickable.StopAtBounds
                        
                        delegate: Item {
                            width: parent.availableWidth; height: 35
                            
                            Rectangle {
                                id: delegateRect
                                anchors {
                                    fill: parent
                                    margins: 0
                                }
                                color: backgroundcolor2

                                Text {
                                    id: lineNum
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                        leftMargin: 2
                                    }
                                    text: line_index
                                    font.family: "Consolas"
                                    font.pixelSize: 25
                                    color: textColor
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Rectangle {
                                    id: lineNum_separatorbar
                                    anchors {
                                        left: lineNum.right
                                        top: parent.top
                                        bottom: parent.bottom
                                        leftMargin: 5
                                    }  
                                    width: 3
                                    color: "#1A1A1A"
                                }

                                Text {
                                    id: codeLine
                                    anchors {
                                        left: lineNum_separatorbar.right
                                        top: parent.top
                                        bottom: parent.bottom
                                        leftMargin: 8
                                    }
                                    text: code_line
                                    font.pixelSize: 25
                                    color: textColor
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

            height: 0.55 * parent.height
            radius: 10
            color: backgroundcolor2

            ScrollView {
                id: viewIssues
                anchors.fill: parent
                anchors.margins: 6
                clip: true 

                ScrollBar.vertical: ScrollBar {
                    parent: viewIssues
                    x: viewIssues.mirrored ? 0 : viewIssues.width - width
                    y: viewIssues.topPadding
                    height: viewIssues.availableHeight 
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    padding: 0

                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: width / 2
                        color: '#2e2e2e'
                    }
                    background: Rectangle {
                        implicitWidth: 10
                        color: backgroundcolor2
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    id: hBar
                    parent: viewIssues
                    x: viewIssues.leftPadding
                    y: viewIssues.height - height
                    width: viewIssues.availableWidth
                    policy: ScrollBar.AsNeeded
                    hoverEnabled: false
                    active: hovered || pressed

                    contentItem: Rectangle {
                        implicitHeight: 6
                        radius: height / 2
                        color: '#2e2e2e'
                    } 
                    background: Rectangle {
                        implicitHeight: 10
                        color: backgroundcolor2
                        opacity: 1
                    }
                }

                background: Rectangle {
                    color: backgroundcolor2
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
            color: backgroundcolor2
            radius: 15

            Text {
                anchors.centerIn: parent
                font.pixelSize: 30
                text: "LLM suggestions go here"
                color: textColor
            }
        }
    }

    function setFileInfo(code, infoStream) {
        console.log("setFileInfo called...")
        var temp = ""

        windowRoot.title = infoStream.file_name
        infoTitleBar.setTitleText(infoStream.file_name)
        for (var i = 0; i < code.length; i++) {
            var line = {
                "line_index": (i+1).toString().padStart(4, " "),
                "code_line": code[i]
            }
            codeModel.append(line)
        }
        
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
        infoStream.bytePacking.bytePacking_messages.forEach(function(item) {
            temp += ("• " + item) + "\n"
        })
        bytePackingPane.populateModule("Byte Packing (" + infoStream.bytePacking.bytePacking_issues + ")", temp)

        windowRoot.visible = true
    }
}