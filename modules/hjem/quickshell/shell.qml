import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
  // color: "#002b36"
  color: "transparent"

  Rectangle {
    // match the size of the window
    anchors.fill: parent

    radius: 8 
    color: "#002b36"  
  }

  anchors {
    top: true
    left: true
    right: true
  }

  margins {
    top: 4
    left: 4
    right: 4
  }

  implicitHeight: 30

  Text {
    property string title: MprisPlayer.isPlaying
    text: title

    color: "#DDDDDD"
 }

  Text {
    id: clock
    anchors.centerIn: parent
   
    color: "#DDDDDD"

    Process {
      // give the process object an id so we can talk
      // about it from the timer
      id: dateProc

      command: ["date"]
      running: true

      stdout: StdioCollector {
        onStreamFinished: clock.text = this.text
      }
    }

    // use a timer to rerun the process at an interval
    Timer {
      // 1000 milliseconds is 1 second
      interval: 1000

      // start the timer immediately
      running: true

      // run the timer again when it ends
      repeat: true

      // when the timer is triggered, set the running property of the
      // process to true, which reruns it if stopped.
      onTriggered: dateProc.running = true
    }
  }
}
