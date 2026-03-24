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
        "secondaryTextColor": "#969696", 
        "titleTextColor": "#FFFFFF",
        "focusColor": "#808b8b8b",
        "itemColor": '#a6a6a6',
        "separatorColor": "#b3b3b3",
        "gradientColor1": "#80FFFFFF",
        "gradientColor2": "#00FFFFFF",
        "deleteIconSrc": "./assets/delete-light.png",
        "cecsIconSrc": "./assets/CECS_2.png",
        "noAiIconSrc": "./assets/robot_black.png",
        "noIssueSrc": "./assets/confetti_black.png"
    }

    property var lightModeHC: {
        "accent1color": "#00315F",      // Darkened for better contrast on white
        "backgroundcolor": "#FFFFFF",   // Keep pure white
        "backgroundcolor2": "#FFFFFF",  // Remove the soft grey; use white for max contrast
        "textColor": "#000000",         // Pure black
        "secondaryTextColor": "#000000", 
        "titleTextColor": "#FFFFFF",
        "focusColor": "#80000000",        // Solid black outline for focus
        "itemColor": "#E6E6E6",         // Slightly darker grey for visibility
        "separatorColor": "#000000",     // Black lines instead of soft grey
        "gradientColor1": "#80FFFFFF",
        "gradientColor2": "#00FFFFFF",
        "deleteIconSrc": "./assets/delete-lightHC.png",
        "cecsIconSrc": "./assets/CECS_2.png",
        "noAiIconSrc": "./assets/robot_black.png",
        "noIssueSrc": "./assets/confetti_black.png"
    }

    property var darkMode: {
        "accent1color": "#144F85",
        "backgroundcolor": "#141414",
        "backgroundcolor2":"#242424",
        "textColor": "#FFFFFF",
        "secondaryTextColor": "#969696", 
        "titleTextColor": "#FFFFFF",
        "focusColor": "#808b8b8b",
        "itemColor": "#2E2E2E",
        "separatorColor": "#1A1A1A",
        "gradientColor1": "#80141414",
        "gradientColor2": "#00000000",
        "deleteIconSrc": "./assets/delete-dark.png",
        "cecsIconSrc": "./assets/CECS_dark.png",
        "noAiIconSrc": "./assets/robot_white.png",
        "noIssueSrc": "./assets/confetti_white.png"
    }

    property var darkModeHC: {
        "accent1color": "#4DABFF",      // Brightened significantly to pop against black
        "backgroundcolor": "#000000",   // Pure black (OLED style)
        "backgroundcolor2": "#000000",  // Consistency is key for HC
        "textColor": "#FFFFFF",         // Pure white
        "secondaryTextColor": "#FFFFFF", 
        "titleTextColor": "#000000",
        "focusColor": "#80FFFFFF",        // White focus ring
        "itemColor": "#333333",         // Defined containers
        "separatorColor": "#FFFFFF",    // White separators for clear sectioning
        "gradientColor1": "#80000000",
        "gradientColor2": "#00000000",
        "deleteIconSrc": "./assets/delete-darkHC.png",
        "cecsIconSrc": "./assets/CECS_dark_hc.png",
        "noAiIconSrc": "./assets/robot_white.png",
        "noIssueSrc": "./assets/confetti_white.png"
    }

    property var colorMode: lightMode
    property bool highContrastState: false

    property string accent1color:colorMode.accent1color
    property string backgroundcolor: colorMode.backgroundcolor
    property string backgroundcolor2: colorMode.backgroundcolor2
    property string textColor: colorMode.textColor
    property string secondaryTextColor: colorMode.secondaryTextColor
    property string titleTextColor: colorMode.titleTextColor
    property string focusColor: colorMode.focusColor
    property string itemColor: colorMode.itemColor
    property string separatorColor: colorMode.separatorColor
    property string gradientColor1: colorMode.gradientColor1
    property string gradientColor2: colorMode.gradientColor2
    property string deleteIconSrc: colorMode.deleteIconSrc
    property string cecsIconSrc: colorMode.cecsIconSrc
    property string noAiIconSrc: colorMode.noAiIconSrc
    property string noIssueSrc: colorMode.noIssueSrc

    function switchColorMode(mode) {
        if(mode === 1) {
            colorMode = darkMode 
            highContrastMode(highContrastState)
        }
        else if(mode === 0) { 
            colorMode = lightMode
            highContrastMode(highContrastState)
        }
    }

    function highContrastMode(mode) {
        console.log("highContrastMode called", mode)
        highContrastState = mode
        if(mode === 0 && colorMode === lightModeHC) {colorMode = lightMode}
        else if(mode === 1 && colorMode === lightMode) {colorMode = lightModeHC}
        else if(mode === 1 && colorMode === darkMode) {colorMode = darkModeHC}
        else if(mode === 0 && colorMode === darkModeHC) {colorMode = darkMode}
    }

    function changeTheme(mode, contrast) {
        if(mode === 0 && contrast === 0) {colorMode = lightMode}
        else if(mode === 0 && contrast === 1) {colorMode = lightModeHC}
        else if(mode === 1 && contrast === 0) {colorMode = darkMode}
        else if(mode === 1 && contrast === 1) {colorMode = darkModeHC}
    }
}