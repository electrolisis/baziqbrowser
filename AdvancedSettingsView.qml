// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebEngine
import QtQuick.Layouts

import BrowserUtils

//
import QtQuick.LocalStorage

Pane {
    id: advancedSettingsView

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property alias javaScriptEnabled: javaScriptEnabled.checked
    property alias webRTCPublicInterfacesOnly: webRTCPublicInterfacesOnly.checked
    property alias readingFromCanvasEnabled: readingFromCanvasEnabled.checked
    property alias webGLEnabled: webGLEnabled.checked
    property bool freeze : freezeCheck.checked
    //property int freezeDelay : freezeSpin.enabled && freezeSpin.value
    property int freezeDelay : freezeSpin.value
    property bool forceFreeze : forceFreeze.checked

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
                advancedSettingsView.visible = false
                tabLayout.visible = true
            }
        }

        CheckBox {
            id: javaScriptEnabled
            text: "JavaScript On"
            checkable: true
            checked: (appSettings.javaScriptEnabled == "") ? false : WebEngine.settings.javascriptEnabled
        }

        CheckBox {
            id: webRTCPublicInterfacesOnly
            text: "webRTCPublicInterfacesOnly"
            checkable: true
            checked: (appSettings.webRTCPublicInterfacesOnly == "") ? true : WebEngine.settings.webRTCPublicInterfacesOnly
        }

        CheckBox {
            id: readingFromCanvasEnabled
            text: "readingFromCanvasEnabled"
            checkable: true
            checked: appSettings.readingFromCanvasEnabled == "" ? false : WebEngine.settings.readingFromCanvasEnabled
        }

        CheckBox {
            id: webGLEnabled
            text: "webGLEnabled"
            checkable: true
            checked: appSettings.webGLEnabled == "" ? false : WebEngine.settings.webGLEnabled
        }

        Text {
            color: sysPalette.windowText
            text: "User Agent: "
        }

        Row {
            width: parent.width

            TextField {
                id: uaText
                color: sysPalette.windowText
                font.pixelSize: 12
                width: parent.width - defaultUaButton.width
                //enabled: false
                text: appSettings.httpUserAgent ? appSettings.httpUserAgent : currentWebView.profile.httpUserAgent

                onTextChanged: {
                    if(advancedSettingsView.visible) {
                        appSettings.httpUserAgent = text
                        currentWebView.profile.httpUserAgent = text
                    }
                }
            }

            Button {
                id: defaultUaButton
                icon.name: "edit-undo"
                onClicked: {
                    appSettings.httpUserAgent = WebEngine.defaultProfile.httpUserAgent
                    currentWebView.profile.httpUserAgent = WebEngine.defaultProfile.httpUserAgent
                }
            }
        }

        Text {
             color: sysPalette.windowText
             text: qsTr("Automatic lifecycle control: ")
         }

        Row{
            CheckBox {
                id: freezeCheck
                text: qsTr("Freeze after delay (seconds)")
                checked: appSettings.freeze
            }
            SpinBox {
                id: freezeSpin
                editable: true
                enabled: freezeCheck.checked
                value: (appSettings.freezeDelay == 0) ? 60 : appSettings.freezeDelay
                from: 10
                to: 60*60
            }
            CheckBox {
                id: forceFreeze
                text: qsTr("Force")
                checked: appSettings.forceFreeze
            }
        }

        Button {
            id: clearCookies
            text: qsTr("Clear cookies")
            onClicked: {
                Utils.clearCookies(currentWebView.profile.persistentStoragePath)
            }
        }

         // Label {
         //     text: "Content filter (blocker)"
         //     font.bold: true
         // }

         // Text {
         //     color: sysPalette.windowText
         //     text: qsTr(" ...")
         // }

         // Label {
         //     text: "Tor Network"
         //     font.bold: true
         // }

         // Text {
         //     color: sysPalette.windowText
         //     text: qsTr(" ...")
         // }

         Label {
             text: qsTr("Infos")
             font.bold: true
         }

         Button {
             id: qtversion
             text: qsTr("Qt Version")
             onClicked: {
                 tabBar.createTab(currentWebView.profile, true, "chrome:qt");
                 advancedSettingsView.visible = false
                 tabLayout.visible = true
             }
         }

     }

     //}
 }
