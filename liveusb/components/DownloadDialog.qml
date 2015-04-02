import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

Dialog {
    id: root
    title: "Write " + liveUSBData.currentImage.name + " to USB"

    height: layout.height + 64 + (group.checked ? 48 : 0)
    standardButtons: StandardButton.NoButton

    width: 640

    contentItem: Rectangle {
        anchors.fill: parent
        color: palette.window
        Column {
            id: layout
            spacing: 24
            clip: true
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 48
                leftMargin: 64
                rightMargin: anchors.leftMargin
            }
            Text {
                wrapMode: Text.WordWrap
                //text: "Writing the image of " + liveUSBData.currentImage.name +" will delete everything that's currently on the drive."
                text: liveUSBData.currentImage.info
            }

            ColumnLayout {
                width: parent.width
                Behavior on y {
                    NumberAnimation {
                        duration: 1000
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    property double leftSize: liveUSBData.currentImage.download.maxProgress - liveUSBData.currentImage.download.progress
                    property string leftStr: leftSize <= 0 ? "" :
                                             (leftSize < 1024) ? (leftSize + " B") :
                                             (leftSize < (1024 * 1024)) ? ((leftSize / 1024).toFixed(1) + " KB") :
                                             (leftSize < (1024 * 1024 * 1024)) ? ((leftSize / 1024 / 1024).toFixed(1) + " MB") :
                                             ((leftSize / 1024 / 1024 / 1024).toFixed(1) + " GB")
                    text: liveUSBData.currentImage.status + (liveUSBData.currentImage.download.maxProgress > 0 ? " (" + leftStr + " left)" : "")
                }
                Item {
                    Layout.fillWidth: true
                    height: childrenRect.height
                    AdwaitaProgressBar {
                        width: parent.width
                        value: liveUSBData.currentImage.download.running ? liveUSBData.currentImage.download.progress / liveUSBData.currentImage.download.maxProgress : 0
                        visible: !liveUSBData.currentImage.writer.running
                    }
                    AdwaitaProgressBar {
                        width: parent.width
                        value: liveUSBData.currentImage.writer.running ? liveUSBData.currentImage.writer.progress / liveUSBData.currentImage.writer.maxProgress : 0
                        visible: !liveUSBData.currentImage.download.running
                        progressColor: liveUSBData.currentImage.writer.status == "Checking the source image" ? Qt.lighter("green") : "red"
                    }
                }
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 32
                IndicatedImage {
                    source: liveUSBData.currentImage.logo
                    sourceSize.width: 64
                    sourceSize.height: 64
                    fillMode: Image.PreserveAspectFit
                }
                Arrow {

                }
                AdwaitaComboBox {
                    Layout.preferredWidth: implicitWidth * 2.3
                    model: liveUSBData.usbDriveNames
                    currentIndex: liveUSBData.currentDrive
                    onCurrentIndexChanged: liveUSBData.currentDrive = currentIndex
                    enabled: !liveUSBData.currentImage.writer.running
                }
            }
            Item {
                width: group.width
                height: group.height + group.y
                GroupBox {
                    id: group
                    y: 8
                    title: "Show Advanced Options"
                    flat: true
                    checked: false
                    checkable: true
                    enabled: liveUSBData.options && liveUSBData.options[0]
                    ColumnLayout {
                        Repeater {
                            id: groupLayoutRepeater
                            model: group.checked ? liveUSBData.options : null
                            CheckBox {
                                checked: false
                                height: 20
                                width: 20
                                text: groupLayoutRepeater.model[index]
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: dialogButtonBar
            height: 32
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 24
                leftMargin: 16
                rightMargin: anchors.leftMargin
            }

            AdwaitaButton {
                id: cancelButton
                anchors {
                    right: acceptButton.left
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 6
                }
                width: implicitWidth * 1.2
                text: "Cancel"
                enabled: !liveUSBData.currentImage.writer.running
                onClicked: {
                    liveUSBData.currentImage.download.cancel()
                    liveUSBData.currentImage.writer.cancel()
                    root.close()
                }
            }
            AdwaitaButton {
                id: acceptButton
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "red"
                textColor: enabled ? "white" : palette.text
                width: implicitWidth * 1.2
                enabled: liveUSBData.currentImage.readyToWrite && !liveUSBData.currentImage.writer.running
                text: "Write to disk"
                onClicked: liveUSBData.currentImage.write()
            }
        }
    }
}
