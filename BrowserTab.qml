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
            width: height; height: control.availableHeight * .5
            sourceSize: Qt.size(width, height)
            visible: source != ""
            source: webview && webview.icon
        }
        Text {
            Layout.fillWidth: true
            text: webview && webview.title ? webview.title : qsTr("Untitled")
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
        }
        ToolButton {
            text: "⊠"
            font.pixelSize: control.availableHeight * .5
            onClicked: webview.triggerWebAction(WebEngineView.RequestClose)
        }
    }
}
