/*
 * Copyright (C) 2026 OPENOS-dev
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the OPENOS-PROJECT-LICENSE (OPL) v1.2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * OPL for more details.
 *
 * You should have received a copy of the OPL along with this program.
 * If not, see <https://github.com/OPENOS-dev/OPL>.
 */

// openos-run — Windows 10 开始菜单风格启动器 (独立 Window)
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Window {
    id: root
    width: 640; height: 600
    flags: Qt.FramelessWindowHint | Qt.Dialog | Qt.WindowStaysOnTopHint
    title: "开始"
    color: "transparent"
    visible: true

    property string query: searchBox.text.trim().toLowerCase()

    function launch(a) {
        if (a.source === "vmapp" && a.vmapp.length) appLauncher.launchInVmapp(a.vmapp, a.exec)
        else appLauncher.launch(a.exec)
        root.close()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.07,0.07,0.07, OpenUI.glassMenuAlpha)
        radius: OpenUI.shapeLg
        border.color: Qt.rgba(1,1,1,0.10)

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // 左细栏
            Item {
                Layout.preferredWidth: 48
                Layout.fillHeight: true
                Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.35) }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: OpenUI.sp3
                    anchors.bottomMargin: OpenUI.sp3
                    spacing: OpenUI.sp2

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32; height: 32; radius: 16
                        color: OpenUI.primary
                        Text { anchors.centerIn: parent; text: "O"
                            color: OpenUI.onPrimary; font.pixelSize: 16; font.bold: true }
                    }
                    Item { Layout.fillHeight: true; Layout.minimumHeight: 8 }
                    ItemDelegate {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 40
                        contentItem: Item {
                            ThemedIcon { anchors.centerIn: parent; name: "open-menu"; ctx: "Actions"; size: 20; color: OpenUI.onSurface }
                        }
                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(1,1,1,OpenUI.hoverAlpha) : "transparent"
                            radius: OpenUI.shapeSm
                        }
                        onClicked: appsList.forceActiveFocus()
                    }
                    Item { Layout.fillHeight: true }
                    ItemDelegate {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 40
                        contentItem: Item {
                            ThemedIcon { anchors.centerIn: parent; name: "system-power"; ctx: "Actions"; size: 20; color: OpenUI.onSurface }
                        }
                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(1,1,1,OpenUI.hoverAlpha) : "transparent"
                            radius: OpenUI.shapeSm
                        }
                        onClicked: root.close()
                    }
                }
            }

            // 右侧主区
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: OpenUI.sp3
                anchors.margins: OpenUI.sp4

                TextField {
                    id: searchBox
                    Layout.fillWidth: true
                    placeholderText: "搜索应用…"
                    color: OpenUI.onSurface
                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.06)
                        radius: OpenUI.shapeSm
                        border.color: searchBox.activeFocus ? OpenUI.primary : Qt.rgba(1,1,1,0.10)
                    }
                    leftPadding: OpenUI.sp3
                }

                Label {
                    text: "已固定"
                    color: OpenUI.onSurfaceVariant
                    font.pixelSize: OpenUI.typeLabelL
                    font.bold: true
                }
                GridLayout {
                    columns: 6
                    rowSpacing: OpenUI.sp3
                    columnSpacing: OpenUI.sp3
                    Repeater {
                        model: Math.min(12, appsModel.rowCount())
                        delegate: ItemDelegate {
                            required property int index
                            Layout.fillWidth: true; height: 72
                            leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                            property var a: appsModel.data(appsModel.index(index,0), 0x100) // placeholder
                            contentItem: ColumnLayout {
                                spacing: OpenUI.sp1
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 44; Layout.preferredHeight: 44
                                    Rectangle {
                                        anchors.fill: parent; radius: OpenUI.shapeSm
                                        color: appsModel.data(appsModel.index(index,0), 0x103) === "vmapp"
                                            ? OpenUI.tertiary : OpenUI.primaryContainer
                                        Text {
                                            anchors.centerIn: parent
                                            text: (appsModel.data(appsModel.index(index,0), 0x101)).toString()[0].toUpperCase()
                                            color: appsModel.data(appsModel.index(index,0), 0x103) === "vmapp"
                                                ? OpenUI.onSurface : OpenUI.onPrimaryContainer
                                            font.pixelSize: 20; font.bold: true
                                        }
                                    }
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: 72
                                    text: appsModel.data(appsModel.index(index,0), 0x101)
                                    color: OpenUI.onSurface
                                    font.pixelSize: OpenUI.typeLabelM
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight; wrapMode: Text.Wrap; maximumLineCount: 2
                                }
                            }
                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(1,1,1,OpenUI.hoverAlpha) : "transparent"
                                radius: OpenUI.shapeSm
                            }
                            onClicked: {
                                var m = appsModel.index(index, 0)
                                root.launch({
                                    name: appsModel.data(m, 0x101),
                                    exec: appsModel.data(m, 0x102),
                                    vmapp: appsModel.data(m, 0x103),
                                    source: appsModel.data(m, 0x104)
                                })
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1
                    color: Qt.rgba(1,1,1,0.08) }

                Label {
                    text: "所有应用"
                    color: OpenUI.onSurfaceVariant
                    font.pixelSize: OpenUI.typeLabelL
                    font.bold: true
                }
                ListView {
                    id: appsList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: appsModel
                    section.property: "group"
                    section.criteria: ViewSection.FirstCharacter
                    section.delegate: Rectangle {
                        width: appsList.width; height: 28; color: "transparent"
                        Text {
                            text: section
                            color: OpenUI.primary
                            font.pixelSize: OpenUI.typeTitle; font.bold: true
                            x: OpenUI.sp2; anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    delegate: ItemDelegate {
                        width: appsList.width; height: 40
                        visible: root.query === "" || model.name.toLowerCase().includes(root.query)
                        contentItem: RowLayout {
                            spacing: OpenUI.sp3
                            Rectangle {
                                width: 26; height: 26; radius: OpenUI.shapeXs
                                color: model.source === "vmapp" ? OpenUI.tertiary : OpenUI.primaryContainer
                                Text {
                                    anchors.centerIn: parent
                                    text: model.name.charAt(0).toUpperCase()
                                    color: model.source === "vmapp" ? OpenUI.onSurface : OpenUI.onPrimaryContainer
                                    font.pixelSize: OpenUI.typeLabelM; font.bold: true
                                }
                            }
                            Text {
                                text: model.name + (model.source === "vmapp" ? "  (隔离)" : "")
                                color: OpenUI.onSurface
                                font.pixelSize: OpenUI.typeBodyM
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                        }
                        background: Rectangle {
                            color: parent.hovered ? Qt.rgba(1,1,1,OpenUI.hoverAlpha) : "transparent"
                        }
                        onClicked: root.launch(model)
                    }
                }
            }
        }
    }

    Component.onCompleted: searchBox.forceActiveFocus()
}
