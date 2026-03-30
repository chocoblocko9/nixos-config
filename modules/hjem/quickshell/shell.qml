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
    // ── Theme ────────────────────────────────────────────────────────
    property color colBg:        "#0a1a24"
    property color colBgLight:   "#0f2833"
    property color colBgWidget:  "#132e3c"
    property color colFg:        "#b8d4e3"
    property color colFgDim:     "#5a8a9e"
    property color colAccent:    "#0db9d7"
    property color colAccent2:   "#0090b0"
    property color colGreen:     "#2dd4a8"
    property color colYellow:    "#e0c868"
    property color colRed:       "#e06070"
    property color colSeparator: "#1a3a4a"

    property string fontFamily: "JetBrainsMono Nerd Font "
    property int fontSize: 13
    property int barHeight: 36
    property int barRadius: 0
    property int widgetRadius: 6
    property int widgetSpacing: 6

    // ── Dropdown state ───────────────────────────────────────────────
    property bool controlCenterOpen: false

    // ── Notification server ──────────────────────────────────────────
    NotificationServer {
        id: notifServer
        keepOnReload: true
        onNotification: notification => {
            if (dndOn) {
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
    property string username: ""
    property string hostname: ""
    property string uptimeStr: ""
    property int batteryPercent: -1 // set impossible default to hide battery on slip
    property bool batteryCharging: false
    property int volumePercent: 0
    property bool volumeMuted: false
    property string networkName: ""
    property string networkIcon: "󰤭"
    property string weatherText: ""
    property string weatherIcon: ""
    property string weatherTemp: ""
    property string weatherLocation: ""
    property string weatherDesc: ""
    property bool bluetoothOn: true
    property bool dndOn: false 

    // ── Processes ────────────────────────────────────────────────────

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                }
                lastCpuTotal = total
                lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: userProc
        command: ["sh", "-c", "echo \"$(whoami)@$(hostname)\""]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split("@")
                username = parts[0] || ""
                hostname = parts[1] || ""
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null && cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo 'NONE'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "NONE") {
                    batteryPercent = -1
                    return
                }
                var lines = data.trim()
                var val = parseInt(lines)
                if (!isNaN(val)) {
                    batteryPercent = val
                } else {
                    batteryCharging = lines.indexOf("Charging") >= 0
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volumeProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo '0'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s+([\d.]+)/)
                if (match) {
                    volumePercent = Math.round(parseFloat(match[1]) * 100)
                }
                volumeMuted = data.indexOf("[MUTED]") >= 0
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: networkProc
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | head -1"]
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
        Component.onCompleted: running = true
    }

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s 'wttr.in/?format=%c+%t+%l+%C' 2>/dev/null || echo ''"]
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
        Component.onCompleted: running = true
    }

    // ── Timers ───────────────────────────────────────────────────────
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: {
            cpuProc.running = true
            volumeProc.running = true
        }
    }

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

    // ── Volume control processes ─────────────────────────────────────
    property string pendingVolume: ""

    Process {
        id: volSetProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pendingVolume]
    }

    Process {
        id: volMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
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
            color: colBg

            // ── Control Center Popup ─────────────────────────────────
            PopupWindow {
                id: controlCenter
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 320
                anchor.rect.y: barHeight
                width: 310
                height: ccColumn.implicitHeight + 36
                visible: controlCenterOpen
                color: "transparent"

                onVisibleChanged: {
                    if (!visible) controlCenterOpen = false
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 12
                    color: colBg
                    border.color: colSeparator
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

                            width: parent.width; height: 50; radius: 10
                            color: colBgWidget

                            RowLayout {

                                PwObjectTracker {
                                    property PwNode sink: Pipewire.defaultAudioSink
                                    objects: [sink]
                                }

                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Text {
                                    property PwNode sink: Pipewire.defaultAudioSink
                                    property int volume: Math.floor(sink.audio.volume * 100)

                                    text: sink.audio.muted ? "󰝟" : (volumePercent > 50 ? "󰕾" : "󰖀")
                                    color: sink.audio.muted ? colRed : colAccent
                                    font { family: fontFamily; pixelSize: 16 }
                                    MouseArea {
                                        property PwNode sink: Pipewire.defaultAudioSink
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: sink.audio.muted = !sink.audio.muted 
                                    }
                                }

                                Slider {
                                    property PwNode sink: Pipewire.defaultAudioSink
                                    Layout.fillWidth: true
                                    value: sink.audio.volume
                                    onValueChanged: sink.audio.volume = value
                                }

                                Text {
                                    text: volumePercent + "%"
                                    color: colFg
                                    font { family: fontFamily; pixelSize: fontSize - 1 }
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
                                        if (batteryCharging) return "󰂄"
                                        if (batteryPercent > 80) return "󰁹"
                                        if (batteryPercent > 60) return "󰂀"
                                        if (batteryPercent > 40) return "󰁾"
                                        if (batteryPercent > 20) return "󰁻"
                                        return "󰂃"
                                    }
                                    color: {
                                        if (batteryCharging) return colGreen
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
                                            if (batteryCharging) return colGreen
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

            // ── Notification toasts ──────────────────────────────────
            PopupWindow {
                id: notifPopup
                anchor.window: barWindow
                anchor.rect.x: barWindow.width - 364 // fits with my hyprland windows
                anchor.rect.y: barHeight + 10        // cus that's cool I think
                width: 350
                height: notifToastCol.implicitHeight + 12
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

                            width: parent.width
                            height: notifContent.implicitHeight + 20
                            radius: 10
                            color: colBg
                            border.color: colSeparator
                            border.width: 1

                            Timer {
                                interval: 5000
                                running: true
                                onTriggered: notifModel.remove(index) // dismisses after 5s
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
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: userRow.implicitWidth + 16
                    radius: widgetRadius
                    color: colBgWidget

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
                            text: username + "@" + hostname
                            color: colAccent
                            font { family: fontFamily; pixelSize: fontSize; bold: true }
                        }
                    }
                }

                // ═══════════════ WORKSPACES ══════════════════════════

                Rectangle {
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: wsRow.implicitWidth + 14
                    radius: widgetRadius
                    color: colBgWidget

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
                                height: barHeight - 6

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

                // ═══════════════ MEDIA ══════════════════════════════
 
                Item { Layout.fillWidth: true }

                Item { Layout.fillWidth: true }

                // ═══════════════ RIGHT ══════════════════════════════

                // Volume 
                Rectangle {
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: volBarRow.implicitWidth + 14
                    radius: widgetRadius
                    color: colBgWidget

                    RowLayout {
                        id: volBarRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: volumeMuted ? "󰝟" : (volumePercent > 50 ? "󰕾" : "󰖀")
                            color: volumeMuted ? colRed : colFg
                            font { family: fontFamily; pixelSize: fontSize + 3 }
                        }
                        Text {
                            text: volumePercent + "%"
                            color: colFg
                            font { family: fontFamily; pixelSize: fontSize + 1 }
                        }
                    }
                }

                // Battery
                Rectangle {
                    visible: batteryPercent >= 0
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: batRow.implicitWidth + 14
                    radius: widgetRadius
                    color: colBgWidget

                    RowLayout {
                        id: batRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: {
                                if (batteryCharging) return "󰂄"
                                if (batteryPercent > 80) return "󰁹"
                                if (batteryPercent > 60) return "󰂀"
                                if (batteryPercent > 40) return "󰁾"
                                if (batteryPercent > 20) return "󰁻"
                                return "󰂃"
                            }
                            color: {
                                if (batteryCharging) return colGreen
                                if (batteryPercent > 40) return colFg
                                if (batteryPercent > 20) return colYellow
                                return colRed
                            }
                            font { family: fontFamily; pixelSize: fontSize }
                        }
                        Text {
                            text: batteryPercent + "%"
                            color: colFg
                            font { family: fontFamily; pixelSize: fontSize + 1 }
                        }
                    }
                }

                // Clock
                Rectangle {
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: clockRow.implicitWidth + 16
                    radius: widgetRadius
                    color: colBgWidget

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
                            text: Qt.formatDateTime(new Date(), "dd-M-yyyy")
                            Timer {
                                interval: 60000; running: true; repeat: true
                                onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dd-M-yyyy")
                            }
                        }
                    }
                }

                // ═══════════════ NOTIFICATION BELL ══════════════════
                Rectangle {
                    // visible: notifModel.count > 0
                    visible: false
                    Layout.preferredHeight: barHeight - 6
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
                    Layout.preferredHeight: barHeight - 6
                    Layout.preferredWidth: ccBtnRow.implicitWidth + 14
                    radius: widgetRadius
                    color: controlCenterOpen ? colAccent2 : colBgWidget

                    Behavior on color { ColorAnimation { duration: 150 } }

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
                        onClicked: controlCenterOpen = !controlCenterOpen
                    }
                }
            }

            // ── Media player (centered overlay) ──────────────────────
            Rectangle {
                property var player: Mpris.players.values[0] ?? null
                visible: player !== null

                anchors.centerIn: parent
                width: mediaRow.implicitWidth + 16
                height: barHeight - 6
                clip: true
                radius: widgetRadius
                color: colBgWidget

                RowLayout {
                    id: mediaRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰒮"
                        color: colFgDim
                        font { family: fontFamily; pixelSize: fontSize }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var p = Mpris.players.values[0]
                                if (p && p.canGoPrevious) p.previous()
                            }
                        }
                    }

                    Text {
                        property var p: Mpris.players.values[0] ?? null
                        text: (p && p.isPlaying) ? "󰏤" : "󰐊"
                        color: colAccent
                        font { family: fontFamily; pixelSize: fontSize + 2 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var pl = Mpris.players.values[0]
                                if (pl && pl.canTogglePlaying) pl.isPlaying = !pl.isPlaying
                            }
                        }
                    }

                    Text {
                        text: "󰒭"
                        color: colFgDim
                        font { family: fontFamily; pixelSize: fontSize }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var p = Mpris.players.values[0]
                                if (p && p.canGoNext) p.next()
                            }
                        }
                    }

                    Rectangle { width: 1; height: 14; color: colSeparator }

                    Text {
                        property var p: Mpris.players.values[0] ?? null
                        text: {
                            if (!p) return "Nothing playing"
                            var artist = p.trackArtist || ""
                            var title = p.trackTitle || ""
                            if (artist && title) return artist + " — " + title
                            if (title) return title
                            return "Playing"
                        }
                        color: colFg
                        font { family: fontFamily; pixelSize: fontSize - 1 }
                        elide: Text.ElideRight
                        Layout.maximumWidth: 320
                    }
                }
            }
        }
    }
}
