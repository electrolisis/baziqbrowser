// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtWebEngine

QtObject {
    id: root

    property QtObject defaultProfile: WebEngineProfile {
        //storageName: "Profile"
        storageName: "Profile-alt-0"
        //storageName: "Profile-email"
        //storageName: "Profile-universidade"
        //storageName: "Profile-comunicate"
        //storageName: "Profile-market"
        //storageName: "Profile-apps"
        offTheRecord: false
        //?
        //httpUserAgent: "Mozilla/5.0 (Linux) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0 Safari/537.36"
        //gmail works->
        //httpUserAgent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0 Safari/537.36"
        //
        //httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/6.7.2 Chrome/118.0.5993.220 Safari/537.36"
        //alt?
        httpUserAgent: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chromium/118.0"
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
}
