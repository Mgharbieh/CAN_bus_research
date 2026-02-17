import QtQml 6.10
import QtQuick 6.10
import QtQuick.Effects 6.10

// "#0078D7"

Item {

    property var lightMode: {
        "accent1color": "#144F85",
        "backgroundcolor": "#FFFFFF",
        "backgroundcolor2": "#F3F3F3",
        "textColor": "#000000",
        "focusColor": "#808b8b8b",
        "itemColor": '#a6a6a6',
        "separatorColor": "#b3b3b3"
    }

    property var darkMode: {
        "accent1color": "#144F85",
        "backgroundcolor": "#141414",
        "backgroundcolor2":"#242424",
        "textColor": "#FFFFFF",
        "focusColor": "#808b8b8b",
        "itemColor": "#2E2E2E",
        "separatorColor": "#1A1A1A"
    }

    property var colorMode: lightMode

    property string accent1color:colorMode.accent1color
    property string backgroundcolor: colorMode.backgroundcolor
    property string backgroundcolor2: colorMode.backgroundcolor2
    property string textColor: colorMode.textColor
    property string focusColor: colorMode.focusColor
    property string itemColor: colorMode.itemColor
    property string separatorColor: colorMode.separatorColor

    function switchColorMode(mode) {
        if(mode === 1) { colorMode = darkMode }
        else if(mode === 0) { colorMode = lightMode }
    }
}