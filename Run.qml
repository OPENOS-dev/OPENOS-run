import QtQuick 2.15
import QtQuick.Window 2.15

/* OPENOS 运行 App (独立窗口, 紧凑对话框)
 * 输入命令回车执行 (系统调用)
 */
Window {
    id: runApp
    width: 460; height: 110
    flags: Qt.FramelessWindowHint | Qt.Dialog | Qt.WindowStaysOnTopHint
    title: "运行"
    color: OpenUI.surface

    Rectangle {
        anchors.fill: parent; radius: OpenUI.shapeLg
        color: Qt.rgba(OpenUI.surface6.r, OpenUI.surface6.g, OpenUI.surface6.b,
                       OpenUI.glassMenuAlpha)
        border.color: OpenUI.outlineVariant; border.width: 1
        Column {
            anchors.fill: parent; anchors.margins: OpenUI.sp4; spacing: OpenUI.sp3
            Text { text: "运行"; color: OpenUI.onSurfaceVariant; font.pixelSize: OpenUI.typeLabelM }
            Row { width: parent.width; spacing: OpenUI.sp2
                Item { width: 20; height: 20; anchors.verticalCenter: parent.verticalCenter
                    ThemedIcon { anchors.centerIn: parent; name: "arrow-right"; ctx: "Navigation"; size: 16; color: OpenUI.primary } }
                TextField {
                    id: input
                    width: parent.width - 20; height: 34
                    placeholderText: "输入命令…"
                    color: OpenUI.onSurface; font.pixelSize: OpenUI.typeBodyM
                    Rectangle { z: -1; anchors.fill: parent; radius: OpenUI.shapeXs
                        color: Qt.rgba(OpenUI.surfaceBright.r, OpenUI.surfaceBright.g,
                                       OpenUI.surfaceBright.b, 0.5) }
                    Keys.onReturnPressed: {
                        // 生产: 经合成器启动 (wayland bridge exec)
                        console.log("run:", input.text)
                        input.text = ""
                        runApp.close()
                    }
                    Keys.onEscapePressed: runApp.close()
                    Component.onCompleted: forceActiveFocus()
                }
            }
        }
    }
}
