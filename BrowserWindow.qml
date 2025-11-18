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

    //width: 800
    //height: 600
    //width: Screen.width
    //height: Screen.height
    width: Screen.width * 0.66
    height: Screen.height * 0.66
    visible: true
    title: currentWebView && currentWebView.title

    property QtObject applicationRoot
    property Item currentWebView: tabBar.currentIndex < tabBar.count ? tabLayout.children[tabBar.currentIndex] : null
    property int previousVisibility: Window.Windowed
    property bool portraitMode: (browserWindow.width < browserWindow.height)
    property string currentWebViewIcon: currentWebView.icon

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    onWidthChanged: {
        portraitMode = (browserWindow.width < browserWindow.height)
        //
        addressBar.visible = (portraitMode == true) ? false : true
        //
        if(portraitMode == true || tabBar.count === 1) {
            tabBar.visible = false
            tabBar.height = 0
            tabBar.spacing = 10
            tabBar.padding = 10
        }else{
            tabBar.visible = true
            tabBar.height = navigationBar.height
            navigationBar.visible = true
            tabLayout.visible = true
            tabBar.spacing = 1
            tabBar.padding = 1
        }
    }

    onCurrentWebViewChanged: {
        findBar.clear()
        findBar.reset();
    }

    Settings {
        id : appSettings
        category: profileName
        property alias javaScriptEnabled: advancedSettingsView.javaScriptEnabled
        property alias webRTCPublicInterfacesOnly: advancedSettingsView.webRTCPublicInterfacesOnly
        property alias readingFromCanvasEnabled: advancedSettingsView.readingFromCanvasEnabled
        property alias webGLEnabled: advancedSettingsView.webGLEnabled
        property string httpUserAgent
        property bool dbCreated: false
        property string homePage
        property string style
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
            width: portraitMode ?
                       (tabBar.width-(tabBar.width*0.08)) :
                           browserWindow.width/5 //? improve

            property int id
            property string tabTitle: "New Tab"
            property string tabUrl
            property string favicon: "image://favicon/" + tabUrl

            //https://doc.qt.io/qt-6/qtwebengine-features.html#favicon
            Image {
                id: faviconImage
                anchors.verticalCenter: parent.verticalCenter
                width: 22; height: 22
                sourceSize: Qt.size(width, height)
                anchors.margins: 10
                source: favicon
            }

            contentItem: Text {
                text: tabButton.tabTitle
                color: sysPalette.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                anchors.left: faviconImage.right
                anchors.right: closeTabbutton.left
            }

            ToolButton {
                id: closeTabbutton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                //anchors.verticalCenterOffset: (closeTabbutton.height > 28) ? 3 : 0
                anchors.rightMargin: 2
                icon.source: "qrc:/icons/window-close.svg"
                onClicked: tabButton.closeTab()
                z:1.1
                visible: (tabBar.count > 1) ? true : false
            }

            Rectangle {
                visible: portraitMode ? true : false
                width: parent.width
                height: 1
                color: sysPalette.mid
                anchors.bottom: parent.bottom
            }

            onClicked: {
                addressBar.text = tabLayout.itemAt(TabBar.index).url;
            }

            function closeTab() {
                tabBar.removeView(TabBar.index);
            }

            function setTab() {
                tabBar.currentIndex = TabBar.index //?
            }

            // ? qnd, fix styles
            Component.onCompleted: {
                if(appSettings.style == "Basic"){
                    tabButton.background.opacity = "0.1"
                }else if(appSettings.style == "Fusion"){
                    tabButton.implicitHeight = closeTabbutton.height + 2
                }else{
                    closeTabbutton.anchors.verticalCenterOffset = 3
                }
            }

            //https://doc.qt.io/qt-6/qml-qtquick-wheelevent.html
            MouseArea{
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    tabButton.setTab()
                    if(portraitMode){
                        tabBar.height = 0
                        tabBar.visible = false
                        navigationBar.visible = true
                        tabLayout.visible = true
                    }
                }

                onWheel: (wheel)=> {
                    if(!portraitMode){
                        if(wheel.angleDelta.y < 0){
                            //console.log("----- mouse wheel was rotated up/right")
                            if(tabBar.currentIndex < (tabBar.count - 1))
                                tabBar.currentIndex++;
                        }else{
                            //console.log("----- mouse wheel was rotated down/left")
                            if(tabBar.currentIndex > 0)
                                tabBar.currentIndex--;
                        }
                    }
                }
            }

        }
    }

    TabBar {
        id: tabBar

        spacing: 1

            //
            contentItem: ListView {
                id: tabBarListModel
                model: tabBar.contentModel
                currentIndex: tabBar.currentIndex

                spacing: tabBar.spacing
                orientation: portraitMode ? ListView.Vertical : ListView.Horizontal
                highlightMoveDuration: 100

                // ScrollBar.vertical: ScrollBar {
                //     id : tabBarscrollBar
                // }
            }

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        visible: portraitMode ? false : true

        Component.onCompleted: {
            dbInit()
            createTab(defaultProfile)
            currentWebView.profile.httpUserAgent = appSettings.httpUserAgent
        }

        currentIndex: tabLayout.currentIndex

        function createTab(profile, focusOnNewTab = true, url = undefined) {
            var webview = tabComponent.createObject(tabLayout, {profile: profile});
            var newTabButton =
                tabButtonComponent.createObject(tabBar, {
                    id: tabBar.count,
                    tabTitle: Qt.binding(
                        function () {
                            return webview.title;
                        }),
                    tabUrl: Qt.binding(
                        function () {
                            return webview.url;
                        })});

            tabBar.addItem(newTabButton);

            if (focusOnNewTab) {
                tabBar.setCurrentIndex(tabBar.count - 1);
            }

            if (url !== undefined) {
                webview.url = url;
            } else {
                    if(appSettings.homePage != "mostVisited"){
                        webview.url = appSettings.homePage;
                    }else{
                        if (focusOnNewTab) {
                            mostVisitedView.visible = true
                        }else{
                            mostVisitedView.visible = false
                        }
                    }
            }
            //
            if (tabBar.count === 1) {
                 tabBar.visible = false
                 tabBar.height = 0
            } else {
                if(portraitMode == false){
                 tabBar.visible = true
                 tabBar.height = navigationBar.height
                }
             }

            return webview;
        }

        function removeView(index) {
                tabBar.removeItem(tabBar.itemAt(index));
                tabLayout.children[index].destroy();
                tabBar.setCurrentIndex(currentIndex); //?
            if (tabBar.count === 1) {
                if(!portraitMode){
                    tabBar.visible = false
                    tabBar.height = 0
                }
            } else {
                if(!portraitMode){
                tabBar.visible = true
                }
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
                                JS.historyDbInsert(currentWebView.title,currentWebView.url,"") //
                            }
                        }
                    }
                    //console.log("--- currentWebView.icon --- : " + currentWebView.icon)
                }

                onFeaturePermissionRequested: function(securityOrigin, feature) {
                    featurePermissionDialog.securityOrigin = securityOrigin;
                    featurePermissionDialog.feature = feature;
                    featurePermissionDialog.visible = true;
                }

                settings.touchIconsEnabled: true

                Timer {
                    id: reloadTimer
                    interval: 0
                    running: false
                    repeat: false
                    onTriggered: currentWebView.reload()
                }

            }
        }
    }

    //
    ToolBar {
        id: navigationBar

        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 2 //fusion, breeze
        padding: 0 // kde/breeze style (do not remove)

        RowLayout {
            id: navigationBarRow
            anchors.fill: parent

            ToolButton {
                id: addressBarButton
                Layout.alignment: Qt.AlignLeft
                visible: (portraitMode == true) ? true : false
                icon.source: (addressBar.visible === true) ? "qrc:/icons/swap-panels.svg" : "qrc:/icons/map-globe.svg"
                onClicked: {
                        (addressBar.visible === true) ? (addressBar.visible = false) : (addressBar.visible = true)
                }
            }

            Item{
                width: 22; height: 22

                BusyIndicator {
                    visible: (currentWebView && currentWebView.loadProgress < 100) ? true : false
                    anchors.verticalCenter: parent.verticalCenter;
                    leftInset: 0
                    topInset: 0
                    rightInset: 0
                    bottomInset: 0
                    padding: 0
                    width: 22; height: 22
                }

                Image {
                    visible: (currentWebView && currentWebView.loadProgress < 100) ? false : true
                    anchors.verticalCenter: parent.verticalCenter;
                    id: faviconImage
                    width: 22; height: 22
                    sourceSize: Qt.size(width, height)
                    source: currentWebViewIcon ? currentWebView.icon : "qrc:/icons/page-simple.svg"
                }
            }

            Row{
                Layout.fillWidth: true
                //
                TextField {
                    id: addressBar
                    visible: (portraitMode == true) ? false : true

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

                    width: parent.width

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
                            addBookmarkButton.icon.source = "qrc:/icons/bookmarks-bookmarked.svg"
                            addBookmarkButton.enabled = false
                        }else {
                            addBookmarkButton.icon.source = "qrc:/icons/bookmarks.svg"
                            addBookmarkButton.enabled = true
                        }

                        if(addressBar.text === ""){
                            mostVisitedView.visible = true
                        }else{
                            mostVisitedView.visible = false
                        }
                    }
                }
            }

            Row{
                id: toolButtons
                visible: (portraitMode && addressBar.visible) ? false : true
                Layout.alignment: Qt.AlignRight

            ToolButton {
                id: backButton
                icon.source: "qrc:/icons/go-previous.svg" //use app icon file
                onClicked: currentWebView.goBack()
                enabled: currentWebView && currentWebView.canGoBack
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            ToolButton {
                id: forwardButton
                icon.source: "qrc:/icons/go-next.svg"
                onClicked: currentWebView.goForward()
                enabled: currentWebView && currentWebView.canGoForward
                activeFocusOnTab: !browserWindow.platformIsMac
            }

            ToolButton {
                id: addTabButton
                icon.source: "qrc:/icons/list-add.svg"
                onClicked: {
                    tabBar.createTab(tabBar.count !== 0 ? currentWebView.profile : defaultProfile);
                }
            }

            ToolButton {
                id: createdTabsButton
                text: tabBar.count
                implicitWidth: settingsMenuButton.width + 12
                implicitHeight: settingsMenuButton.height
                highlighted: true
                visible: portraitMode ? true : false
                onClicked: {
                    navigationBar.visible = false
                    tabLayout.visible = false // to block scroll
                    tabBar.height = browserWindow.height
                    tabBar.visible = true
                }
            }

            ToolButton {
                id: settingsMenuButton
                icon.source: "qrc:/icons/overflow-menu.svg"
                onClicked: settingsMenu.open()
                Menu {
                    id: settingsMenu
                    y: settingsMenuButton.height

                    MenuItem {
                        id: menuItemIcons
                        height: bookmark.height+1

                        Row{
                            spacing: 1

                            ToolButton {
                                id: addBookmarkButton
                                icon.source: "qrc:/icons/bookmarks.svg"
                                enabled: false
                                onClicked: {
                                    JS.bookmarkDbInsert(currentWebView.title,currentWebView.url,"")
                                    addBookmarkButton.enabled = false
                                    icon.source = "qrc:/icons/bookmarks-bookmarked.svg"
                                }
                            }

                            ToolButton {
                                id: reloadButton
                                icon.source: currentWebView && currentWebView.loading ? "qrc:/icons/dialog-cancel.svg" : "qrc:/icons/view-refresh.svg"
                                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                            }

                            ToolButton {
                                id: jsButton
                                text: appSettings.javaScriptEnabled ? "js" : "<s>js</s>"
                                implicitHeight: reloadButton.height //?
                                onClicked: {
                                    appSettings.javaScriptEnabled = appSettings.javaScriptEnabled ? false : true
                                }
                            }
                        }
                    }

                    MenuItem {
                        height: bookmark.height+1

                        Row{
                            spacing: 1

                            Label{
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Zoom ")
                                leftPadding: bookmark.leftPadding
                            }
                            ToolButton {
                                icon.source: "qrc:/icons/zoom-in.svg"
                                onClicked: currentWebView.zoomFactor += 0.1
                            }
                            ToolButton {
                                icon.source: "qrc:/icons/zoom-out.svg"
                                onClicked: currentWebView.zoomFactor -= 0.1
                            }
                        }
                    }

                    MenuItem {
                        text: qsTr("Find...")
                        onClicked: {
                            findBar.visible = true
                        }
                    }

                    MenuItem {
                        id: bookmark
                        text: qsTr("Bookmarks")
                        onClicked: {
                            bookmarkView.visible = !bookmarkView.visible;
                            tabLayout.visible = false // to block scroll
                        }
                    }

                    MenuItem {
                        id: history
                        text: qsTr("History")
                        onClicked: {
                            historyView.visible = !historyView.visible;
                            tabLayout.visible = false // to block scroll
                        }
                    }

                    MenuItem {
                        id: downloads
                        text: qsTr("Downloads")
                        onClicked: {
                            downloadView.visible = !downloadView.visible
                            tabLayout.visible = false // to block scroll
                        }
                    }

                    MenuItem {
                        id: menuItemSettings
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
    }
    //

    StackLayout {
        id: tabLayout
        currentIndex: tabBar.currentIndex
        anchors.top: findBar.visible ? findBar.bottom : navigationBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    FindBar {
        id: findBar
        visible: false
        anchors.right: parent.right
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

    Dialog {
        id: sslDialog
        anchors.centerIn: parent
        contentWidth: browserWindow.width - (browserWindow.width*0.1)
        contentHeight: mainTextForSSLDialog.height + detailedTextForSSLDialog.height
        property var certErrors: []
        standardButtons: Dialog.No | Dialog.Yes
        title: "Server's certificate not trusted"
        contentItem: Item {
            width: parent.width
            Label {
                id: mainTextForSSLDialog
                text: qsTr("Do you wish to continue?")
            }
            Text {
                id: detailedTextForSSLDialog
                anchors.top: mainTextForSSLDialog.bottom
                width: parent.width
                wrapMode: Text.WordWrap
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
        contentWidth: browserWindow.width - (browserWindow.width*0.1)
        contentHeight: mainTextForPermissionDialog.height
        standardButtons: Dialog.No | Dialog.Yes
        title: "Permission Request"

        property var feature;
        property url securityOrigin;

        contentItem: Item {
            width: parent.width
            Label {
                id: mainTextForPermissionDialog
                width: parent.width
                text: featurePermissionDialog.questionForFeature()
            }
        }

        onAccepted: currentWebView && currentWebView.grantFeaturePermission(securityOrigin, feature, true)
        onRejected: currentWebView && currentWebView.grantFeaturePermission(securityOrigin, feature, false)

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
    }

    function onDownloadRequested(download) {
        downloadView.visible = true;
        downloadView.append(download);
        download.accept();
    }

    MostVisitedView {
        id: mostVisitedView
        visible: false
        anchors.fill: tabLayout
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
