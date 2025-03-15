/*
 * Copyright (C) 2025 - Timo Könnecke <github.com/eLtMosen>
 *
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.15
import org.asteroid.utils 1.0
import org.asteroid.controls 1.0
import org.asteroid.filehelper 1.0

Application {
    id: root
    anchors.fill: parent

    centerColor: "#119DA4"
    outerColor: "#090B0C"

    property string shopperFile: "/home/ceres/shopper.txt"

    ListModel {
        id: shoppingModel
    }

    Component.onCompleted: {
        loadShoppingList()
    }

    function loadShoppingList() {
        var fileContent = FileHelper.readFile(shopperFile)
        if (fileContent !== "") {
            var items = fileContent.split('\n').filter(item => item.trim() !== '')
            items.forEach(function(item) {
                var trimmed = item.trim()
                if (trimmed.length > 0) {
                    var isChecked = false
                    var name = trimmed
                    if (trimmed.charAt(0) === '+' || trimmed.charAt(0) === '-') {
                        isChecked = trimmed.charAt(0) === '+'
                        name = trimmed.substring(1).trim()
                    }
                    shoppingModel.append({name: name, checked: isChecked})
                }
            })
            sortList()
        }
    }

    function saveShoppingList() {
        var data = ""
        for (var i = 0; i < shoppingModel.count; i++) {
            var item = shoppingModel.get(i)
            data += (item.checked ? "+" : "-") + item.name + "\n"
        }
        FileHelper.writeFile(shopperFile, data)
    }

    function sortList() {
        var currentPosition = listView.contentY
        var atTop = listView.atYBeginning

        var items = []
        for (var i = 0; i < shoppingModel.count; i++) {
            var item = shoppingModel.get(i)
            items.push({name: item.name, checked: item.checked})
        }

        var unchecked = items.filter(item => !item.checked)
        var checked = items.filter(item => item.checked)

        unchecked.sort((a, b) => a.name.localeCompare(b.name))
        checked.sort((a, b) => a.name.localeCompare(b.name))

        var newIndex = 0
        unchecked.forEach(item => {
            shoppingModel.set(newIndex++, {name: item.name, checked: item.checked})
        })
        checked.forEach(item => {
            shoppingModel.set(newIndex++, {name: item.name, checked: item.checked})
        })

        saveShoppingList()

        if (!atTop) {
            listView.contentY = currentPosition
        }
    }

    function uncheckAll() {
        for (var i = 0; i < shoppingModel.count; i++) {
            shoppingModel.setProperty(i, "checked", false)
        }
        sortList()
    }

    Timer {
        id: sortDelayTimer
        interval: 500
        repeat: false
        onTriggered: sortList()
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.topMargin: DeviceInfo.hasRoundScreen ? 30 : 10
        model: shoppingModel
        clip: true

        delegate: Item {
            width: listView.width
            height: 64
            opacity: checked ? 0.7 : 1.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: checked ? "#222222" : "#00000000"
                opacity: checked ? 0.4 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 12

                Icon {
                    id: checkIcon
                    name: checked ? "ios-checkmark-circle-outline" : "ios-circle-outline"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.leftMargin: DeviceInfo.hasRoundScreen ? 60 : 10

                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                    scale: checked ? 1.0 : 0.8  // Scale up slightly when checked
                }

                Label {
                    text: name
                    font.pixelSize: 28
                    font.strikeout: checked
                    color: checked ? "#ACF39D" : "#ffffff"  // Green for checked, white for unchecked
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    shoppingModel.setProperty(index, "checked", !checked)
                    sortDelayTimer.start()
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Dims.l(1)
                color: "#20ffffff"
            }
        }

        footer: Item {
            width: listView.width
            height: 72

            Rectangle {
                anchors.fill: parent
                color: "#20ffffff"
            }

            Text {
                anchors.centerIn: parent
                text: "Uncheck All"
                font.pixelSize: 28
                color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: uncheckAll()
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Dims.l(1)
                color: "#20ffffff"
            }
        }
    }
}
