// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: root

    property int numberOfMatches: 0
    property int activeMatch: 0
    property alias text: findTextField.text

    function reset() {
        numberOfMatches = 0;
        activeMatch = 0;
        visible = false;
    }

    signal findNext()
    signal findPrevious()
    signal clear()

    padding: 0
    width: parent.width
    //height: navigationBar.height
    //radius: 2

    //SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    //border.width: 1
    //border.color: sysPalette.mid
    //color: "white"

    onVisibleChanged: {
        if (visible)
            findTextField.forceActiveFocus();
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextField {
                id: findTextField
                anchors.fill: parent
                onAccepted: root.findNext()
                onTextChanged: root.findNext()
                onActiveFocusChanged: activeFocus ? selectAll() : deselect()
            }
        }

        Label {
            text: activeMatch + "/" + numberOfMatches
            visible: findTextField.text !== ""
            //color: "black"
        }

        ToolButton {
            icon.name: "go-previous"
            //icon.source: "qrc:/icons/go-previous.svg"
            //text: "<"
            enabled: numberOfMatches > 0
            onClicked: root.findPrevious()
            //contentItem: Text {
                //color: "black"
            //    text: parent.text
            //}navigationBar
        }

        ToolButton {
            icon.name: "go-next"
            //icon.source: "qrc:/icons/go-next.svg"
            //text: ">"
            enabled: numberOfMatches > 0
            onClicked: root.findNext()
            //contentItem: Text {
                //color: "black"
            //    text: parent.text
            //}
        }

        ToolButton {
            icon.name: "mobile-close-app"
            //icon.source: "qrc:/icons/mobile-close-app.svg"
            onClicked: {
                root.clear()
                root.visible = false
            }
        }
    }
}
