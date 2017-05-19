import QtQuick 2.7
import QtWebEngine 1.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

WebEngineView {
    id: webEngineView
    focus: true

    onLinkHovered: {
        if (hoveredUrl == "") {
            resetStatusText.start()
        } else {
            resetStatusText.stop()
            statusText.text = hoveredUrl
        }
    }

    states: [
        State {
            name: "FullScreen"
            PropertyChanges {
                target: tabs
                visible: false
            }
            PropertyChanges {
                target: navigationBar
                visible: false
            }
        }
    ]
    settings.autoLoadImages: appSettings.autoLoadImages
    settings.javascriptEnabled: appSettings.javaScriptEnabled
    settings.errorPageEnabled: appSettings.errorPageEnabled
    settings.pluginsEnabled: appSettings.pluginsEnabled
    settings.fullScreenSupportEnabled: appSettings.fullScreenSupportEnabled
    settings.autoLoadIconsForPage: appSettings.autoLoadIconsForPage
    settings.touchIconsEnabled: appSettings.touchIconsEnabled
    settings.accelerated2dCanvasEnabled: false

    onCertificateError: {
        error.defer()
        sslDialog.enqueue(error)
    }

    onNewViewRequested: {
        if (!request.userInitiated) {
            print("Warning: Blocked a popup window.")
        } else if (request.destination == WebEngineView.NewViewInTab) {
            var tab = createEmptyTab(currentWebView.profile)
            tabs.currentIndex = tabs.count - 1
            request.openIn(tab)
        } else if (request.destination == WebEngineView.NewViewInBackgroundTab) {
            var tab = createEmptyTab(currentWebView.profile)
            request.openIn(tab)
        } else if (request.destination == WebEngineView.NewViewInDialog) {
            var dialog = applicationRoot.createDialog(currentWebView.profile)
            request.openIn(dialog.currentWebView)
        } else {
            var window = applicationRoot.createWindow(currentWebView.profile)
            request.openIn(window.currentWebView)
        }
    }

    onFullScreenRequested: {
        if (request.toggleOn) {
            webEngineView.state = "FullScreen"
            browserWindow.previousVisibility = browserWindow.visibility
            browserWindow.showFullScreen()
            fullScreenNotification.show()
        } else {
            webEngineView.state = ""
            browserWindow.visibility = browserWindow.previousVisibility
            fullScreenNotification.hide()
        }
        request.accept()
    }

    onFeaturePermissionRequested: {
        console.warn("Feature requested:", securityOrigin, feature)
        if (feature == WebEngineView.Geolocation) {
            dlgLocationRequest.securityOrigin = securityOrigin;
            dlgLocationRequest.open();
        }
    }

    MessageDialog {
        id: dlgLocationRequest
        property url securityOrigin
        standardButtons: Dialog.Ok | Dialog.Cancel
        icon: StandardIcon.Question
        title: qsTr("Geolocation Request")
        text: qsTr("Website %1 is attempting to access your geolocation, allow it?").arg(securityOrigin)
        onAccepted: {
            grantFeaturePermission(securityOrigin, WebEngineView.Geolocation, true);
        }
        onRejected: {
            grantFeaturePermission(securityOrigin, WebEngineView.Geolocation, false);
        }
    }

    onRenderProcessTerminated: {
        var status = ""
        switch (terminationStatus) {
        case WebEngineView.NormalTerminationStatus:
            status = "(normal exit)"
            break;
        case WebEngineView.AbnormalTerminationStatus:
            status = "(abnormal exit)"
            break;
        case WebEngineView.CrashedTerminationStatus:
            status = "(crashed)"
            break;
        case WebEngineView.KilledTerminationStatus:
            status = "(killed)"
            break;
        }

        console.warn("Render process exited with code " + exitCode + " " + status)
        reloadTimer.start()
    }

    Timer {
        id: reloadTimer
        interval: 0
        running: false
        repeat: false
        onTriggered: currentWebView.reload()
    }
}
