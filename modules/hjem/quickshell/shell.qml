import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: "#cc002b36"
    // color: "transparent"

    margins {
        top: 4
        left: 4
        right: 4
    }

    RowLayout {
        anchors.margins: 8
        anchors.fill: parent

        // Tony my goat
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

        Item { Layout.fillWidth: true }

        Text {
            property var currentPlayer: Mpris.players.values[0]

            function formatPosition(seconds) {
                const mins = Math.floor(seconds / 60);
                const secs = Math.floor(seconds) % 60;
                return mins + ":" + (secs < 10 ? "0" + secs : secs);
            }

            id: music
            text: (currentPlayer.playbackState == MprisPlaybackState.Stopped) ? ("Nothing playing...") : (currentPlayer.trackArtist + " - " + currentPlayer.trackTitle + " - " + formatPosition(currentPlayer.position))
            color: "#7aa2f7"
            font { pixelSize: 14; bold: true }

            MouseArea {
                anchors.fill: parent
                onClicked: Mpris.players.values[0].togglePlaying() 
            }

            Timer {
                property var currentPlayer: Mpris.players.values[0]

                // Only emit the signal when the position is actually changing.
                running: currentPlayer.playbackState == MprisPlaybackState.Playing

                interval: 1000
                repeat: true
                // Honestly man don't even worry about it 
                onTriggered: music.text = currentPlayer.trackArtist + " - " + currentPlayer.trackTitle + " - " + (Math.floor(currentPlayer.position / 60)) + ":" + (((Math.floor(currentPlayer.position) % 60) < 10) ? ("0" + (Math.floor(currentPlayer.position) % 60)) : (Math.floor(currentPlayer.position) % 60))
            }
        }

        Item { Layout.fillWidth: true }

        SystemClock {
            id:clock
            precision: SystemClock.Minutes
        }

        Text {
            text: Qt.formatDateTime(clock.date, "ddd, dd/MM/yy - hh:mm")
            color: "#7aa2f7"
            font { pixelSize: 12; bold: true }
        }
    }
}

