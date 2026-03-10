import QtQml 6.10
import QtQuick 6.10
import QtQuick.Window 6.10

Item {
    width: 600
    height: 275
    //modality: Qt.ApplicationModal 
    //flags: Qt.SplashScreen

    ColorWay {
        id: colorFile
    }

    Rectangle {
        id: splash_can_Rect
        anchors.fill: parent

        color: colorFile.accent1color
        radius: 30

        Rectangle {
            anchors {
                top: parent.top
                margins: 20
                horizontalCenter: parent.horizontalCenter
            }
            height: parent.height * 0.7
            width: whiteRect.textWidth + splash_can_txt.contentWidth
            color: "Transparent"

            Rectangle {
                property alias textWidth: statiText.contentWidth
                id: whiteRect
                anchors {
                   verticalCenter: parent.verticalCenter
                }
                color: colorFile.titleTextColor
                radius: 20
                width: statiText.contentWidth + 10
                height: statiText.contentHeight 

                Text {
                    id: statiText
                    color: colorFile.accent1color
                    text: "Stati"
                    anchors.centerIn: parent
                    //minimumPixelSize: 40
                    font.pixelSize: 100
                    fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Text {
                id: splash_can_txt
                color: colorFile.titleTextColor
                text: "CAN"
                anchors {
                    top: parent.top
                    left: whiteRect.right
                    bottom: parent.bottom
                    leftMargin: 5
                    topMargin: 20
                    bottomMargin: 20
                    rightMargin: 20
                }
                
                minimumPixelSize: 40
                font.pixelSize: 100
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }

        Text {
            id: splash_loading_txt
            color: colorFile.titleTextColor
            text: qsTr("Loading user preferences...")
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 20
            }
            height: parent.height * 0.3
            minimumPixelSize: 20
            font.pixelSize: 40
            font.weight: 200
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
        }
    }
}