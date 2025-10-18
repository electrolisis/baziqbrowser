// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtQuick.Layouts

Pane {
    id: tabsView

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    ListModel {
        id: tabsModel
        property var tabs: []
    }

    function append(tab) {
        tabsModel.append(tab);
        tabsModel.tabs.push(tab);
    }

    Column {
        width: parent.width
        height: parent.height

        RowLayout{
            anchors.right: parent.right

            Button {
                id: addTabButton
                icon.source: "qrc:/icons/list-add.svg"
                onClicked: {
                    tabsView.visible = false;
                    tabLayout.visible = true
                    tabBar.createTab(tabBar.count !== 0 ? currentWebView.profile : defaultProfile);
                }
            }

            Button {
                id: closeButton
                icon.source: "qrc:/icons/mobile-close-app.svg"
                onClicked: {
                    tabsView.visible = false;
                    tabLayout.visible = true
                }
            }
        }

        Component {
            id: tabItemDelegate

            Rectangle {
                id : rectangle
                width: listView.width - scrollBar.width
                height: childrenRect.height
                anchors.margins: 10
                radius: 3
                color: "transparent"

                Rectangle {
                    width: 0
                    height: removeButton.height
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 20
                    }

                    Button {
                        id: label
                        anchors {
                            verticalCenter: removeButton.verticalCenter
                            left: parent.left
                            right: removeButton.left
                        }
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        height: removeButton.height

                        contentItem: Text {
                            text: tabsModel.tabs[index].tabTitle
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            color: (index == tabBar.currentIndex) ? sysPalette.highlight : sysPalette.alternateBase
                            border.color: sysPalette.alternateBase
                        }

                        onClicked: {
                            tabBar.setCurrentIndex(index);
                            tabsView.visible = false;
                            tabLayout.visible = true
                        }
                    }

                    Button {
                        id: removeButton
                        anchors.right: parent.right
                        icon.source: "qrc:/icons/im-ban-kick-user.svg"
                        visible: (tabBar.count === 1) ? false : true
                        onClicked: {
                            var tab = tabsModel.tabs[index];
                            tabsModel.tabs = tabsModel.tabs.filter(function (el) {
                                  return el.id !== tab.id;
                              });
                            tabBar.removeView(index);
                            tabsModel.remove(index)
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

        Pane {
            width: parent.width
            height: parent.height - closeButton.height - paneDiv.height

            ListView {
                id: listView
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width
                spacing: 10

                model: tabsModel
                delegate: tabItemDelegate

                ScrollBar.vertical: ScrollBar { id : scrollBar }
            }
        }
    }

    function tabsModelRemoveTab (index){
        var tab = tabsModel.tabs[index];
        tabsModel.tabs = tabsModel.tabs.filter(function (el) {
              return el.id !== tab.id;
          });
        tabsModel.remove(index)
    }
}
