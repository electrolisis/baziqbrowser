// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtQuick.Layouts
//
import QtQuick.LocalStorage

Pane {
    id: settingsView

    Pane {
        width: parent.width
        height: parent.height - closeButton.height

    Flickable {
        anchors.fill: parent
        contentHeight: pane.implicitHeight - closeButton.height
        flickableDirection: Flickable.AutoFlickIfNeeded

        Pane {
            id: pane
            width: parent.width
            height: parent.height
            padding: 0

    Column {
        width: parent.width - scrollBar.width
        spacing: 10

        Button {
            id: closeButton
            icon.source: "qrc:/icons/mobile-close-app.svg"
            anchors.right: parent.right
            onClicked: {
                settingsView.visible = false
                tabLayout.visible = true
            }
        }

        Label {
            text: qsTr("Basic")
            font.bold: true
        }

        Label {
            text: qsTr("Homepage / New tab: ")
        }

        Switch {
            id: mostVisitedSwitch
            text: qsTr("Most visited")
            checked: appSettings.homePage == "mostVisited"
            onClicked: {
                if(appSettings.homePage == "mostVisited"){
                    homePage.text = "about:blank"
                }else{
                    homePage.text = "mostVisited"
                    appSettings.homePage = "mostVisited"
                }
            }
        }

        TextField {
            id: homePage
            enabled: !mostVisitedSwitch.checked
            width: parent.width
            //text: appSettings.homePage ? appSettings.homePage : "mostVisited"
            text: appSettings.homePage ? appSettings.homePage : "about:blank"
            //text: appSettings.homePage ? appSettings.homePage : "https://lite.duckduckgo.com/lite/"

            onTextChanged: {
                if(settingsView.visible) {
                    appSettings.homePage = text
                }
            }

            Component.onCompleted: {
                if(appSettings.homePage == "")
                    appSettings.homePage = text
            }
        }

        Label {
            text: qsTr("Profiles")
            font.bold: true
        }

        Label {
            text: qsTr("Current profile: " + currentWebView.profile.storageName)
        }

        Button {
            text: qsTr("Advanced settings")
            onClicked: {
                settingsView.visible = false
                advancedSettingsView.visible = true
            }
        }

     }

        }
        ScrollBar.vertical: ScrollBar { id : scrollBar }
        }
        }
 }
