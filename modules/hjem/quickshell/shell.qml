import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

PanelWindow {
    id: bar

    // Colours
    property color colBg: "#ee002b36"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 28
    // color: "#ee002b36"
    color: "transparent"
    
    margins {
        top: 2
        left: 4
        right: 4
    }
    
    PopupWindow {
        id: timePopup
        anchor.window: bar 
        anchor.rect.x: parentWindow.width - 164  
        anchor.rect.y: parentWindow.height + 5 
        width: 164
        height: 180
        visible: false
        // color: "#7dffffff"
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 5

            color: bar.colBg 
        }
    }

    RowLayout {
        anchors.fill: parent

        WrapperRectangle { 
            margin: 5
            topMargin: 3
            color: bar.colBg
            radius: 5

            Row {
                spacing: 8  

                // Tonybtw my goat
                Repeater {
                    model: 9

                    Text {
                        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                        text: index + 1
                        color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                        font { pixelSize: 14; bold: true }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        WrapperRectangle {
            margin: 5
            topMargin: 3
            color: bar.colBg 
            radius: 5
            
            Text {
                property var currentPlayer: Mpris.players.values[0]

                

                id: music
                // text: (currentPlayer.playbackState != (MprisPlaybackState.Playing || MprisPlaybackState.Paused)) ? ("Nothing playing...") : (currentPlayer.trackArtist + " - " + currentPlayer.trackTitle + " - " + formatPosition(currentPlayer.position))
                text: "Nothing Playing..."
                color: "#7aa2f7"
                font { pixelSize: 14; bold: true }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Mpris.players.values[0].togglePlaying() 
                }

                Timer {
                    property var currentPlayer: Mpris.players.values[0]
  
                    function formatPosition(seconds) {
                        const mins = Math.floor(seconds / 60);
                        const secs = Math.floor(seconds) % 60;
                        return mins + ":" + (secs < 10 ? "0" + secs : secs);
                    }

                    // Only emit the signal when the position is actually changing.
                    running: currentPlayer.playbackState == MprisPlaybackState.Playing

                    interval: 1000
                    repeat: true
                    onTriggered: music.text = currentPlayer.trackArtist + " - " + currentPlayer.trackTitle + " - " + formatPosition(currentPlayer.position)
                }
            }
        }

        Item { Layout.fillWidth: true }

        SystemClock {
                id:clock
                precision: SystemClock.Minutes
        }

        WrapperRectangle { 
            id:dateRect
            margin: 5
            color: "#ee002b36"
            radius: 5

            Text {
                property bool isClicked: dateRect.color != bar.colBg

                text: Qt.formatDateTime(clock.date, "ddd, dd/MM/yy")
                color: "#7aa2f7"
                font { pixelSize: 13; bold: true }

                MouseArea {
                    function showClockPopup(color) {
                        if (color != "#ee002b36") {
                            dateRect.color = "#ee002b36";
                            timePopup.visible = false
                        } else {
                            dateRect.color = "#eedddddd";
                            timePopup.visible = true
                        }
                    }
                    anchors.fill: parent
                    // onClicked: (dateRect.color == "#ee002b36") ? (dateRect.color = "#eedddddd") : (dateRect.color = "#ee002b36") 
                    onClicked: showClockPopup(dateRect.color)
                } 
            }
        }

        WrapperRectangle { 
            id:timeRect
            margin: 5
            color: bar.colBg 
            radius: 5

            Text {
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: "#7aa2f7"
                font { pixelSize: 13; bold: true }

                MouseArea {
                    anchors.fill: parent
                    onClicked: (timeRect.color == "#ee002b36") ? (timeRect.color = "#eedddddd") : (timeRect.color = "#ee002b36") 
                } 
            }
        } 
    }
}

