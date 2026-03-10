pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

ComboBox {
    id: control
    model: []
    font.pixelSize: 20

    delegate: ItemDelegate {
        property alias hoverTarget: hoverHandler1
        id: delegate

        required property var model
        required property int index

        width: control.width
        contentItem: Text {
            text: delegate.model[control.textRole]
            color: delegate.hovered || delegate.highlighted ? colorWay.titleTextColor : colorWay.textColor
            font: control.font
            elide: Text.ElideRight
            leftPadding: 5
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index

        background: Rectangle {
            color: delegate.hovered || delegate.highlighted ? colorWay.accent1color : "transparent"
            radius: 2
        }

        HoverHandler {
            id: hoverHandler1
            cursorShape:Qt.PointingHandCursor
        }
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        /*
        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }
        */

        Connections {
            target: hoverHandler3
            function onHoveredChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle =  hoverHandler3.hovered ? colorWay.accent1color : colorWay.separatorColor; //control.pressed
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: colorWay.textColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        border.color: hoverHandler2.hovered ? colorWay.accent1color : colorWay.separatorColor
        border.width: control.visualFocus ? 2 : 1
        color: backgroundcolor
        radius: 2

        HoverHandler {
            id: hoverHandler2
            cursorShape: Qt.PointingHandCursor
        }
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: colorWay.backgroundcolor2
            color: colorWay.backgroundcolor
            radius: 2
        }
    }

    HoverHandler {
        id: hoverHandler3
    }
}