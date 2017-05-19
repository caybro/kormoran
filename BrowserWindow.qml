import QtQuick 2.7
import QtQml 2.2 // for Instantiator
import QtWebEngine 1.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

ApplicationWindow {
    id: browserWindow
    property QtObject applicationRoot
    property Item currentWebView: browserViewLayout.children[browserViewLayout.currentIndex]
    property int previousVisibility: Window.Windowed

    width: 1300
    height: 900
    visible: true
    title: currentWebView && currentWebView.title !== "" ? currentWebView.title : "Kormoran"

    // Make sure the Qt.WindowFullscreenButtonHint is set on OS X.
    Component.onCompleted: flags = flags | Qt.WindowFullscreenButtonHint

    // When using style "mac", ToolButtons are not supposed to accept focus.
    readonly property bool platformIsMac: Qt.platform === "osx"

    Settings {
        id: appSettings
        category: "Browser"
        property alias autoLoadImages: loadImages.checked;
        property alias javaScriptEnabled: javaScriptEnabled.checked;
        property alias errorPageEnabled: errorPageEnabled.checked;
        property alias pluginsEnabled: pluginsEnabled.checked;
        property alias fullScreenSupportEnabled: fullScreenSupportEnabled.checked;
        property alias autoLoadIconsForPage: autoLoadIconsForPage.checked;
        property alias touchIconsEnabled: touchIconsEnabled.checked;
    }

    Settings {
        category: "Window"
        property alias x: browserWindow.x
        property alias y: browserWindow.y
        property alias width: browserWindow.width
        property alias height: browserWindow.height
    }

    Shortcut {
        sequence: "Ctrl+J"
        onActivated: downloadView.visible = !downloadView.visible
    }
    Shortcut {
        sequence: "F6"
        onActivated: {
            addressBar.forceActiveFocus(Qt.ShortcutFocusReason);
            addressBar.selectAll();
        }
    }
    Shortcut {
        sequence: StandardKey.Refresh
        onActivated: {
            currentWebView.triggerWebAction(WebEngineView.Reload);
        }
    }
    Shortcut {
        sequence: "Ctrl+T" //StandardKey.AddTab
        onActivated: {
            createEmptyTab(currentWebView.profile);
            tabs.currentIndex = tabs.count - 1;
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }
    Shortcut {
        sequence: StandardKey.Close
        onActivated: currentWebView.triggerWebAction(WebEngineView.RequestClose);
    }
    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            if (currentWebView && currentWebView.loading) {
                currentWebView.stop();
            }

            if (currentWebView.state == "FullScreen") {
                browserWindow.visibility = browserWindow.previousVisibility
                fullScreenNotification.hide()
                currentWebView.triggerWebAction(WebEngineView.ExitFullScreen);
            }
        }
    }
    Shortcut {
        sequence: "Ctrl+0"
        onActivated: currentWebView.zoomFactor = 1.0;
    }
    Shortcut {
        sequence: StandardKey.ZoomOut
        onActivated: currentWebView.zoomFactor -= 0.1;
    }
    Shortcut {
        sequence: StandardKey.ZoomIn
        onActivated: currentWebView.zoomFactor += 0.1;
    }
    Shortcut {
        sequence: StandardKey.Copy
        onActivated: currentWebView.triggerWebAction(WebEngineView.Copy)
    }
    Shortcut {
        sequence: StandardKey.Cut
        onActivated: currentWebView.triggerWebAction(WebEngineView.Cut)
    }
    Shortcut {
        sequence: StandardKey.Paste
        onActivated: currentWebView.triggerWebAction(WebEngineView.Paste)
    }
    Shortcut {
        sequence: "Shift+"+StandardKey.Paste
        onActivated: currentWebView.triggerWebAction(WebEngineView.PasteAndMatchStyle)
    }
    Shortcut {
        sequence: StandardKey.SelectAll
        onActivated: currentWebView.triggerWebAction(WebEngineView.SelectAll)
    }
    Shortcut {
        sequence: StandardKey.Undo
        onActivated: currentWebView.triggerWebAction(WebEngineView.Undo)
    }
    Shortcut {
        sequence: StandardKey.Redo
        onActivated: currentWebView.triggerWebAction(WebEngineView.Redo)
    }
    Shortcut {
        sequence: StandardKey.Back
        onActivated: currentWebView.triggerWebAction(WebEngineView.Back)
    }
    Shortcut {
        sequence: StandardKey.Forward
        onActivated: currentWebView.triggerWebAction(WebEngineView.Forward)
    }
    Shortcut {
        sequence: "Ctrl+Tab" // StandardKey.NextChild
        onActivated: tabs.currentIndex = Math.min(tabs.currentIndex+1, tabs.count-1)
    }
    Shortcut {
        sequence: "Ctrl+Shift+Tab" // BUG this doesn't work: StandardKey.PreviousChild
        onActivated: tabs.currentIndex = Math.max(tabs.currentIndex-1, 0);
    }

    header: ToolBar {
        id: navigationBar
        RowLayout {
            width: parent.width
            ToolbarButton {
                id: backButton
                iconSource: "qrc:/icons/go-previous.png"
                tooltip: qsTr("Back")
                onClicked: currentWebView.goBack()
                enabled: currentWebView && currentWebView.canGoBack
                activeFocusOnTab: !browserWindow.platformIsMac
                onPressAndHold: backMenu.open()
                onRightClicked: backMenu.open()
                Menu {
                    id: backMenu
                    y: parent.y + parent.height

                    Instantiator {
                        model: currentWebView && currentWebView.navigationHistory.backItems
                        delegate: MenuItem {
                            text: model.title
                            onTriggered: currentWebView.goBackOrForward(model.offset)
                            checkable: !enabled
                            checked: !enabled
                            enabled: model.offset
                        }

                        onObjectAdded: backMenu.insertItem(index, object)
                        onObjectRemoved: backMenu.removeItem(index)
                    }
                }
            }
            ToolbarButton {
                id: forwardButton
                iconSource: "qrc:/icons/go-next.png"
                tooltip: qsTr("Forward")
                onClicked: currentWebView.goForward()
                enabled: currentWebView && currentWebView.canGoForward
                activeFocusOnTab: !browserWindow.platformIsMac
                onPressAndHold: forwardMenu.open()
                onRightClicked: forwardMenu.open()
                Menu {
                    id: forwardMenu
                    y: parent.y + parent.height

                    Instantiator {
                        model: currentWebView && currentWebView.navigationHistory.forwardItems
                        delegate: MenuItem {
                            text: model.title
                            onTriggered: currentWebView.goBackOrForward(model.offset)
                            checkable: !enabled
                            checked: !enabled
                            enabled: model.offset
                        }

                        onObjectAdded: forwardMenu.insertItem(index, object)
                        onObjectRemoved: forwardMenu.removeItem(index)
                    }
                }
            }
            ToolbarButton {
                id: reloadButton
                readonly property bool loading: currentWebView && currentWebView.loading
                iconSource: loading ? "qrc:/icons/process-stop.png" : "qrc:/icons/view-refresh.png"
                tooltip: loading ? qsTr("Stop") : qsTr("Refresh")
                onClicked: loading ? currentWebView.stop() : currentWebView.reload()
                activeFocusOnTab: !browserWindow.platformIsMac
            }
            AddressBar {
                id: addressBar
                Layout.fillWidth: true
                currentWebView: browserWindow.currentWebView
            }
            ToolbarButton {
                id: settingsMenuButton
                iconSource: "qrc:/icons/menu.png"
                tooltip: qsTr("Settings")
                onClicked: settingsMenu.open()
                hoverEnabled: true
                Menu {
                    id: settingsMenu
                    MenuItem {
                        id: loadImages
                        text: "Autoload images"
                        checkable: true
                        checked: WebEngine.settings.autoLoadImages
                    }
                    MenuItem {
                        id: javaScriptEnabled
                        text: "JavaScript On"
                        checkable: true
                        checked: WebEngine.settings.javascriptEnabled
                    }
                    MenuItem {
                        id: errorPageEnabled
                        text: "ErrorPage On"
                        checkable: true
                        checked: WebEngine.settings.errorPageEnabled
                    }
                    MenuItem {
                        id: pluginsEnabled
                        text: "Plugins On"
                        checkable: true
                        checked: true
                    }
                    MenuItem {
                        id: fullScreenSupportEnabled
                        text: "FullScreen Support"
                        checkable: true
                        checked: WebEngine.settings.fullScreenSupportEnabled
                    }
                    MenuItem {
                        id: offTheRecordEnabled
                        text: "Incognito"
                        checkable: true
                        checked: currentWebView.profile.offTheRecord
                        onCheckedChanged: currentWebView.profile = checked ? otrProfile : defaultProfile;
                    }
                    MenuItem {
                        id: httpDiskCacheEnabled
                        text: "HTTP Disk Cache"
                        checkable: !currentWebView.profile.offTheRecord
                        checked: (currentWebView.profile.httpCacheType == WebEngineProfile.DiskHttpCache)
                        onCheckedChanged: currentWebView.profile.httpCacheType = checked ? WebEngineProfile.DiskHttpCache : WebEngineProfile.MemoryHttpCache
                    }
                    MenuItem {
                        id: autoLoadIconsForPage
                        text: "Icons On"
                        checkable: true
                        checked: WebEngine.settings.autoLoadIconsForPage
                    }
                    MenuItem {
                        id: touchIconsEnabled
                        text: "Touch Icons On"
                        checkable: true
                        checked: WebEngine.settings.touchIconsEnabled
                        enabled: autoLoadIconsForPage.checked
                    }
                }
            }
        }
        ProgressBar {
            id: progressBar
            height: 3
            width: parent.width
            anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
                leftMargin: -parent.leftMargin
                rightMargin: -parent.rightMargin
            }
            z: -2;
            from: 0
            to: 100
            value: (currentWebView && currentWebView.loadProgress < 100) ? currentWebView.loadProgress : 0
        }
    }

    footer: TabBar {
        id: tabs
        currentIndex: 0
        visible: count > 1

        function createTab(browserView) {
            var component = Qt.createComponent("BrowserTab.qml");
            var tab = component.createObject(tabs, { "webview": browserView });
            tabs.addItem(tab);
        }
    }

    Component {
        id: browserTabComponent
        BrowserTabDelegate { }
    }

    function createEmptyTab(profile) {
        var browserView = browserTabComponent.createObject(browserViewLayout);

        if (browserView === null) {
            console.error("Error creating tab view delegate");
            return;
        }

        browserView.profile = profile;
        tabs.createTab(browserView);
        browserViewLayout.children[browserViewLayout.children.length] = browserView;
        return browserView;
    }

    StackLayout {
        id: browserViewLayout
        anchors.fill: parent
        currentIndex: tabs.currentIndex

        Component.onCompleted: createEmptyTab(defaultProfile)
    }

    MouseArea {
        anchors.fill: browserViewLayout
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        cursorShape: undefined
        onClicked: {
            if (!currentWebView || currentWebView.url == "")
                return;

            if (mouse.button === Qt.BackButton) {
                currentWebView.triggerWebAction(WebEngineView.Back)
            } else if (mouse.button === Qt.ForwardButton) {
                currentWebView.triggerWebAction(WebEngineView.Forward)
            }
        }
    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []
        icon: StandardIcon.Warning
        standardButtons: StandardButton.No | StandardButton.Yes
        title: qsTr("Server's certificate not trusted")
        text: qsTr("Do you wish to continue?")
        detailedText: qsTr("If you wish so, you may continue with an unverified certificate. " +
                           "Accepting an unverified certificate means " +
                           "you may not be connected with the host you tried to connect to.\n" +
                           "Do you wish to override the security check and continue?")
        onYes: {
            certErrors.shift().ignoreCertificateError()
            presentError()
        }
        onNo: reject()
        onRejected: reject()

        function reject() {
            certErrors.shift().rejectCertificate()
            presentError()
        }
        function enqueue(error) {
            certErrors.push(error)
            presentError()
        }
        function presentError() {
            visible = certErrors.length > 0
        }
    }

    FullScreenNotification {
        id: fullScreenNotification
        anchors.centerIn: parent
    }

    DownloadView {
        id: downloadView
        visible: false
        anchors.fill: parent
    }

    function onDownloadRequested(download) {
        downloadView.visible = true
        downloadView.append(download)
        download.accept()
    }

    Pane {
        id: statusBubble

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        padding: 5
        visible: statusText.text !== ""

        Text {
            id: statusText
            anchors.centerIn: parent
            elide: Qt.ElideMiddle

            Timer {
                id: resetStatusText
                interval: 750
                onTriggered: statusText.text = ""
            }
        }
    }
}
