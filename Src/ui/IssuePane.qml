import QtQuick 6.10
import QtQuick.Controls 6.10

Item {
    visible: true
    implicitHeight: issueTextArea.contentHeight + 20
    implicitWidth: issueTextArea.contentWidth + 50

    property var scrollRef: null

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

    TextArea {
        id: issueTextArea
        anchors {
            top: issueTitleBar.bottom
            left: parent.left
            leftMargin: 10
        }
        topPadding: 3
        
        text: ""
        color: colorWay.textColor
        font.pixelSize: 25
        readOnly: true
        wrapMode: TextEdit.NoWrap
        background: Rectangle {
            color: colorWay.backgroundcolor2
            radius: 15
        }
    }

    function populateModule(titleString, issueString) {
        issueTitleText.text = titleString
        issueTextArea.text = issueString
    }
}