import QtQuick 2.4
import QtQuick.Window 2.2
import QtWebEngine 1.4

Window {
    property alias currentWebView: webView
    flags: Qt.Dialog
    width: 800
    height: 600
    visible: true
    onClosing: destroy()
    WebEngineView {
        id: webView
        anchors.fill: parent
    }
}
