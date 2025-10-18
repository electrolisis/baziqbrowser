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

    property alias javaScriptEnabled: javaScriptEnabled.checked
    property alias webRTCPublicInterfacesOnly: webRTCPublicInterfacesOnly.checked
    property alias readingFromCanvasEnabled: readingFromCanvasEnabled.checked
    property alias webGLEnabled: webGLEnabled.checked

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
                advancedSettingsView.visible = false
                tabLayout.visible = true
            }
        }

        CheckBox {
            id: javaScriptEnabled
            text: "JavaScript On"
            checkable: true
            //checked: appSettings.javaScriptEnabled
            checked: WebEngine.settings.javascriptEnabled
        }

        CheckBox {
            id: webRTCPublicInterfacesOnly
            text: "webRTCPublicInterfacesOnly"
            checkable: true
            checked: !WebEngine.settings.webRTCPublicInterfacesOnly //
        }

        CheckBox {
            id: readingFromCanvasEnabled
            text: "readingFromCanvasEnabled"
            checkable: true
            //checked: appSettings.readingFromCanvasEnabled
            checked: WebEngine.settings.readingFromCanvasEnabled
        }

        CheckBox {
            id: webGLEnabled
            text: "webGLEnabled"
            checkable: true
            //checked: appSettings.webGLEnabled
            checked: WebEngine.settings.webGLEnabled
        }

        Label {
            text: "User Agent: "
        }

        Row {
            width: parent.width

            TextField {
                id: uaText
                font.pixelSize: 12
                width: parent.width - defaultUaButton.width
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
                icon.source: "qrc:/icons/edit-undo.svg"
                onClicked: {
                    appSettings.httpUserAgent = WebEngine.defaultProfile.httpUserAgent
                    currentWebView.profile.httpUserAgent = WebEngine.defaultProfile.httpUserAgent
                }
            }
        }

        Button {
            id: clearCookies
            text: qsTr("Clear cookies")
            onClicked: {
                Utils.clearCookies(currentWebView.profile.persistentStoragePath)
                clearCookiesMessage.visible = true
            }
        }

        Label {
            id: clearCookiesMessage
            text: qsTr("Restart required")
            color: "#e41e25"
            visible: false
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

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
        //
         Label {
             text: qsTr("Style:")
             font.bold: true
         }

         ComboBox {
             id: styleBox
             property int styleIndex: -1
             onActivated: appSettings.style = currentValue
             model: builtInStyles
             Component.onCompleted: {
                 styleIndex = find(appSettings.style, Qt.MatchFixedString)
                 if (styleIndex !== -1)
                     currentIndex = styleIndex
             }
             Layout.fillWidth: true
         }

         Label {
             text: qsTr("Restart required")
             color: "#e41e25"
             opacity: styleBox.currentIndex !== styleBox.styleIndex ? 1.0 : 0.0
             horizontalAlignment: Label.AlignHCenter
             verticalAlignment: Label.AlignVCenter
             Layout.fillWidth: true
             Layout.fillHeight: true
         }

     }

        }
        ScrollBar.vertical: ScrollBar { id : scrollBar }
        }
        }

 }
