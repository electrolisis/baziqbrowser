// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// https://doc.qt.io/qt-6/qtwebengine-qmlmodule.html

import QtCore
//import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtWebEngine
import BrowserUtils
//
import QtQuick.LocalStorage
import "Database.js" as JS

ApplicationWindow {
    id: browserWindow
    property QtObject applicationRoot
    property Item currentWebView: tabBar.currentIndex < tabBar.count ? tabLayout.children[tabBar.currentIndex] : null
    property int previousVisibility: Window.Windowed
    //property int createdTabs: 0

    //width: 800
    //height: 600
    width: Screen.width * 0.75
    height: Screen.height * 0.75
    visible: true
    title: currentWebView && currentWebView.title

    // Make sure the Qt.WindowFullscreenButtonHint is set on OS X.
    //Component.onCompleted: flags = flags | Qt.WindowFullscreenButtonHint

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    onCurrentWebViewChanged: {
        findBar.clear()
        findBar.reset();
    }

    // When using style "mac", ToolButtons are not supposed to accept focus.
    // bool platformIsMac: Qt.platform.os === "osx"

    Settings {
        id : appSettings
        category: profileName
        property alias javaScriptEnabled: advancedSettingsView.javaScriptEnabled
        property alias webRTCPublicInterfacesOnly: advancedSettingsView.webRTCPublicInterfacesOnly
        property alias readingFromCanvasEnabled: advancedSettingsView.readingFromCanvasEnabled
        property alias webGLEnabled: advancedSettingsView.webGLEnabled
        //
        property string httpUserAgent
        property bool freeze : advancedSettingsView.freeze
        property int freezeDelay : advancedSettingsView.freezeDelay
        property int forceFreeze : advancedSettingsView.forceFreeze
        property bool dbCreated: false
        property string homePage
    }

    function dbInit() {
        if(!appSettings.dbCreated) {
            JS.dbInit()
            appSettings.dbCreated = true
        }
    }

    Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloadView.visible = !downloadView.visible;
        }
    }
    Action {
        id: focus
        shortcut: "Ctrl+L"
        onTriggered: {
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }
    Action {
        shortcut: StandardKey.Refresh
        onTriggered: {
            if (currentWebView)
                currentWebView.reload();
        }
    }
    Action {
        shortcut: StandardKey.AddTab
        onTriggered: {
            tabBar.createTab(tabBar.count !== 0 ? currentWebView.profile : defaultProfile);
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }
    Action {
        shortcut: StandardKey.Close
        onTriggered: {
            currentWebView.triggerWebAction(WebEngineView.RequestClose);
        }
    }
    Action {
        shortcut: StandardKey.Quit
        onTriggered: browserWindow.close()
    }
    Action {
        shortcut: "Escape"
        onTriggered: {
            if (currentWebView.state === "FullScreen") {
                browserWindow.visibility = browserWindow.previousVisibility;
                fullScreenNotification.hide();
                currentWebView.triggerWebAction(WebEngineView.ExitFullScreen);
            }

            if (findBar.visible)
                findBar.visible = false;
        }
    }
    Action {
        shortcut: "Ctrl+0"
        onTriggered: currentWebView.zoomFactor = 1.0
    }
    Action {
        shortcut: StandardKey.ZoomOut
        onTriggered: currentWebView.zoomFactor -= 0.1
    }
    Action {
        shortcut: StandardKey.ZoomIn
        onTriggered: currentWebView.zoomFactor += 0.1
    }

    Action {
        shortcut: StandardKey.Copy
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Copy)
    }
    Action {
        shortcut: StandardKey.Cut
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Cut)
    }
    Action {
        shortcut: StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Paste)
    }
    Action {
        shortcut: "Shift+"+StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.PasteAndMatchStyle)
    }
    Action {
        shortcut: StandardKey.SelectAll
        onTriggered: currentWebView.triggerWebAction(WebEngineView.SelectAll)
    }
    Action {
        shortcut: StandardKey.Undo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Undo)
    }
    Action {
        shortcut: StandardKey.Redo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Redo)
    }
    Action {
        shortcut: StandardKey.Back
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Back)
    }
    Action {
        shortcut: StandardKey.Forward
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Forward)
    }
    Action {
        shortcut: StandardKey.Find
        onTriggered: {
            if(!findBar.visible) {
                findBar.visible = true
            }else{
                findBar.clear()
                findBar.reset()
            }
        }
    }
    Action {
        shortcut: StandardKey.FindNext
        onTriggered: findBar.findNext()
    }
    Action {
        shortcut: StandardKey.FindPrevious
        onTriggered: findBar.findPrevious()
    }

    Component {
        id: tabButtonComponent

        TabButton {
            id: tabButton
            property string tabTitle: "New Tab"
            property bool lifecycleStateIcon: false

            //implicitHeight: closeTabbutton.height + 4 // fusion, breeze
            implicitHeight: navigationBar.height// fusion
            //padding: 0

            // background: Rectangle {
            //     //border.width: 1
            //     //border.color: sysPalette.mid
            //     color: sysPalette.window
            // }

                ToolButton {
                    id: lcsButton
                    visible: lifecycleStateIcon
                    enabled: false
                    anchors.verticalCenter: parent.verticalCenter
                    icon.name: "system-suspend-hibernate"
                    //icon.source: "qrc:/icons/system-suspend-hibernate.svg"
                    icon.color: sysPalette.windowText
                }
                //
                Text {
                    id: text
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    //anchors.leftMargin: 60
                    anchors.leftMargin: lcsButton.visible ? 45 : 5
                    anchors.rightMargin: 45
                    text: tabButton.tabTitle
                    elide: Text.ElideRight
                    color: sysPalette.windowText
                }

                ToolButton {
                    id: closeTabbutton
                    anchors.right: parent.right
                    //anchors.top: parent.top
                    //anchors.bottom: parent.bottom
                    anchors.verticalCenter: parent.verticalCenter
                    //topInset: 3
                    //anchors.verticalCenterOffset: 3 //breeze
                    //weird solution: if fusion 0 if breeze 3
                    anchors.verticalCenterOffset: (closeTabbutton.height > 28) ? 3 : 0
                    anchors.rightMargin: 2
                    icon.name: "tab-close"
                    onClicked: tabButton.closeTab()
                }
            //}

            onClicked: {
                addressBar.text = tabLayout.itemAt(TabBar.index).url;
                //
                //print(tabLayout.currentIndex + " / " + tabBar.currentIndex)
                //print(currentWebView.profile.httpUserAgent)
            }

            // onPressedChanged: {
            //     tabButton.backgroundColor = sysPalette.accent
            // }

            function closeTab() {
                tabBar.removeView(TabBar.index);
            }
        }
    }

    TabBar {
        id: tabBar
        //anchors.top: parent.top
        //implicitWidth: parent.width

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        //padding: 0

        Component.onCompleted: {
            dbInit()
            createTab(defaultProfile)
            currentWebView.profile.httpUserAgent = appSettings.httpUserAgent
        }

        currentIndex: tabLayout.currentIndex

        function createTab(profile, focusOnNewTab = true, url = undefined) {
            var webview = tabComponent.createObject(tabLayout, {profile: profile});
            //var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle: Qt.binding(function () { return webview.title; })});
            var newTabButton =
                tabButtonComponent.createObject(tabBar, {
                    lifecycleStateIcon: Qt.binding(
                        function () {
                            switch (webview.lifecycleState) {
                            case WebEngineView.LifecycleState.Active:
                                return false
                            case WebEngineView.LifecycleState.Frozen:
                                return true
                            }
                    }),
                    tabTitle: Qt.binding(
                        function () {
                            return webview.title;
                        })});

            tabBar.addItem(newTabButton);

            if (focusOnNewTab) {
                tabBar.setCurrentIndex(tabBar.count - 1);
            }

            if (url !== undefined) {
                webview.url = url;
            } else {
                if (tabBar.count === 1) {
                    webview.url = appSettings.homePage;
                }else{
                    webview.url = "about:blank";
                }
            }
            //
            if (tabBar.count === 1) {
                tabBar.visible = false
                tabBar.height = 0
            } else {
                tabBar.visible = true
                //tabBar.height = 30 //fusion, breeze
                //tabBar.height = 40 //basic
                tabBar.height = navigationBar.height
            }
            //
            return webview;
        }

        function removeView(index) {
            //if (tabBar.count > 1) {
                tabBar.removeItem(tabBar.itemAt(index));
                tabLayout.children[index].destroy();
            //} else {
                //browserWindow.close();
            //}
            //
            if (tabBar.count === 1) {
                tabBar.visible = false
                tabBar.height = 0
            } else {
                tabBar.visible = true
                //tabBar.height = 30 //fusion, breeze
                //tabBar.height = 40 //basic
                tabBar.height = navigationBar.height
            }
            //
        }

        Component {
            id: tabComponent
            WebEngineView {
                id: webEngineView
                focus: true

                onLinkHovered: function(hoveredUrl) {
                    if (hoveredUrl == "") // ==
                        hideStatusText.start();
                    else {
                        statusText.text = hoveredUrl;
                        statusBubble.visible = true;
                        hideStatusText.stop();
                    }
                }

                states: [
                    State {
                        name: "FullScreen"
                        PropertyChanges {
                            target: tabBar
                            visible: false
                            height: 0
                        }
                        PropertyChanges {
                            target: navigationBar
                            visible: false
                            height: 0
                        }
                    }
                ]

                //https://doc.qt.io/qt-6/qml-qtwebengine-webenginesettings.html
                //
                /*
                Most trackers run on JavaScript, and they can’t gather much
                of the information used to determine your browser fingerprint without it.
                Thus, your browser looks a lot less distinct, and is more protected.
                But there is a trade off. Disabling JavaScript
                breaks a staggering amount of websites, and limits the functionality of many more.
                */
                settings.javascriptEnabled: appSettings.javaScriptEnabled
                //limits WebRTC to public IP addresses only
                settings.webRTCPublicInterfacesOnly: appSettings.webRTCPublicInterfacesOnly
                //disable to prevent canvas fingerprinting
                settings.readingFromCanvasEnabled: appSettings.readingFromCanvasEnabled
                //
                settings.webGLEnabled: appSettings.webGLEnabled
                //
                settings.allowRunningInsecureContent: false
                settings.pdfViewerEnabled: false

                onCertificateError: function(error) {
                    error.defer();
                    sslDialog.enqueue(error);
                }

                onNewWindowRequested: function(request) {
                    if (!request.userInitiated)
                        console.warn("Blocked a popup window.");
                    else if (request.destination === WebEngineNewWindowRequest.InNewTab) {
                        var tab = tabBar.createTab(currentWebView.profile, true, request.requestedUrl);
                        tab.acceptAsNewWindow(request);
                    } else if (request.destination === WebEngineNewWindowRequest.InNewBackgroundTab) {
                        var backgroundTab = tabBar.createTab(currentWebView.profile, false);
                        backgroundTab.acceptAsNewWindow(request);
                    } else if (request.destination === WebEngineNewWindowRequest.InNewDialog) {
                        var dialog = applicationRoot.createDialog(currentWebView.profile);
                        dialog.currentWebView.acceptAsNewWindow(request);
                    } else {
                        var window = applicationRoot.createWindow(currentWebView.profile);
                        window.currentWebView.acceptAsNewWindow(request);
                    }
                }

                onFullScreenRequested: function(request) {
                    if (request.toggleOn) {
                        webEngineView.state = "FullScreen";
                        browserWindow.previousVisibility = browserWindow.visibility;
                        browserWindow.showFullScreen();
                        fullScreenNotification.show();
                    } else {
                        webEngineView.state = "";
                        browserWindow.visibility = browserWindow.previousVisibility;
                        fullScreenNotification.hide();
                    }
                    request.accept();
                }

                onRegisterProtocolHandlerRequested: function(request) {
                    console.log("accepting registerProtocolHandler request for "
                                + request.scheme + " from " + request.origin);
                    request.accept();
                }

                onRenderProcessTerminated: function(terminationStatus, exitCode) {
                    var status = "";
                    switch (terminationStatus) {
                    case WebEngineView.NormalTerminationStatus:
                        status = "(normal exit)";
                        break;
                    case WebEngineView.AbnormalTerminationStatus:
                        status = "(abnormal exit)";
                        break;
                    case WebEngineView.CrashedTerminationStatus:
                        status = "(crashed)";
                        break;
                    case WebEngineView.KilledTerminationStatus:
                        status = "(killed)";
                        break;
                    }

                    print("Render process exited with code " + exitCode + " " + status);
                    reloadTimer.running = true;
                }

                onSelectClientCertificate: function(selection) {
                    selection.certificates[0].select();
                }

                onFindTextFinished: function(result) {
                    if (!findBar.visible)
                        findBar.visible = true;

                    findBar.numberOfMatches = result.numberOfMatches;
                    findBar.activeMatch = result.activeMatch;
                }

                onLoadingChanged: function(loadRequest) {
                    if (loadRequest.status === WebEngineView.LoadStartedStatus)
                        findBar.clear()
                        findBar.reset();
                        //
                    if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                        if(currentWebView.title !== "about:blank") {
                            if(currentWebView.url !== "about:blank") {
                                JS.historyDbInsert(currentWebView.title,currentWebView.url,"")
                                //JS.historyDbInsert(currentWebView.title,currentWebView.url,currentWebView.icon)
                            }
                        }
                    }
                }

                onFeaturePermissionRequested: function(securityOrigin, feature) {
                    featurePermissionDialog.securityOrigin = securityOrigin;
                    featurePermissionDialog.feature = feature;
                    featurePermissionDialog.visible = true;
                }

                Timer {
                    id: reloadTimer
                    interval: 0
                    running: false
                    repeat: false
                    onTriggered: currentWebView.reload()
                }

                Timer {
                    interval: {
                        if(webEngineView.visible)
                            0
                        else
                            appSettings.freezeDelay * 1000
                    }
                    running: !webEngineView.visible
                    repeat: true
                    onTriggered: {
                        if(appSettings.freeze && !webEngineView.visible) {
                            if (!appSettings.forceFreeze) {
                                webEngineView.lifecycleState = webEngineView.recommendedState
                            }else{
                                //if(!webEngineView.visible)
                                   webEngineView.lifecycleState = 1
                                }
                            //print(webEngineView.recommendedState)
                        }
                    }
                }
            }
        }
    }

    //
    ToolBar {
        //visible: false
        id: navigationBar

        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.topMargin: 2 //fusion, breeze
        //anchors.topMargin: (tabBar.count > 1) ? 5 : 0 //basic
        padding: 0 // kde/breeze style (do not remove)

        //height: 30 // style?
        //height: settingsMenuButton.height + 2

        RowLayout {
            id: navigationBarRow
            anchors.fill: parent

            ToolButton {
                id: backButton
                icon.name: "go-previous" //use kde breeze icon theme
                //icon.source: "qrc:/icons/go-previous.svg" //use app icon file
                onClicked: currentWebView.goBack()
                enabled: currentWebView && currentWebView.canGoBack
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            ToolButton {
                id: forwardButton
                icon.name: "go-next"
                //icon.source: "qrc:/icons/go-next.svg"
                onClicked: currentWebView.goForward()
                enabled: currentWebView && currentWebView.canGoForward
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            ToolButton {
                id: reloadButton
                icon.name: currentWebView && currentWebView.loading ? "dialog-cancel" : "view-refresh"
                //icon.source: currentWebView && currentWebView.loading ? "qrc:/icons/dialog-cancel.svg" : "qrc:/icons/view-refresh.svg"
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            TextField {
                id: addressBar
                //implicitHeight: 28 // fusion, breeze

                    BusyIndicator {
                        visible: (currentWebView && currentWebView.loadProgress < 100) ? true : false
                        anchors.verticalCenter: addressBar.verticalCenter;
                        leftInset: 0
                        topInset: 0
                        rightInset: 0
                        bottomInset: 0
                        padding: 0
                        width: 16; height: 16
                        x: 5
                        z: 2
                    }
                    Image {
                        visible: (currentWebView && currentWebView.loadProgress < 100) ? false : true
                        anchors.verticalCenter: addressBar.verticalCenter;
                        x: 5
                        z: 2
                        id: faviconImage
                        width: 16; height: 16
                        sourceSize: Qt.size(width, height)
                        source: currentWebView && currentWebView.icon ? currentWebView.icon : ''
                    }
                //}
                //

                MouseArea {
                    id: textFieldMouseArea
                    acceptedButtons: Qt.RightButton
                    anchors.fill: parent
                    onClicked: {
                        var textSelectionStartPos = addressBar.selectionStart;
                        var textSelectionEndPos = addressBar.selectionEnd;
                        textFieldContextMenu.open();
                        addressBar.select(textSelectionStartPos, textSelectionEndPos);
                    }
                    Menu {
                        id: textFieldContextMenu
                        x: textFieldMouseArea.mouseX
                        y: textFieldMouseArea.mouseY
                        MenuItem {
                            text: qsTr("Cut")
                            onTriggered: addressBar.cut()
                            enabled: addressBar.selectedText.length > 0
                        }
                        MenuItem {
                            text: qsTr("Copy")
                            onTriggered: addressBar.copy()
                            enabled: addressBar.selectedText.length > 0
                        }
                        MenuItem {
                            text: qsTr("Paste")
                            onTriggered: addressBar.paste()
                            enabled: addressBar.canPaste
                        }
                        MenuItem {
                            text: qsTr("Delete")
                            onTriggered: addressBar.text = qsTr("")
                            enabled: addressBar.selectedText.length > 0
                        }
                        MenuSeparator {}
                        MenuItem {
                            text: qsTr("Select All")
                            onTriggered: addressBar.selectAll()
                            enabled: addressBar.text.length > 0
                        }
                    }
                }

                leftPadding: 26
                focus: true
                Layout.fillWidth: true
                Binding on text {
                    when: currentWebView
                    value: currentWebView.url
                }

                property string imputText

                onAccepted: {
                    currentWebView.url = Utils.fromUserInput(text)
                }

                selectByMouse: true

                onTextChanged: {
                    imputText = JS.bookmarkDbReadUrl(text)
                    if(imputText === text) {
                        addBookmarkButton.icon.name = "bookmarks-bookmarked"
                        //addBookmarkButton.icon.source = "qrc:/icons/bookmarks-bookmarked.svg"
                        addBookmarkButton.enabled = false
                    }else {
                        addBookmarkButton.icon.name = "bookmarks"
                        //addBookmarkButton.icon.source = "qrc:/icons/bookmarks.svg"
                        addBookmarkButton.enabled = true
                    }
                }
            }
            // //
            // ProgressBar {
            //     //visible: false
            //     id: progressBar
            //     //height: addressBar.height
            //     //width: addressBar.width
            //     // anchors {
            //     //     top: addressBar.top
            //     //     left: addressBar.left
            //     //     right: addressBar.right
            //     //     leftMargin: addressBar.leftMargin
            //     //     rightMargin: addressBar.rightMargin
            //     // }
            //     //anchors.fill: addressBar

            //     background: Item {}
            //     // background: Rectangle {
            //     //     //border.width: 1
            //     //     //border.color: sysPalette.mid
            //     //     //color: sysPalette.window
            //     //     //color: "transparent"
            //     //     //height: addressBar.height
            //     //     //width: addressBar.width
            //     //     //radius: 32
            //     // }
            //     z: -1
            //     from: 0
            //     to: 100
            //     value: (currentWebView && currentWebView.loadProgress < 100) ? currentWebView.loadProgress : 0
            // }
            //
            ToolButton {
                id: addBookmarkButton
                icon.name: "bookmarks"
                //icon.source: "qrc:/icons/bookmarks.svg"
                enabled: false
                onClicked: {
                    JS.bookmarkDbInsert(currentWebView.title,currentWebView.url,"")
                    //JS.bookmarkDbInsert(currentWebView.title,currentWebView.url,currentWebView.icon)
                    addBookmarkButton.enabled = false
                    icon.name = "bookmarks-bookmarked"
                    //icon.source = "qrc:/icons/bookmarks-bookmarked.svg"
                    //print(currentWebView.icon)
                }
            }
            //
            //
            ToolButton {
            //RoundButton {
                id: addTabButton
                //icon.source: currentWebView && currentWebView.loading ? "qrc:/icons/process-stop.png" : "qrc:/icons/view-refresh.png"
                //onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                //
                //text: "+"
                //visible: (tabBar.count < 10) ? true : false
                icon.name: "list-add"
                //icon.source: "qrc:/icons/list-add.svg"
                onClicked: {
                    tabBar.createTab(tabBar.count !== 0 ? currentWebView.profile : defaultProfile);
                    addressBar.forceActiveFocus();
                    addressBar.selectAll();
                }
                //
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            //
            ToolButton {
                id: securityButton
                text: appSettings.javaScriptEnabled ? "js" : "<s>js</s>"
                implicitWidth: settingsMenuButton.width //?
                implicitHeight: settingsMenuButton.height //?
                flat: true
                onClicked: {
                    appSettings.javaScriptEnabled = appSettings.javaScriptEnabled ? false : true
                }
            }
            //
            // ToolButton {
            //     id: createdTabsButton
            //     text: tabBar.count
            //     implicitWidth: settingsMenuButton.width
            //     implicitHeight: settingsMenuButton.height
            //     //flat: true
            //     visible: (tabBar.count > 1) ? true : false
            //     onClicked: {
            //     }
            // }
            //
            ToolButton {
                id: settingsMenuButton
                icon.name: "overflow-menu"
                //icon.source: "qrc:/icons/overflow-menu.svg"
                onClicked: settingsMenu.open()
                Menu {
                    id: settingsMenu
                    y: settingsMenuButton.height
                    MenuItem {
                        id: bookmark
                        text: qsTr("Bookmarks")
                        onClicked: {
                            bookmarkView.visible = !bookmarkView.visible;
                            tabLayout.visible = false // to block scroll
                            //print(settingsMenuButton.height)
                        }
                    }
                    MenuItem {
                        id: history
                        text: qsTr("History")
                        //checkable: true
                        //checked: WebEngine.settings.autoLoadImages
                        onClicked: {
                            //JS.dbReadAll();
                            historyView.visible = !historyView.visible;
                            tabLayout.visible = false // to block scroll
                        }
                    }
                    MenuItem {
                        id: downloads
                        text: qsTr("Downloads")
                        //checkable: true
                        //checked: WebEngine.settings.autoLoadImages
                        onClicked: {
                            downloadView.visible = !downloadView.visible
                            tabLayout.visible = false // to block scroll
                        }
                    }
                    MenuItem {
                        id: settings
                        text: qsTr("Settings")
                        onClicked: {
                            settingsView.visible = !settingsView.visible;
                            tabLayout.visible = false // to block scroll
                        }
                    }
                }
            }
        }
    }
    //

    StackLayout {
        id: tabLayout
        currentIndex: tabBar.currentIndex
        anchors.top: findBar.visible ? findBar.bottom : navigationBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.topMargin: 7
        //visible: false
    }

    Dialog {
        id: sslDialog
        anchors.centerIn: parent
        contentWidth: Math.max(mainTextForSSLDialog.width, detailedTextForSSLDialog.width)
        contentHeight: mainTextForSSLDialog.height + detailedTextForSSLDialog.height
        property var certErrors: []
        // fixme: icon!
        // icon: StandardIcon.Warning
        standardButtons: Dialog.No | Dialog.Yes
        title: "Server's certificate not trusted"
        contentItem: Item {
            Label {
                id: mainTextForSSLDialog
                text: qsTr("Do you wish to continue?")
            }
            Text {
                id: detailedTextForSSLDialog
                anchors.top: mainTextForSSLDialog.bottom
                text: qsTr("If you wish so, you may continue with an unverified certificate.\n" +
                      "Accepting an unverified certificate means\n" +
                      "you may not be connected with the host you tried to connect to.\n" +
                      "Do you wish to override the security check and continue?")
            }
        }

        onAccepted: {
            certErrors.shift().acceptCertificate();
            presentError();
        }
        onRejected: reject()

        function reject(){
            certErrors.shift().rejectCertificate();
            presentError();
        }
        function enqueue(error){
            certErrors.push(error);
            presentError();
        }
        function presentError(){
            visible = certErrors.length > 0
        }
    }

    Dialog {
        id: featurePermissionDialog
        anchors.centerIn: parent
        width: Math.min(browserWindow.width, browserWindow.height) / 3 * 2
        contentWidth: mainTextForPermissionDialog.width
        contentHeight: mainTextForPermissionDialog.height
        standardButtons: Dialog.No | Dialog.Yes
        title: "Permission Request"

        property var feature;
        property url securityOrigin;

        contentItem: Item {
            Label {
                id: mainTextForPermissionDialog
                text: featurePermissionDialog.questionForFeature()
            }
        }

        onAccepted: currentWebView && currentWebView.grantFeaturePermission(securityOrigin, feature, true)
        onRejected: currentWebView && currentWebView.grantFeaturePermission(securityOrigin, feature, false)
        onVisibleChanged: {
            if (visible)
                width = contentWidth + 20;
        }

        function questionForFeature() {
            var question = "Allow " + securityOrigin + " to "

            switch (feature) {
            case WebEngineView.Geolocation:
                question += "access your location information?";
                break;
            case WebEngineView.MediaAudioCapture:
                question += "access your microphone?";
                break;
            case WebEngineView.MediaVideoCapture:
                question += "access your webcam?";
                break;
            case WebEngineView.MediaVideoCapture:
                question += "access your microphone and webcam?";
                break;
            case WebEngineView.MouseLock:
                question += "lock your mouse cursor?";
                break;
            case WebEngineView.DesktopVideoCapture:
                question += "capture video of your desktop?";
                break;
            case WebEngineView.DesktopAudioVideoCapture:
                question += "capture audio and video of your desktop?";
                break;
            case WebEngineView.Notifications:
                question += "show notification on your desktop?";
                break;
            default:
                question += "access unknown or unsupported feature [" + feature + "] ?";
                break;
            }

            return question;
        }
    }

    FullScreenNotification {
        id: fullScreenNotification
    }

    DownloadView {
        id: downloadView
        visible: false
        anchors.fill: parent
        //anchors.fill: tabLayout
    }

    function onDownloadRequested(download) {
        downloadView.visible = true;
        downloadView.append(download);
        download.accept();
    }

    BookmarkView {
        id: bookmarkView
        visible: false
        anchors.fill: parent
    }

    HistoryView {
        id: historyView
        visible: false
        anchors.fill: parent
    }

    SettingsView {
        id: settingsView
        visible: false
        anchors.fill: parent
    }

    AdvancedSettingsView {
        id: advancedSettingsView
        visible: false
        anchors.fill: parent
    }

    FindBar {
        id: findBar
        visible: false
        anchors.right: parent.right
        //anchors.rightMargin: 10
        anchors.top: navigationBar.bottom

        onFindNext: {
            if (text)
                currentWebView && currentWebView.findText(text);
            else if (!visible)
                visible = true;
        }

        onFindPrevious: {
            if (text)
                currentWebView && currentWebView.findText(text, WebEngineView.FindBackward);
            else if (!visible)
                visible = true;
        }

        onClear: currentWebView && currentWebView.findText("");
    }

    Rectangle {
        id: statusBubble
        color: "oldlace"
        property int padding: 8
        visible: false

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: statusText.paintedWidth + padding
        height: statusText.paintedHeight + padding

        Text {
            id: statusText
            anchors.centerIn: statusBubble
            elide: Qt.ElideMiddle

            Timer {
                id: hideStatusText
                interval: 750
                onTriggered: {
                    statusText.text = "";
                    statusBubble.visible = false;
                }
            }
        }
    }
}
