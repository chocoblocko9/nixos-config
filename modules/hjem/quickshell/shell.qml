import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire                   
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    // Colours
    property color colBg: "#ee002b36"
    property color colBgInvert: "#eedddddd"
    property color colText: "#7aa2f7"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 36 
    color: 'transparent'

    
    PopupWindow {
        id: timePopup
        anchor.window: bar 
        anchor.rect.x: parentWindow.width - 164  
        anchor.rect.y: parentWindow.height + 5 
        implicitWidth: 200 
        implicitHeight: 180
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

        WrapperMouseArea {

            onClicked: Quickshell.execDetached([ "runapp", "pavucontrol" ])

            WrapperRectangle {
                id:pwRect
                margin: 6
                rightMargin: 9 
                leftMargin: 9
                color: bar.colBg 
                radius: 5

                PwObjectTracker {
                    property PwNode defSink: Pipewire.defaultAudioSink
                    objects: [defSink]
                }
                // Just show volume, click to open pavucontrol
                Text {
                    property PwNode defSink: Pipewire.defaultAudioSink
                    property var defVolume: Math.round(defSink.audio.volume * 100)
                    function pickIcon(volume) {
                        if (volume > 50) {
                            return "   ";
                        } else if (volume > 15) {
                            return "  ";
                        } else {
                            return "  ";
                        }
                    }
                
                    text: pickIcon(defVolume) + defVolume + "%"
                    // text: defVolume
                    color: bar.colText
                    font { pixelSize: 14; bold: true }
                }
            }
        }

        WrapperRectangle {
            margin: 6
            rightMargin: 9 
            leftMargin: 9
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

        WrapperMouseArea {
            function showClockPopup(color) {
                if (color != bar.colBg) {
                    dateRect.color = bar.colBg;
                    timePopup.visible = false
                } else {
                    dateRect.color = bar.colBgInvert;
                    timePopup.visible = true
                }
            }
            // onClicked: (dateRect.color == "#ee002b36") ? (dateRect.color = "#eedddddd") : (dateRect.color = "#ee002b36") 
            onClicked: showClockPopup(dateRect.color)

            WrapperRectangle { 
                id:dateRect
                margin: 5
                color: bar.colBg
                radius: 5

                Text {
                    property bool isClicked: dateRect.color != bar.colBg

                    text: Qt.formatDateTime(clock.date, "ddd, dd/MM/yy")
                    color: "#7aa2f7"
                    font { pixelSize: 13; bold: true }
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
                    onClicked: (timeRect.color == bar.colBg) ? (timeRect.color = bar.colBgInvert) : (timeRect.color = bar.colBg) 
                } 
            }
        } 
    }
}

