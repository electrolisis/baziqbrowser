// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtQuick.Layouts

Pane {
    id: downloadView

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    ListModel {
        id: downloadModel
        property var downloads: []
    }

    function append(download) {
        downloadModel.append(download);
        downloadModel.downloads.push(download);
    }

    Column {
        width: parent.width
        height: parent.height

        Button {
            id: closeButton
            //height: 28 //fusion
            icon.name: "mobile-close-app"
            //icon.source: "qrc:/icons/mobile-close-app.svg"
            anchors.right: parent.right
            onClicked: {
                downloadView.visible = false;
                tabLayout.visible = true
            }
        }

        Component {
            id: downloadItemDelegate

            Rectangle {
                id : rectangle
                width: listView.width - scrollBar.width
                height: childrenRect.height
                anchors.margins: 10
                radius: 3
                color: "transparent"
                border.color: sysPalette.mid

                Rectangle {
                    id: progressBar

                    property real progress: downloadModel.downloads[index]
                                           ? downloadModel.downloads[index].receivedBytes / downloadModel.downloads[index].totalBytes : 0

                    radius: 3
                    color: width == (rectangle.width - cancelButton.width - 1) ? "mediumseagreen" : "skyblue"
                    width: (rectangle.width - cancelButton.width - 1) * progress
                    height: cancelButton.height

                    Behavior on width {
                        SmoothedAnimation { duration: 100 }
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20
                    }

                    Label {
                        id: label
                        text: downloadModel.downloads[index] ? downloadModel.downloads[index].downloadDirectory + "/" + downloadModel.downloads[index].downloadFileName : qsTr("")
                        anchors {
                            verticalCenter: cancelButton.verticalCenter
                            left: parent.left
                            right: cancelButton.left
                        }
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        elide: Label.ElideRight
                    }

                    Button {
                        id: cancelButton
                        anchors.right: parent.right
                        icon.name: "dialog-cancel"
                        //icon.source: "qrc:/icons/dialog-cancel.svg"
                        onClicked: {
                            var download = downloadModel.downloads[index];

                            download.cancel();

                            downloadModel.downloads = downloadModel.downloads.filter(function (el) {
                                return el.id !== download.id;
                            });
                            downloadModel.remove(index);
                        }
                    }
                }
            }
        }

        Pane {
            id: paneDiv
            width: parent.width
            height: 10
        }

        //Rectangle {
        Pane {
            width: parent.width
            height: parent.height - closeButton.height - paneDiv.height

            ListView {
                id: listView
                anchors {
                    //topMargin: 50
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width
                spacing: 10

                model: downloadModel
                delegate: downloadItemDelegate

                ScrollBar.vertical: ScrollBar { id : scrollBar }
            }
        }
    }
}
