// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtWebEngine

QtObject {
    id: root

    property string profileName: "default"
    required property var builtInStyles
    required property var httpAcceptLanguageString

    //https://doc.qt.io/qt-6/qml-qtwebengine-webengineprofile.html
    property QtObject defaultProfile: WebEngineProfile {
        storageName: profileName
        offTheRecord: false
        httpAcceptLanguage: httpAcceptLanguageString+", utf-8;q=0.9"
        spellCheckEnabled: false
    }

    property QtObject otrProfile: WebEngineProfile {
        offTheRecord: true
    }

    property Component browserWindowComponent: BrowserWindow {
        applicationRoot: root
    }

    property Component browserDialogComponent: BrowserDialog {
        onClosing: destroy()
    }

    function createWindow(profile) {
        var newWindow = browserWindowComponent.createObject(root);
        newWindow.currentWebView.profile = profile;
        profile.downloadRequested.connect(newWindow.onDownloadRequested);
        return newWindow;
    }

    function createDialog(profile) {
        var newDialog = browserDialogComponent.createObject(root);
        newDialog.currentWebView.profile = profile;
        return newDialog;
    }

    function load(url) {
        var browserWindow = createWindow(defaultProfile);
        browserWindow.currentWebView.url = url;
    }

    function setProfile(profile) {
        profileName = profile;
    }
}
