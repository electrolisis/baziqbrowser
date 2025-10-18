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

            RowLayout{
                anchors.right: parent.right

                DelayButton {
                    id: clearDelayButton
                    delay: 1500
                    text: qsTr("Clear all history")
                    icon.source: "qrc:/icons/edit-clear-history.svg" //works on kde breeze
                    onActivated: {
                        JS.historyDbClear()
                        historyModel.clear()
                    }
                }

                Button {
                    id: closeButton
                    icon.source: "qrc:/icons/mobile-close-app.svg"
                    onClicked: {
                        historyView.visible = false;
                        tabLayout.visible = true
                    }
                }
            }
        }

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

                                        Label {
                                            text: model.title
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: model.url
                                            elide: Text.ElideRight
                                            font.pixelSize: 12
                                            Layout.fillWidth: true
                                        }
                                    }
                            }

                            flat: true

                            onClicked: {
                                currentWebView.url = model.url;
                                historyView.visible = false
                                tabLayout.visible = true
                            }
                        }

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
