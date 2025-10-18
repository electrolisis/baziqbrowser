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
    id: bookmarkView

    ListModel {
        id: bookmarkModel
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
                id: closeButton
                icon.source: "qrc:/icons/mobile-close-app.svg"
                anchors.right: parent.right
                onClicked: {
                    bookmarkView.visible = false
                    tabLayout.visible = true
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

                model: bookmarkModel

                delegate:
                    Row {
                        id: row
                        width: listView.width - scrollBar.width

                        required property int index
                        required property var model

                        Button {
                            id: bookmarkItem
                            width: row.width - removeBookmarkButton.width - 5

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
                                bookmarkView.visible = false
                                tabLayout.visible = true
                            }
                        }

                        Button{
                            id: removeBookmarkButton
                            icon.source: "qrc:/icons/im-ban-kick-user.svg"
                            flat: true
                            height: row.height
                            onClicked: {
                                JS.bookmarkDbDeleteRow(model.id)
                                bookmarkModel.remove(row.index)
                            }
                        }
                    }

                ScrollBar.vertical: ScrollBar { id : scrollBar }
            }
        }
    }

    //
    onVisibleChanged: {
        bookmarkModel.clear()
        JS.bookmarkDbReadAll()
    }
}
