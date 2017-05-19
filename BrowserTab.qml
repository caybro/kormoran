import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtWebEngine 1.4

TabButton {
    id: control

    property var webview

    contentItem: RowLayout {
        Image {
            id: faviconImage
            width: height; height: control.availableHeight/2
            sourceSize: Qt.size(width, height)
            visible: source != "" && !busyIndicator.running
            source: webview && webview.icon
        }
        BusyIndicator {
            id: busyIndicator
            visible: running
            running: webview && webview.loading
        }
        Text {
            id: pageTitle
            Layout.fillWidth: true
            text: webview && webview.title ? webview.title : qsTr("Untitled")
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
        }
        ToolButton {
            text: "⊠"
            font.pixelSize: control.availableHeight/2
            onClicked: webview.triggerWebAction(WebEngineView.RequestClose)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: {
            webview.triggerWebAction(WebEngineView.RequestClose)
        }
    }
}
