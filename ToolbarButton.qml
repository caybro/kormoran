import QtQuick 2.4
import QtQuick.Controls 2.0

ToolButton {
    id: control
    hoverEnabled: true
    padding: width * .25

    property alias iconSource: icon.source
    property string tooltip

    signal rightClicked(int modifiers)

    contentItem: Image {
        id: icon
        fillMode: Image.PreserveAspectFit
        width: control.availableWidth
        height: control.availableHeight
        sourceSize: Qt.size(width, height)
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.5

        ToolTip.visible: control.hovered && control.tooltip !== ""
        ToolTip.timeout: 1000
        ToolTip.text: control.tooltip
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.RightButton) {
                control.rightClicked(mouse.modifiers);
            }
        }
    }
}
