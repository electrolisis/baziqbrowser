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
    id: mostVisitedView

    ListModel {
        id: historyModel
    }

    Column {
        width: parent.width
        height: parent.height

        Pane {
            width: parent.width
            height: parent.height

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
                                        width: 32; height: 32
                                        sourceSize: Qt.size(width, height)
                                        //source: model.icon
                                        source: "image://favicon/" + model.url
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
                                mostVisitedView.visible = false
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
