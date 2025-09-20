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
//Rectangle {
    id: bookmarkView

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

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
                id: clearButton
                //height: 28 //fusion
                icon.name: "edit-clear-history"
                //icon.source: "qrc:/icons/edit-clear-history.svg"
                anchors.left: parent.left
                onClicked: {
                    JS.bookmarkDbClear()
                    bookmarkModel.clear()
                }
            }

            Button {
                id: closeButton
                //height: 28 //fusion
                icon.name: "mobile-close-app"
                //icon.source: "qrc:/icons/mobile-close-app.svg"
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
                //topMargin: 10

                model: bookmarkModel

                delegate:
                    Row {
                        id: row
                        width: listView.width - scrollBar.width

                        required property int index
                        required property var model

                        Button {
                            id: bookmarkItem
                            //height: 40
                            width: row.width - removeBookmarkButton.width - 5
                            //visible: false

                            contentItem:
                                RowLayout {
                                //spacing: 10
                                //height: 40
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
                                    }
                                    Text {
                                        text: model.url
                                        elide: Text.ElideRight
                                        font.pixelSize: 12
                                        //color: "dimgray"
                                        color: sysPalette.windowText
                                        Layout.fillWidth: true
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
                                bookmarkView.visible = false
                                tabLayout.visible = true
                            }
                        }

                        Button{
                            id: removeBookmarkButton
                            icon.name: "im-ban-kick-user"
                            //icon.source: "qrc:/icons/im-ban-kick-user.svg"
                            // background: Rectangle {
                            //     color: "white"
                            //     // Image {
                            //     //     source: "qrc:/icons/im-ban-kick-user.svg"
                            //     // }
                            // }
                            flat: true
                            height: row.height
                            //anchors.right: parent.right
                            onClicked: {
                                JS.bookmarkDbDeleteRow(model.id)
                                bookmarkModel.remove(row.index)
                                //print(row.index)
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
