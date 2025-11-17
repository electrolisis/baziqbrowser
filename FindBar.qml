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

    onVisibleChanged: {
        if (visible){
            findTextField.forceActiveFocus();
        }else{
            findTextField.focus = false
        }
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
        }

        ToolButton {
            icon.source: "qrc:/icons/go-previous.svg"
            enabled: numberOfMatches > 0
            onClicked: root.findPrevious()
        }

        ToolButton {
            icon.source: "qrc:/icons/go-next.svg"
            enabled: numberOfMatches > 0
            onClicked: root.findNext()
        }

        ToolButton {
            icon.source: "qrc:/icons/mobile-close-app.svg"
            onClicked: {
                root.clear()
                root.visible = false
            }
        }
    }
}
