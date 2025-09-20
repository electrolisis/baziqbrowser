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

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    Column {
        width: parent.width
        //padding: 10
        spacing: 10

        Button {
            id: closeButton
            //height: 28  //fusion
            icon.name: "mobile-close-app"
            //icon.source: "qrc:/icons/mobile-close-app.svg"
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

        Text {
            color: sysPalette.windowText
            text: qsTr("Homepage: ")
        }

        TextField {
            id: homePage
            color: sysPalette.windowText
            width: parent.width
            text: appSettings.homePage ? appSettings.homePage : "https://lite.duckduckgo.com/lite/"

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

        Text {
            color: sysPalette.windowText
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

     //}
 }
