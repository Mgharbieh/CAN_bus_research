import QtQuick 6.10
import QtQuick.Controls 6.10

Item {
    id: itemRoot
    visible: true
    implicitHeight: issueTextRect.height + 40
    implicitWidth: issueTextRect.width + 50

    property var scrollRef: null
    property var aiWorking: null
    signal issueSelected(string txt)

    Rectangle {
        id: issueTitleBar
        color: colorWay.accent1color
        x: scrollRef ? scrollRef.contentItem.contentX : 0
        width: scrollRef ? scrollRef.availableWidth - 12 : parent.availableWidth
        height: 40
        radius: 10

        Text {
            id: issueTitleText
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                topMargin: -2
                leftMargin: 5
            }
            text: ""
            width: parent.width - 5
            color: colorWay.titleTextColor
            minimumPixelSize: 10
            font.pixelSize: 30
            fontSizeMode: Text.Fit
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: issueTextRect
        anchors {
            top: issueTitleBar.bottom
            left: parent.left
            leftMargin: 10
        }
        
        height: issuePaneList.contentHeight + 10
        width: issuePaneList.contentItem.childrenRect.width + 10
        color: "transparent"

        ListView {
            id: issuePaneList
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                topMargin: 2
            }
            model: issuePaneModel
            clip: false
            interactive: false
            width: itemRoot.width
            spacing: 2

            delegate: Rectangle {
                property alias delegateWidth: delegateRect.width

                id: delegateRect
                width: issuePaneText.contentWidth + 5
                height: 30
                color: "transparent"
                //issueMouseArea.containsMouse ? colorWay.accent1color : "transparent"
                border.color: {
                    if ((issueMouseArea.containsMouse) && 
                    (issue_string.includes("No issues") || 
                    issue_string.includes("no issues") || 
                    issue_string.includes("no errors") ||
                    issue_string.includes("found")
                    )) {
                        return "transparent"
                    }
                    else if (issueMouseArea.containsMouse && root.aiEnabled == true) {
                        return colorWay.accent1color
                    }
                    else {
                        return "transparent"
                    }
                }
                border.width: 1
                radius: 5

                Text {
                    id:issuePaneText
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }
                    text: issue_string
                    color: colorWay.textColor
                    font.pixelSize: 25
                    wrapMode: Text.NoWrap
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: issueMouseArea
                    anchors.fill: delegateRect
                    hoverEnabled: true
                    cursorShape: {
                        if(root.aiEnabled === true) {
                            if(issue_string.includes("No issues") || 
                            issue_string.includes("no issues") || 
                            issue_string.includes("no errors") ||
                            issue_string.includes("found")) {
                                return Qt.ArrowCursor
                            }
                            else {
                                if(aiWorking) {
                                    return Qt.ForbiddenCursor
                                }
                                else {
                                    return Qt.PointingHandCursor
                                }  
                            }
                        }
                    }
                    onClicked: {
                        if(aiWorking == false && root.aiEnabled == true) {
                            issueSelected(issue_string.substring(2))
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: issuePaneModel
    }

    function populateModule(titleString, issueList) {
        issueTitleText.text = titleString
        //issueTextArea.text = issueString
        issueList.forEach(function(item) {
            issuePaneModel.append({"issue_string": "• " + item})
        })
    }
}