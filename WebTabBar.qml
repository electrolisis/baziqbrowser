import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

TabBar {
    id: tabBar
    anchors.top: parent.top
    //anchors.left: parent.left
    //anchors.right: parent.right
    //anchors.fill: parent

    //visible: false

    Component.onCompleted: createTab(defaultProfile)

    background: Rectangle {
        color: "Transparent"
    }

    function createTab(profile, focusOnNewTab = true, url = undefined) {
        var webview = tabComponent.createObject(tabLayout, {profile: profile});
        //var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle: Qt.binding(function () { return webview.title; })});
        var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle: Qt.binding(function () { return webview.lifecycleState; })});
        tabBar.addItem(newTabButton);
        if (focusOnNewTab) {
            tabBar.setCurrentIndex(tabBar.count - 1);
        }
        if (url !== undefined) {
            webview.url = url;
        }
        return webview;
    }

    function removeView(index) {
        if (tabBar.count > 1) {
            tabBar.removeItem(tabBar.itemAt(index));
            tabLayout.children[index].destroy();
        } else {
            browserWindow.close();
        }
    }

    Component {
        id: tabComponent
        WebEngineView {
            id: webEngineView
            focus: true

            onLinkHovered: function(hoveredUrl) {
                if (hoveredUrl == "")
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
                    }
                }
                // State {
                //     name: "Active"
                //     PropertyChanges {
                //         target:
                //         tabTitle: "(A)"
                //     }
                // }
            ]
            //settings.localContentCanAccessRemoteUrls: true
            //settings.localContentCanAccessFileUrls: false
            //settings.autoLoadImages: appSettings.autoLoadImages
            settings.javascriptEnabled: appSettings.javaScriptEnabled
            //settings.errorPageEnabled: appSettings.errorPageEnabled
            // settings.pluginsEnabled: appSettings.pluginsEnabled
            // settings.fullScreenSupportEnabled: appSettings.fullScreenSupportEnabled
            // settings.autoLoadIconsForPage: appSettings.autoLoadIconsForPage
            // settings.touchIconsEnabled: appSettings.touchIconsEnabled
            // settings.webRTCPublicInterfacesOnly: appSettings.webRTCPublicInterfacesOnly
            // settings.pdfViewerEnabled: appSettings.pdfViewerEnabled

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
                if (loadRequest.status == WebEngineView.LoadStartedStatus)
                    findBar.reset();
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
                //interval: 2000
                interval: {
                    switch (webEngineView.recommendedState) {
                    case WebEngineView.LifecycleState.Active:
                        //console.log("log -> " + "tab active")
                        //webEngineView.state = "Active";
                        return 1
                    case WebEngineView.LifecycleState.Frozen:
                        //console.log("log -> " + "tab frozen")
                        //return root.freezeDelay * 1000
                        return 10 * 1000
                    case WebEngineView.LifecycleState.Discarded:
                        //console.log("log -> " + "tab discarded")
                        //return root.discardDelay * 1000
                        return 60 * 60 * 1000
                    }
                }
                running: interval && webEngineView.lifecycleState !== webEngineView.recommendedState
                //running: true
                //repeat: true
                onTriggered: {
                    webEngineView.lifecycleState = webEngineView.recommendedState
                    //console.log("log -> " + "onTriggered " + "?" + " " + webEngineView.lifecycleState)
                    //tabButton.tabTitle = webEngineView.lifecycleState
                    //webEngineView.state = "Active";
                    console.log("log -> " + interval)
                }
            }
        }
    }
}
