// QuickShell 0.3.0 
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ShellRoot {
    id: root

    // ── Theme ────────────────────────────────────────────────────────
    property color colBg:            "#0a1a24"
    property color colBgLight:       "#0f2833"
    property color colBgWidget:      "#80132e3c"  // semi-transparent widget fill
    property color colBgWidgetHover: "#38132e3c"  // slightly more opaque on hover
    property color colBorder:        "#30179eb8"  // subtle cyan-tinted border
    property color colBorderActive:  "#500db9d7"  // brighter border for active/hover
    property color colFg:            "#b8d4e3"    // grey-ish text
    property color colFgDim:         "#5a8a9e"
    property color colAccent:        "#0db9d7"
    property color colAccent2:       "#0090b0"
    property color colGreen:         "#2dd4a8"
    property color colYellow:        "#e0c868"
    property color colRed:           "#e06070"
    property color colSeparator:     "#1a3a4a"
    property color colGlow:          "#180db9d7"  // bottom bar glow

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13
    property int barHeight: 34 
    property int barRadius: 0
    property int widgetRadius: 8
    property int widgetSpacing: 5

    // ── Dropdown state ───────────────────────────────────────────────
    property bool controlCenterOpen: false
    property bool mediaDropdownOpen: false
    property bool audioDropdownOpen: false

    // ── MPRIS player selection ───────────────────────────────────────
    property var selectedMpris: null // Currently chosen player
    property string preferredPlayerName: "Lollypop" // Preferred player to fall back to if none is chosen (start-up)

    // The "current" player aka whatever the rest of the UI should show 
    // priority top to bottom
    readonly property var currentMpris: {
        var players = Mpris.players.values
        if (!players || players.length === 0) return null

        // 1. User selection, if still alive
        if (selectedMpris && players.indexOf(selectedMpris) >= 0) {
            return selectedMpris
        }

        // 2. Preferred player by identity
        if (preferredPlayerName) {
            var needle = preferredPlayerName.toLowerCase()
            for (var i = 0; i < players.length; i++) {
                var p = players[i]
                var id = (p.identity || "").toLowerCase()
                var bus = (p.dbusName || "").toLowerCase()
                if (id.indexOf(needle) >= 0 || bus.indexOf(needle) >= 0) {
                    return p
                }
            }
        }

        // 3. Fallback to first available
        return players[0]
    }

    // Cycle through players, used by the little chip in the media dropdown.
    function cycleMpris() {
        var players = Mpris.players.values
        if (!players || players.length <= 1) return
        var cur = currentMpris
        var idx = players.indexOf(cur)
        var next = players[(idx + 1) % players.length]
        selectedMpris = next
    }

    // ── Notification server ──────────────────────────────────────────
    NotificationServer {
        id: notifServer
        keepOnReload: true
        onNotification: notification => {
          if (dndOn) { // DND immediately expires notifications
                       // but doesn't block discord ping, TODO?
                notification.expire()
                return
            }
            notification.tracked = true
            notifModel.insert(0, { notif: notification })
        }
    }

    ListModel { id: notifModel }

    // ── System data ──────────────────────────────────────────────────
    property int cpuUsage: 0
    property int memUsage: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    property string idBadge: ""
    property string uptimeStr: ""
    property int batteryPercent: -1 // set impossible default to hide battery on slip
    property string batteryStatus: ""
    property string networkName: ""
    property string networkIcon: "󰤭"
    property string weatherText: ""
    property string weatherIcon: ""
    property string weatherTemp: ""
    property string weatherLocation: ""
    property string weatherDesc: ""
    property bool bluetoothOn: true
    property bool dndOn: false 

    // ── Pipewire Handler ───────────────────────────────────────────── 

    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    property PwNodeAudio output: sink ? sink.audio : null
    property PwNodeAudio input: source ? source.audio : null

    property int outputVolumePercent: output ? Math.floor(output.volume * 100) : 0

    PwObjectTracker { objects: [
      sink, // track main output
      source // track main input (might be useful?)
    ] }

    // All output sinks (for device picker)
    readonly property var allSinks: {
        var out = []
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            if (n && n.isSink && !n.isStream && n.audio) {
                out.push(n)
            }
        }
        return out
    }

    // All application output streams (things playing INTO a sink) — these
    // are what show up in pavucontrol's "Playback" tab.
    readonly property var appStreams: {
        var out = []
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            if (n && n.isStream && !n.isSink && n.audio) {
                // TODO: fix this, my logic is wrong i think
                out.push(n)
            }
        }
        return out
    }

    // Track every sink + stream so their properties stay live.
    PwObjectTracker {
        objects: {
            var arr = []
            var s = allSinks
            var a = appStreams
            for (var i = 0; i < s.length; i++) arr.push(s[i])
            for (var j = 0; j < a.length; j++) arr.push(a[j])
            return arr
        }
    }

    // ── Processes ────────────────────────────────────────────────────

    Process {
        id: userProc
        command: ["sh", "-c", "echo \"$(whoami)@$(hostname)\""]
        stdout: SplitParser { onRead: idBadge = data } // This is bad apprently? whatever bro
        // Still needs to be SplitParser otherwise it has like 3 extra empty lines
        Component.onCompleted: running = true
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null) $(cat /sys/class/power_supply/BAT0/status 2>/dev/null)\" || echo 'NONE'"]
        Component.onCompleted: running = true
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === " ") {
                    batteryPercent = -1 
                    return
                }
                var lines = data.split(" ")
                if (!isNaN(lines[0])) { batteryPercent = lines[0] } 
                batteryStatus = lines[1]
            }
        }
    }

    Process {
        id: networkProc
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | head -1"]
        Component.onCompleted: running = true
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) {
                    networkName = "Disconnected"
                    networkIcon = "󰤭"
                    return
                }
                var parts = data.trim().split(":")
                networkName = parts[0] || "Connected"
                var type = parts[1] || ""
                if (type.indexOf("wireless") >= 0 || type.indexOf("wifi") >= 0) {
                    networkIcon = "󰤨"
                } else if (type.indexOf("ethernet") >= 0) {
                    networkIcon = "󰈀"
                } else {
                    networkIcon = "󰛳"
                }
            }
        }
    }

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s 'wttr.in/?format=%c+%t+%l+%C' 2>/dev/null || echo ''"]
        Component.onCompleted: running = true
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return
                var parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    weatherIcon = parts[0]
                    weatherTemp = parts[1] || ""
                    if (parts.length >= 3) weatherLocation = parts[2] || ""
                    if (parts.length >= 4) weatherDesc = parts.slice(3).join(" ")
                } else {
                    weatherTemp = data.trim()
                }
            }
        }
    }

    // ── Timers ───────────────────────────────────────────────────────
    Timer {
        interval: 10000; running: true; repeat: true
        onTriggered: {
            batteryProc.running = true
            networkProc.running = true
        }
    }

    Timer {
        interval: 600000; running: true; repeat: true
        onTriggered: weatherProc.running = true
    }

    Timer {
        id: ccCloseDelay
        interval: 200 
        onTriggered: controlCenterOpen = false
    }

    Timer {
        id: mediaCloseDelay
        interval: 200
        onTriggered: mediaDropdownOpen = false
    }

    Timer {
        id: audioCloseDelay
        interval: 200
        onTriggered: audioDropdownOpen = false
    }

    // ── Cava data ────────────────────────────────────────────────────
    property var cavaData: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Process {
        id: cavaProc
        command: ["sh", "-c", "cava -p /dev/stdin <<< '[general]\nbars=24\nframerate=30\n[output]\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100\n'"]
        running: (root.currentMpris?.isPlaying ?? false)
        // uncomment the end if you want to be LAME and OPTIMISED but I like the cava actually working
        // when I open the centre instead of having to restart every time, cava is light anyways
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return
                var vals = data.trim().split(";")
                var arr = []
                for (var i = 0; i < vals.length && i < 24; i++) {
                    arr.push(parseInt(vals[i]) || 0)
                }
                while (arr.length < 24) arr.push(0)
                cavaData = arr
            }
        }
    }

    // ── Bar (per-screen) ─────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: barHeight
            color: "#CC0a1a24"

            // Bottom edge glow
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: colBorder
            }

            // Subtle gradient fade at bottom
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 6
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: colGlow }
                }
            }

            // ── Control Center Popup ─────────────────────────────────
            LazyLoader {
                loading: controlCenterOpen

                PopupWindow {
                    id: controlCenter
                    anchor.window: barWindow
                    anchor.rect.x: barWindow.width - 320
                    anchor.rect.y: barHeight
                    implicitWidth: 310
                    implicitHeight: ccColumn.implicitHeight + 36
                    visible: controlCenterOpen
                    color: "transparent"

                    onVisibleChanged: {
                        if (!visible) controlCenterOpen = false
                    }

                    HoverHandler {
                        id: ccHover
                        onHoveredChanged: {
                            if (hovered) {
                                ccCloseDelay.stop()
                                controlCenterOpen = true
                            } else {
                                ccCloseDelay.start()
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 12
                        color: "#EE0a1a24"
                        border.color: colBorder
                        border.width: 1

                        Column {
                            id: ccColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 10

                            // ── Quick toggles ────────────────────────
                            Row {
                                spacing: 8
                                anchors.horizontalCenter: parent.horizontalCenter

                                // WiFi
                                Rectangle {
                                    width: 42; height: 42; radius: 10
                                    color: networkName !== "Disconnected" ? colAccent : colBgWidget
                                    Text {
                                        anchors.centerIn: parent
                                        text: networkIcon
                                        color: networkName !== "Disconnected" ? colBg : colFgDim
                                        font { family: fontFamily; pixelSize: 18 }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                // Bluetooth
                                Rectangle {
                                    width: 42; height: 42; radius: 10
                                    color: bluetoothOn ? colAccent : colBgWidget
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰂯"
                                        color: bluetoothOn ? colBg : colFgDim
                                        font { family: fontFamily; pixelSize: 18 }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: bluetoothOn = !bluetoothOn
                                    }
                                }

                                // DND
                                Rectangle {
                                    width: 42; height: 42; radius: 10
                                    color: dndOn ? colAccent : colBgWidget
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰂛"
                                        color: dndOn ? colBg : colFgDim
                                        font { family: fontFamily; pixelSize: 18 }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: dndOn = !dndOn
                                    }
                                }
                            }

                            // ── Separator ────────────────────────────
                            Rectangle { width: parent.width; height: 1; color: colSeparator }

                            // ── Network card ─────────────────────────
                            Rectangle {
                                width: parent.width; height: 50; radius: 10
                                color: colBgWidget

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Rectangle {
                                        width: 30; height: 30; radius: 8
                                        color: networkName !== "Disconnected" ? colGreen : colBgLight
                                        Text {
                                            anchors.centerIn: parent
                                            text: networkIcon
                                            color: networkName !== "Disconnected" ? colBg : colFgDim
                                            font { family: fontFamily; pixelSize: 14 }
                                        }
                                    }

                                    Column {
                                        spacing: 1
                                        Text {
                                            text: networkName
                                            color: colFg
                                            font { family: fontFamily; pixelSize: fontSize; bold: true }
                                            elide: Text.ElideRight
                                            width: 215 
                                        }
                                        Text {
                                            text: networkName !== "Disconnected" ? "Connected" : "No connection"
                                            color: colFgDim
                                            font { family: fontFamily; pixelSize: fontSize - 2 }
                                        }
                                    }
                                }
                            }

                            // ── Weather card ─────────────────────────
                            Rectangle {
                                visible: weatherTemp !== ""
                                width: parent.width; height: 60; radius: 10
                                color: colBgWidget

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        text: weatherIcon || "󰖐"
                                        font { family: fontFamily; pixelSize: 28 }
                                        color: colYellow
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            text: weatherTemp
                                            color: colFg
                                            font { family: fontFamily; pixelSize: fontSize + 4; bold: true }
                                        }
                                        Text {
                                            text: {
                                                var p = []
                                                if (weatherLocation) p.push(weatherLocation)
                                                if (weatherDesc) p.push(weatherDesc)
                                                return p.join(", ") || "Weather"
                                            }
                                            color: colFgDim
                                            font { family: fontFamily; pixelSize: fontSize - 2 }
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // ── Volume slider ────────────────────────
                            Rectangle {

                                // TODO: make it look actually good
                                width: parent.width; height: 50; radius: 10
                                color: colBgWidget

                                RowLayout {

                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        text: (output && output.muted) ? "󰝟" : (outputVolumePercent > 50 ? "󰕾" : "󰖀")
                                        color: (output && output.muted) ? colRed : colAccent
                                        font { family: fontFamily; pixelSize: 16 }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: { if (output) output.muted = !output.muted }
                                        }
                                    }

                                    Slider {
                                        id: ccVolumeSlider

                                        Layout.fillWidth: true
                                        value: output ? output.volume : 0
                                        onValueChanged: { if (output) output.volume = value }

                                        handle: Rectangle {
                                            x: ccVolumeSlider.leftPadding + ccVolumeSlider.visualPosition * (ccVolumeSlider.availableWidth - width)
                                            y: ccVolumeSlider.topPadding + ccVolumeSlider.availableHeight / 2 - height / 2
                                            implicitWidth: 6
                                            implicitHeight: 16
                                            radius: 4 
                                        }

                                        background: Rectangle {
                                            anchors.centerIn: parent
                                            color: colFg
                                            implicitWidth: 200
                                            implicitHeight: 6
                                            width: ccVolumeSlider.availableWidth
                                            height: implicitHeight
                                            radius: 3

                                            Rectangle {
                                                width: ccVolumeSlider.visualPosition * parent.width
                                                height: parent.height
                                                color: colAccent
                                                radius: 3
                                            }
                                        }
                                    }

                                    Text {
                                        text: outputVolumePercent + "%"
                                        color: colFg
                                        font { family: fontFamily; pixelSize: fontSize }
                                        Layout.preferredWidth: 30
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }

                            // ── Battery card (if present) ────────────
                            Rectangle {
                                visible: batteryPercent >= 0
                                width: parent.width; height: 50; radius: 10
                                color: colBgWidget

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        text: {
                                            if (batteryStatus == "Full" ) return ""
                                            if (batteryStatus == "Charging" ) return "󰂄"
                                            if (batteryPercent > 80) return "󰁹"
                                            if (batteryPercent > 60) return "󰂀"
                                            if (batteryPercent > 40) return "󰁾"
                                            if (batteryPercent > 20) return "󰁻"
                                            return "󰂃"
                                        }
                                        color: {
                                            if (batteryStatus == "Full" || batteryStatus == "Charging") return colGreen
                                            if (batteryPercent > 40) return colFg
                                            if (batteryPercent > 20) return colYellow
                                            return colRed
                                        }
                                        font { family: fontFamily; pixelSize: 16 }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 6; radius: 3
                                        color: colSeparator
                                        Rectangle {
                                            width: parent.width * (batteryPercent / 100)
                                            height: parent.height; radius: 3
                                            color: {
                                                if (batteryStatus == "Charging") return colGreen
                                                if (batteryPercent > 40) return colAccent
                                                if (batteryPercent > 20) return colYellow
                                                return colRed
                                            }
                                            Behavior on width { NumberAnimation { duration: 300 } }
                                        }
                                    }

                                    Text {
                                        text: batteryPercent + "%"
                                        color: colFg
                                        font { family: fontFamily; pixelSize: fontSize - 1 }
                                        Layout.preferredWidth: 30
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }

                            // ── System tray ──────────────────────────
                            Rectangle {
                                visible: trayRow.children.length > 0
                                width: parent.width; height: 42; radius: 10
                                color: colBgWidget

                                Flow {
                                    id: trayRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Repeater {
                                        model: SystemTray.items

                                        Item {
                                            required property var modelData
                                            width: 32; height: 32

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 6
                                                color: trayMouse.containsMouse ? colBgLight : "transparent"
                                            }

                                            Image {
                                                anchors.centerIn: parent
                                                source: modelData.icon ?? ""
                                                width: 18; height: 18
                                                sourceSize.width: 18
                                                sourceSize.height: 18
                                            }

                                            MouseArea {
                                                id: trayMouse
                                                anchors.fill: parent
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: mouse => {
                                                    if (mouse.button === Qt.RightButton) {
                                                        if (modelData.hasMenu) {
                                                            modelData.display(barWindow, barWindow.width - 320 + mouse.x, barHeight + mouse.y)
                                                        }
                                                    } else {
                                                        modelData.activate()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            

            // ── Notification toasts ──────────────────────────────────
            PopupWindow {
                id: notifPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 364 // fits with my hyprland windows
                anchor.rect.y: barHeight + 10        // cus that's cool I think
                implicitHeight: notifToastCol.implicitHeight + 12
                implicitWidth: 350
                visible: notifModel.count > 0 && !controlCenterOpen
                color: "transparent"

                Column {
                    id: notifToastCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 6
                    spacing: 6

                    Repeater {
                        model: notifModel

                        Rectangle {
                            required property var notif
                            required property int index

                            id: panel
                            x: 350 
                            width: parent.width
                            height: notifContent.implicitHeight + 20
                            radius: 10
                            color: "#EE0a1a24"
                            border.color: colBorder
                            border.width: 1

                            states: [
                                State {
                                    name: "visible"
                                    PropertyChanges { target: panel; x: 0 } // Move on-screen
                                }
                            ]

                            // What the fuck am I cooking
                            transitions: [
                                Transition {
                                    from: ""; to: "visible"; reversible: true
                                    NumberAnimation { 
                                        id: notifAnimation
                                        properties: "x"; 
                                        duration: 180; 
                                        easing.type: Easing.InOutBack
                                    }
                                }
                            ]

                            // TODO: Figure out the right way to do this
                            // It's fine cus Qt timers are speedy but this is dumb I think?

                            // especially this, others are like eh but SURELY 
                            // u can do this better
                            Timer {
                                interval: 10 
                                running: true 
                                onTriggered: panel.state = "visible"
                            }

                            Timer {
                                interval: 7000
                                running: true
                                onTriggered: panel.state = ""
                            }

                            Timer {
                                interval: 7000 + notifAnimation.duration
                                running: true
                                onTriggered: notifModel.remove(index) 
                                // dismisses after animation so it doesn't just disappear
                                // but still stay off screen lol
                            }

                            Column {
                                id: notifContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                RowLayout {
                                    width: parent.width
                                    spacing: 6

                                    Text {
                                        text: "󰂚"
                                        color: colAccent
                                        font { family: fontFamily; pixelSize: fontSize }
                                    }

                                    Text {
                                        text: notif.appName ?? "Notification"
                                        color: colFg
                                        font { family: fontFamily; pixelSize: fontSize; bold: true }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "󰅖"
                                        color: colFgDim
                                        font { family: fontFamily; pixelSize: fontSize }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (notif && notif.tracked) {
                                                    notif.dismiss()
                                                }
                                                notifModel.remove(index)
                                            }
                                        }
                                    }
                                }

                                RowLayout { 
                                    width: parent.width
                                    spacing: 10

                                    IconImage {
                                        source: notif.image ?? ""
                                        visible: (notif.image ?? "") !== ""
                                        implicitSize: 50
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 50
                                        Layout.alignment: Qt.AlignTop
                                    }
                                    
                                    Column { 
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            visible: notif && notif.summary
                                            text: notif.summary ?? ""
                                            color: colFg
                                            font { family: fontFamily; pixelSize: fontSize - 1; bold: true }
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: notif && notif.body
                                            text: notif.body ?? ""
                                            color: colFgDim
                                            font { family: fontFamily; pixelSize: fontSize - 1 }
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                z: -1
                                onClicked: {
                                    if (notif && notif.tracked) {
                                        notif.dismiss()
                                    }
                                    notifModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }

            // ── Main bar layout ──────────────────────────────────────
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: widgetSpacing

                // ═══════════════ LEFT ════════════════════════════════

                // User info
                Rectangle {
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: userRow.implicitWidth + 18
                    radius: widgetRadius
                    color: colBgWidget
                    border.color: colBorder
                    border.width: 1

                    RowLayout {
                        id: userRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: ""
                            color: colAccent
                            font { family: fontFamily; pixelSize: fontSize + 2 }
                        }
                        Text {
                            // text: username + "@" + hostname
                            text: idBadge
                            color: colFg 
                            font { family: fontFamily; pixelSize: fontSize; bold: true }
                        }
                    }
                }

                // ═══════════════ WORKSPACES ══════════════════════════

                Rectangle {
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: wsRow.implicitWidth + 14
                    radius: widgetRadius
                    color: colBgWidget
                    border.color: colBorder
                    border.width: 1

                    Row {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: 9

                            Item {
                                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                                property bool hovered: false

                                width: 8
                                height: barHeight - 8

                                Rectangle {
                                    anchors.centerIn: parent

                                    width: isActive ? 7 : (hovered ? 7 : (ws ? 5 : 4))
                                    height: isActive ? 16 : (hovered ? 12 : (ws ? 8 : 4))
                                    radius: width / 2

                                    color: isActive ? colAccent
                                         : hovered ? colAccent2
                                         : ws ? colAccent2
                                         : colSeparator

                                    opacity: isActive ? 1.0 : (hovered ? 0.85 : (ws ? 0.6 : 0.4))

                                    Behavior on width   { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                    Behavior on height  { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                    Behavior on color   { ColorAnimation  { duration: 120 } }
                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: hovered = true
                                    onExited: hovered = false
                                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                                }
                            }
                        }
                    }
                }

                // ═══════════════ MIDDLE ══════════════════════════════
 
                Item { Layout.fillWidth: true }

                // ═══════════════ RIGHT ══════════════════════════════

                // Volume & Battery — now hoverable, opens audio manager
                Rectangle {
                    id: volBatWidget
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: volBatRow.implicitWidth + 14
                    radius: widgetRadius
                    color: audioDropdownOpen ? colAccent2 : colBgWidget
                    border.color: audioDropdownOpen ? colBorderActive : colBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 125 } }
                    Behavior on border.color { ColorAnimation { duration: 125 } }

                    RowLayout {
                        id: volBatRow
                        anchors.centerIn: parent
                        spacing: 8

                        RowLayout {

                            Text {
                                text: (output && output.muted) ? "󰝟" : (outputVolumePercent > 50 ? "󰕾" : "󰖀")
                                color: (output && output.muted) ? colRed : (audioDropdownOpen ? colBg : colFg)
                                font { family: fontFamily; pixelSize: fontSize + 3 }
                            }
                            Text {
                                text: outputVolumePercent + "%"
                                color: audioDropdownOpen ? colBg : colFg
                                font { family: fontFamily; pixelSize: fontSize + 1 }
                            }
                        }

                        Rectangle { width: 1; height: 14; color: colSeparator; visible: batItem.visible ? true : false  }

                        WrapperItem {
                            id: batItem
                            visible: batteryPercent >= 0

                            RowLayout {
                                id: batRow
                                anchors.centerIn: parent

                                Text {
                                    text: {
                                        if (batteryStatus == "Full") return ""
                                        if (batteryStatus == "Charging") return "󰂄"
                                        if (batteryPercent > 80) return "󰁹"
                                        if (batteryPercent > 60) return "󰂀"
                                        if (batteryPercent > 40) return "󰁾"
                                        if (batteryPercent > 20) return "󰁻"
                                        return "󰂃"
                                    }
                                    color: {
                                        if (batteryStatus == "Full") return colGreen
                                        if (batteryPercent > 40) return audioDropdownOpen ? colBg : colFg
                                        if (batteryPercent > 20) return colYellow
                                        return colRed
                                    }
                                    font { family: fontFamily; pixelSize: fontSize }
                                }
                                Text {
                                    text: batteryPercent + "%"
                                    color: audioDropdownOpen ? colBg : colFg
                                    font { family: fontFamily; pixelSize: fontSize + 1 }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            audioCloseDelay.stop()
                            audioDropdownOpen = true
                        }
                        onExited: audioCloseDelay.start()
                    }
                }

                // Clock
                Rectangle {
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: clockRow.implicitWidth + 18
                    radius: widgetRadius
                    color: colBgWidget
                    border.color: colBorder
                    border.width: 1

                    RowLayout {
                        id: clockRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󰥔"
                            color: colAccent
                            font { family: fontFamily; pixelSize: fontSize }
                        }
                        Text {
                            id: clockText
                            color: colFg
                            font { family: fontFamily; pixelSize: fontSize; bold: true }
                            text: Qt.formatDateTime(new Date(), "HH:mm")
                            Timer {
                                interval: 1000; running: true; repeat: true
                                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                            }
                        }
                        Text {
                            id: dateText
                            color: colFgDim
                            font { family: fontFamily; pixelSize: fontSize - 2 }
                            text: Qt.formatDateTime(new Date(), "dd-MM-yyyy")
                            Timer {
                                interval: 60000; running: true; repeat: true
                                onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dd-MM-yyyy")
                            }
                        }
                    }
                }

                // ═══════════════ NOTIFICATION BELL ══════════════════
                Rectangle {
                    // visible: notifModel.count > 0
                    // It's kinda dumb, but I'll leave it cus the logic is kinda 
                    // cool so if I can integrate it in a better way, sure
                    visible: false
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: 28
                    radius: widgetRadius
                    color: colBgWidget
                    
                    

                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        color: colAccent
                        font { family: fontFamily; pixelSize: fontSize }
                    }

                    // Count badge
                    Rectangle {
                        visible: notifModel.count > 0
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        anchors.rightMargin: -2
                        width: 14; height: 14; radius: 7
                        color: colRed

                        Text {
                            anchors.centerIn: parent
                            text: notifModel.count > 9 ? "9+" : notifModel.count
                            color: "#ffffff"
                            font { family: fontFamily; pixelSize: 8; bold: true }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Clear all notifications
                            for (var i = notifModel.count - 1; i >= 0; i--) {
                                var n = notifModel.get(i).notif
                                if (n && n.tracked) n.dismiss()
                            }
                            notifModel.clear()
                        }
                    }
                }

                // ═══════════════ CONTROL CENTER BUTTON ══════════════
                Rectangle {
                    Layout.preferredHeight: barHeight - 8
                    Layout.preferredWidth: ccBtnRow.implicitWidth + 14
                    radius: widgetRadius
                    color: controlCenterOpen ? colAccent2 : colBgWidget
                    border.color: controlCenterOpen ? colBorderActive : colBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 125 } }
                    Behavior on border.color { ColorAnimation { duration: 125 } }

                    RowLayout {
                        id: ccBtnRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: networkIcon
                            color: controlCenterOpen ? colBg : colGreen
                            font { family: fontFamily; pixelSize: fontSize }
                        }
                        Text {
                            text: "󰂯"
                            color: controlCenterOpen ? colBg : colAccent
                            font { family: fontFamily; pixelSize: fontSize }
                        }
                        Text {
                            text: controlCenterOpen ? "󰅁" : "󰅀"
                            color: controlCenterOpen ? colBg : colFgDim
                            font { family: fontFamily; pixelSize: fontSize - 2 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: { 
                            ccCloseDelay.stop()
                            controlCenterOpen = true 
                        }
                        onExited: ccCloseDelay.start() 
                    }
                }
            }

            

            // ── Media player (centered overlay) ──────────────────────
            Rectangle {
                id: mediaBar
                property var player: root.currentMpris
                visible: player !== null

                anchors.centerIn: parent
                width: mediaRow.implicitWidth + 18
                height: barHeight - 8
                clip: true
                radius: widgetRadius
                color: mediaDropdownOpen ? colAccent2 : colBgWidget
                border.color: mediaDropdownOpen ? colBorderActive : colBorder
                border.width: 1

                Behavior on color { ColorAnimation { duration: 125 } }
                Behavior on border.color { ColorAnimation { duration: 125 } }

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) {
                            mediaCloseDelay.stop()
                            mediaDropdownOpen = true
                        } else {
                            mediaCloseDelay.start()
                        }
                    }
                }

                RowLayout {
                    id: mediaRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: ""
                        color: mediaDropdownOpen ? colBg : colFg
                        font { family: fontFamily; pixelSize: fontSize + 1 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var p = root.currentMpris
                                if (p && p.canGoNext) p.next()
                            }
                        }
                    }

                    Text {
                        property var p: root.currentMpris
                        text: {
                            if (!p) return "Nothing playing..."
                            var artist = p.trackArtist || ""
                            var title = p.trackTitle || ""
                            if (artist && title) return artist + " — " + title
                            if (title) return title
                            return "Nothing playing..."
                        }
                        color: mediaDropdownOpen ? colBg : colFg
                        font { family: fontFamily; pixelSize: fontSize; bold: true }
                        elide: Text.ElideRight
                        Layout.maximumWidth: 380
                    }
                }
            }

            // ── Media dropdown ───────────────────────────────────────
            LazyLoader {
                loading: mediaDropdownOpen

                PopupWindow {
                    id: mediaDropdown
                    anchor.window: barWindow
                    anchor.rect.x: (barWindow.width - 340) / 2
                    anchor.rect.y: barHeight
                    implicitWidth: 340
                    implicitHeight: mdContent.implicitHeight + 36
                    visible: mediaDropdownOpen
                    color: "transparent"

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered) {
                                mediaCloseDelay.stop()
                            } else {
                                mediaCloseDelay.start()
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 12
                        color: "#EE0a1a24"
                        border.color: colBorder
                        border.width: 1

                        Column {
                            id: mdContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 10

                            // ── Player picker chip ───────────────────
                            // Shows current player identity, click to cycle.
                            // Hidden when there's only one player (or none).
                            Rectangle {
                                visible: Mpris.players.values.length > 1
                                width: playerChipRow.implicitWidth + 16
                                height: 22
                                radius: 11
                                color: colBgWidget
                                border.color: colBorder
                                border.width: 1
                                anchors.horizontalCenter: parent.horizontalCenter

                                RowLayout {
                                    id: playerChipRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: "󰓃"
                                        color: colAccent
                                        font { family: fontFamily; pixelSize: fontSize - 1 }
                                    }
                                    Text {
                                        text: {
                                            var p = root.currentMpris
                                            var name = p ? (p.identity || p.dbusName || "Unknown") : "None"
                                            var count = Mpris.players.values.length
                                            return name + "  (" + (Mpris.players.values.indexOf(p) + 1) + "/" + count + ")"
                                        }
                                        color: colFg
                                        font { family: fontFamily; pixelSize: fontSize - 2; bold: true }
                                    }
                                    Text {
                                        text: "󰁔"
                                        color: colFgDim
                                        font { family: fontFamily; pixelSize: fontSize - 2 }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.cycleMpris()
                                }
                            }

                            // ── Album art + track info ───────────────
                            RowLayout {
                                width: parent.width
                                spacing: 12

                                // Album art
                                Rectangle {
                                    width: 72; height: 72; radius: 8
                                    color: colBgWidget
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: (root.currentMpris?.trackArtUrl) ?? ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: source !== ""
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰎈"
                                        color: colFgDim
                                        font { family: fontFamily; pixelSize: 28 }
                                        visible: (root.currentMpris?.trackArtUrl ?? "") === ""
                                    }
                                }

                                // Track info
                                Column {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        property var p: root.currentMpris
                                        text: p?.trackTitle ?? "Nothing playing"
                                        color: colFg
                                        font { family: fontFamily; pixelSize: fontSize + 1; bold: true }
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        property var p: root.currentMpris
                                        text: p?.trackArtist ?? ""
                                        color: colFgDim
                                        font { family: fontFamily; pixelSize: fontSize }
                                        elide: Text.ElideRight
                                        width: parent.width
                                        visible: text !== ""
                                    }

                                    Text {
                                        property var p: root.currentMpris
                                        text: p?.trackAlbum ?? ""
                                        color: colSeparator
                                        font { family: fontFamily; pixelSize: fontSize - 1 }
                                        elide: Text.ElideRight
                                        width: parent.width
                                        visible: text !== ""
                                    }
                                }
                            }

                            // ── Cava visualizer ──────────────────────
                            Canvas {
                                id: cavaCanvas
                                width: parent.width
                                height: 40

                                property var bars: cavaData

                                onBarsChanged: requestPaint()

                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)

                                    var barCount = bars.length
                                    var barW = width / barCount
                                    var gap = 1

                                    for (var i = 0; i < barCount; i++) {
                                        var val = bars[i] / 100
                                        var h = val * height * 0.9
                                        if (h < 2) h = 2

                                        var gradient = ctx.createLinearGradient(0, height, 0, height - h)
                                        gradient.addColorStop(0, colAccent2)
                                        gradient.addColorStop(1, colAccent)

                                        ctx.fillStyle = gradient
                                        ctx.beginPath()
                                        // Rounded top
                                        var x = i * barW + gap / 2
                                        var w = barW - gap
                                        var r = Math.min(w / 2, 2)
                                        var y = height - h

                                        ctx.moveTo(x + r, y)
                                        ctx.arcTo(x + w, y, x + w, y + h, r)
                                        ctx.lineTo(x + w, height)
                                        ctx.lineTo(x, height)
                                        ctx.arcTo(x, y, x + r, y, r)
                                        ctx.closePath()
                                        ctx.fill()
                                    }
                                }
                            }

                            // ── Wavy progress bar ────────────────────
                            Item { 
                                width: parent.width
                                height: 28 

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 4 
                                    height: 20 
                                    radius: 4 
                                    color: colAccent 
                                }
                                
                                Text {
                                    anchors.centerIn: parent 
                                    text: "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
                                    color: colFgDim
                                }

                                Canvas {
                                    id: wavyProgress
                                    width: parent.width
                                    height: 28

                                    property var player: root.currentMpris
                                    property real progress: {
                                        if (!player || !player.lengthSupported || player.length <= 0) return 0
                                        return player.position / player.length
                                    }

                                    // Animate the waves
                                    property real wavePhase: 0
                                    NumberAnimation on wavePhase {
                                        from: 0; to: Math.PI * 2
                                        duration: 2000
                                        loops: Animation.Infinite
                                        running: player?.isPlaying ?? false
                                    }

                                    // Repaint on position/phase changes
                                    onProgressChanged: requestPaint()
                                    onWavePhaseChanged: requestPaint()

                                    // Manual position update
                                    FrameAnimation {
                                        running: mediaDropdownOpen && (wavyProgress.player?.isPlaying ?? false)
                                        onTriggered: {
                                            if (wavyProgress.player) {
                                                wavyProgress.player.positionChanged()
                                            }
                                        }
                                    }

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)

                                        var midY = height / 2
                                        var amp = 3
                                        var freq = 0.06
                                        var progressX = progress * width

                                        // Played portion — wavy
                                        if (progressX > 0) {
                                            ctx.beginPath()
                                            for (var x = 0; x <= progressX; x += 1) {
                                                var y = midY + Math.sin(x * freq + wavePhase) * amp
                                                ctx.lineTo(x, y)
                                            }
                                            ctx.strokeStyle = colAccent
                                            ctx.lineWidth = 3
                                            ctx.lineCap = "round"
                                            ctx.stroke()
                                        }

                                        // Playhead dot
                                        if (progressX > 0 && progressX < width) {
                                            var dotY = midY + Math.sin(progressX * freq + wavePhase) * amp
                                            ctx.beginPath()
                                            ctx.arc(progressX, dotY, 5, 0, Math.PI * 2)
                                            ctx.fillStyle = colAccent
                                            ctx.fill()
                                            ctx.beginPath()
                                            ctx.arc(progressX, dotY, 2, 0, Math.PI * 2)
                                            ctx.fillStyle = colBg
                                            ctx.fill()
                                        }
                                    }

                                    // Click to seek
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mouse => {
                                            var p = root.currentMpris
                                            if (p) p.position = (mouse.x / width) * p.length
                                        }
                                    }
                                }
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 4
                                    height: 10
                                    radius: 4
                                    color: colAccent
                                }
                            }

                            // ── Time labels ──────────────────────────
                            RowLayout {
                                width: parent.width

                                Text {
                                    property var p: root.currentMpris
                                    property real pos: p?.position ?? 0
                                    text: {
                                        var s = Math.floor(pos)
                                        var m = Math.floor(s / 60)
                                        s = s % 60
                                        return m + ":" + (s < 10 ? "0" : "") + s
                                    }
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2 }
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    property var p: root.currentMpris
                                    property real len: p?.length ?? 0
                                    text: {
                                        var s = Math.floor(len)
                                        var m = Math.floor(s / 60)
                                        s = s % 60
                                        return m + ":" + (s < 10 ? "0" : "") + s
                                    }
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2 }
                                }
                            }

                            // ── Playback controls ────────────────────
                            RowLayout {
                                width: parent.width
                                spacing: 0

                                // Player volume slider
                                Slider {
                                    id: mdVolumeSlider

                                    Layout.fillWidth: true
                                    value: root.currentMpris?.volume ?? 0
                                    onValueChanged: {
                                        var p = root.currentMpris
                                        if (p && p.volumeSupported) p.volume = value
                                    }

                                    handle: Rectangle {
                                        x: mdVolumeSlider.leftPadding + mdVolumeSlider.visualPosition * (mdVolumeSlider.availableWidth - width)
                                        y: mdVolumeSlider.topPadding + mdVolumeSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 6
                                        implicitHeight: 16
                                        radius: 4 
                                    }

                                    background: Rectangle {
                                        anchors.centerIn: parent
                                        color: colSeparator
                                        implicitHeight: 6
                                        width: mdVolumeSlider.availableWidth
                                        height: implicitHeight
                                        radius: 3

                                        Rectangle {
                                            width: mdVolumeSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: colAccent
                                            radius: 3
                                        }
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    property int l: root.currentMpris?.loopState ?? 0
                                    text: l == 0 ? "󰑗" : (l == 1 ? "󰑘" : "󰑖")
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize + 4 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var p = root.currentMpris
                                            if (p) p.loopState = (p.loopState + 1) % 3
                                        }
                                    }
                                }

                                Item { width: 16 }

                                Text {
                                    text: "󰒮"
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize + 6 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var p = root.currentMpris
                                            if (p && p.canGoPrevious) p.previous()
                                        }
                                    }
                                }

                                Item { width: 16 }

                                Rectangle {
                                    width: 40; height: 40; radius: 20
                                    color: colAccent

                                    Text {
                                        anchors.centerIn: parent
                                        property var p: root.currentMpris
                                        text: (p && p.isPlaying) ? "󰏤" : "󰐊"
                                        color: colBg
                                        font { family: fontFamily; pixelSize: fontSize + 8 }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var pl = root.currentMpris
                                            if (pl && pl.canTogglePlaying) pl.isPlaying = !pl.isPlaying
                                        }
                                    }
                                }

                                Item { width: 16 }

                                Text {
                                    text: "󰒭"
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize + 6 }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var p = root.currentMpris
                                            if (p && p.canGoNext) p.next()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ═══════════════ AUDIO MANAGER DROPDOWN ═════════════════
            LazyLoader {
                loading: audioDropdownOpen

                PopupWindow {
                    id: audioDropdown
                    anchor.window: barWindow
                    anchor.rect.x: Math.max(8, barWindow.width - 360)
                    anchor.rect.y: barHeight
                    implicitWidth: 350
                    implicitHeight: audioContent.implicitHeight + 36
                    visible: audioDropdownOpen
                    color: "transparent"

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered) {
                                audioCloseDelay.stop()
                            } else {
                                audioCloseDelay.start()
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 12
                        color: "#EE0a1a24"
                        border.color: colBorder
                        border.width: 1

                        Column {
                            id: audioContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 10

                            // ── Header ───────────────────────────────
                            RowLayout {
                                width: parent.width
                                spacing: 6
                                Text {
                                    text: "󰕾"
                                    color: colAccent
                                    font { family: fontFamily; pixelSize: fontSize + 2 }
                                }
                                Text {
                                    text: "Audio"
                                    color: colFg
                                    font { family: fontFamily; pixelSize: fontSize; bold: true }
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: allSinks.length + " device" + (allSinks.length === 1 ? "" : "s")
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2 }
                                }
                            }

                            // ── Output device picker ─────────────────
                            // Each sink is a row: icon, name, "default" badge.
                            Rectangle {
                                width: parent.width
                                height: sinkColumn.implicitHeight + 12
                                radius: 10
                                color: colBgWidget

                                Column {
                                    id: sinkColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 6
                                    spacing: 2

                                    Repeater {
                                        model: allSinks

                                        Rectangle {
                                            required property var modelData
                                            property bool isDefault: modelData === Pipewire.defaultAudioSink
                                            property bool hovered: sinkMouse.containsMouse

                                            width: parent.width
                                            height: 32
                                            radius: 6
                                            color: isDefault ? colBgLight
                                                 : hovered ? colBgLight
                                                 : "transparent"

                                            Behavior on color { ColorAnimation { duration: 100 } }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                spacing: 8

                                                Text {
                                                    text: isDefault ? "󰓃" : "󰓃"
                                                    color: isDefault ? colAccent : colFgDim
                                                    font { family: fontFamily; pixelSize: fontSize }
                                                }

                                                Text {
                                                    text: modelData.description
                                                        || modelData.nickname
                                                        || modelData.name
                                                        || "Unknown device"
                                                    color: isDefault ? colFg : colFgDim
                                                    font { family: fontFamily; pixelSize: fontSize - 1; bold: isDefault }
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    visible: isDefault
                                                    text: "default"
                                                    color: colAccent
                                                    font { family: fontFamily; pixelSize: fontSize - 3; bold: true }
                                                }
                                            }

                                            MouseArea {
                                                id: sinkMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    Pipewire.preferredDefaultAudioSink = modelData
                                                }
                                            }
                                        }
                                    }

                                    // Empty state
                                    Text {
                                        visible: allSinks.length === 0
                                        text: "No output devices found"
                                        color: colFgDim
                                        font { family: fontFamily; pixelSize: fontSize - 1 }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // ── Master output slider ─────────────────
                            Rectangle {
                                width: parent.width
                                height: masterCol.implicitHeight + 16
                                radius: 10
                                color: colBgWidget

                                Column {
                                    id: masterCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                    spacing: 4

                                    RowLayout {
                                        width: parent.width
                                        Text {
                                            text: "Master"
                                            color: colFg
                                            font { family: fontFamily; pixelSize: fontSize - 1; bold: true }
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: outputVolumePercent + "%"
                                            color: colFgDim
                                            font { family: fontFamily; pixelSize: fontSize - 2 }
                                        }
                                    }

                                    RowLayout {
                                        width: parent.width
                                        spacing: 8

                                        Text {
                                            text: (output && output.muted) ? "󰝟" : (outputVolumePercent > 50 ? "󰕾" : "󰖀")
                                            color: (output && output.muted) ? colRed : colAccent
                                            font { family: fontFamily; pixelSize: fontSize + 1 }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: { if (output) output.muted = !output.muted }
                                            }
                                        }

                                        Slider {
                                            id: masterSlider
                                            Layout.fillWidth: true
                                            from: 0
                                            to: 1
                                            value: output ? output.volume : 0
                                            onMoved: { if (output) output.volume = value }

                                            handle: Rectangle {
                                                x: masterSlider.leftPadding + masterSlider.visualPosition * (masterSlider.availableWidth - width)
                                                y: masterSlider.topPadding + masterSlider.availableHeight / 2 - height / 2
                                                implicitWidth: 6
                                                implicitHeight: 16
                                                radius: 4
                                                color: colAccent
                                            }

                                            background: Rectangle {
                                                anchors.centerIn: parent
                                                color: colSeparator
                                                implicitHeight: 6
                                                width: masterSlider.availableWidth
                                                height: implicitHeight
                                                radius: 3

                                                Rectangle {
                                                    width: masterSlider.visualPosition * parent.width
                                                    height: parent.height
                                                    color: (output && output.muted) ? colFgDim : colAccent
                                                    radius: 3
                                                    Behavior on color { ColorAnimation { duration: 120 } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // ── Per-app streams header ───────────────
                            RowLayout {
                                width: parent.width
                                visible: appStreams.length > 0
                                Text {
                                    text: "Applications"
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2; bold: true }
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: appStreams.length
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2 }
                                }
                            }

                            // ── Per-app streams ──────────────────────
                            Repeater {
                                model: appStreams

                                Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: appCol.implicitHeight + 16
                                    radius: 10
                                    color: colBgWidget

                                    // Try a couple names if soemthing is being annoying
                                    property string appLabel: {
                                        var n = modelData
                                        if (!n) return "Unknown"
                                        // Known PwNode fields
                                        if (n.properties) {
                                            var p = n.properties
                                            if (p["application.name"]) return p["application.name"]
                                            if (p["application.process.binary"]) return p["application.process.binary"]
                                            if (p["media.name"]) return p["media.name"]
                                        }
                                        return n.description || n.nickname || n.name || "Stream"
                                    }

                                    property string mediaLabel: {
                                        var n = modelData
                                        if (n && n.properties && n.properties["media.name"]) {
                                            return n.properties["media.name"]
                                        }
                                        return ""
                                    }

                                    Column {
                                        id: appCol
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: 8
                                        spacing: 4

                                        RowLayout {
                                            width: parent.width
                                            Text {
                                                text: appLabel
                                                color: colFg
                                                font { family: fontFamily; pixelSize: fontSize - 1; bold: true }
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Text {
                                                text: modelData.audio
                                                    ? Math.floor(modelData.audio.volume * 100) + "%"
                                                    : "—"
                                                color: colFgDim
                                                font { family: fontFamily; pixelSize: fontSize - 2 }
                                            }
                                        }

                                        Text {
                                            visible: mediaLabel !== "" && mediaLabel !== appLabel
                                            text: mediaLabel
                                            color: colFgDim
                                            font { family: fontFamily; pixelSize: fontSize - 3 }
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        RowLayout {
                                            width: parent.width
                                            spacing: 8

                                            Text {
                                                property bool isMuted: modelData.audio ? modelData.audio.muted : false
                                                text: isMuted ? "󰝟" : "󰕾"
                                                color: isMuted ? colRed : colAccent2
                                                font { family: fontFamily; pixelSize: fontSize }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (modelData.audio) {
                                                            modelData.audio.muted = !modelData.audio.muted
                                                        }
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: appSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1
                                                value: modelData.audio ? modelData.audio.volume : 0
                                                onMoved: {
                                                    if (modelData.audio) {
                                                        modelData.audio.volume = value
                                                    }
                                                }

                                                handle: Rectangle {
                                                    x: appSlider.leftPadding + appSlider.visualPosition * (appSlider.availableWidth - width)
                                                    y: appSlider.topPadding + appSlider.availableHeight / 2 - height / 2
                                                    implicitWidth: 6
                                                    implicitHeight: 14
                                                    radius: 4
                                                    color: colAccent2
                                                }

                                                background: Rectangle {
                                                    anchors.centerIn: parent
                                                    color: colSeparator
                                                    implicitHeight: 5
                                                    width: appSlider.availableWidth
                                                    height: implicitHeight
                                                    radius: 2

                                                    Rectangle {
                                                        width: appSlider.visualPosition * parent.width
                                                        height: parent.height
                                                        color: (modelData.audio && modelData.audio.muted) ? colFgDim : colAccent2
                                                        radius: 2
                                                        Behavior on color { ColorAnimation { duration: 120 } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Empty-state row when nothing is playing
                            Rectangle {
                                visible: appStreams.length === 0
                                width: parent.width
                                height: 34
                                radius: 10
                                color: colBgWidget

                                Text {
                                    anchors.centerIn: parent
                                    text: "No applications playing audio"
                                    color: colFgDim
                                    font { family: fontFamily; pixelSize: fontSize - 2 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
