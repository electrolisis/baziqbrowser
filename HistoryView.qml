// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtQuick.Layouts
//
import QtQuick.LocalStorage
import "Database.js" as JS

Pane {
    id: historyView

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    ListModel {
        id: historyModel
    }

    Column {
        width: parent.width
        height: parent.height

        Pane {
            id: buttonsPane
            width: parent.width
            height: closeButton.height + 10
            padding: 0

            Button {
                id: clearButton
                //height: 28 //fusion
                icon.name: "edit-clear-history"
                //icon.source: "qrc:/icons/edit-clear-history.svg"
                //icon.color: "black"
                anchors.left: parent.left
                onClicked: {
                    JS.historyDbClear()
                    historyModel.clear()
                }
            }

            // Pane {
            //     width: parent.width - (clearButton + closeButton)
            // }

            Button {
                id: closeButton
                //height: 28 //fusion
                icon.name: "mobile-close-app"
                //icon.source: "qrc:/icons/mobile-close-app.svg"
                //icon.color: "black"
                anchors.right: parent.right
                onClicked: {
                    historyView.visible = false;
                    tabLayout.visible = true
                }
            }
        }

        // Pane {
        //     id: paneDiv
        //     width: parent.width
        //     height: 10
        // }

        Pane {
            width: parent.width
            height: parent.height - buttonsPane.height

            ListView {
                id: listView
                width: parent.width
                height: parent.height
                spacing: 1

                model: historyModel

                delegate:
                    Row {
                        id: row
                        width: listView.width - scrollBar.width

                        //
                        Button {
                            id: historyItem
                            width: row.width - 5

                            contentItem:
                                RowLayout {
                                    anchors.fill: parent

                                    Image {
                                        width: 22; height: 22
                                        source: model.icon
                                    }

                                    ColumnLayout {

                                        Text {
                                            text: model.title
                                            elide: Text.ElideRight
                                            //color: "#404040"
                                            color: sysPalette.windowText
                                            Layout.fillWidth: true
                                            //padding: 10
                                            //verticalAlignment: Text.AlignVCenter
                                        }

                                        Text {
                                            text: model.url
                                            elide: Text.ElideRight
                                            font.pixelSize: 12
                                            //color: "dimgray"
                                            color: sysPalette.windowText
                                            Layout.fillWidth: true
                                            //padding: 5
                                            //verticalAlignment: Text.AlignVCenter

                                        }
                                    }
                            }

                            // background: Rectangle {
                            //     color: "white"
                            // }

                            flat: true

                            onClicked: {
                                //print(model.url)
                                currentWebView.url = model.url;
                                historyView.visible = false
                                tabLayout.visible = true
                            }
                        }
                    //
                }

                ScrollBar.vertical: ScrollBar { id : scrollBar }
            }

        }
    }

    //
    onVisibleChanged: {
        historyModel.clear()
        JS.historyDbReadAll()
    }
}
