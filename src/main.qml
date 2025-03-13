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

Application {
    id: root
    anchors.fill: parent

    centerColor: "#119DA4"
    outerColor: "#090B0C"

    ListModel {
        id: shoppingModel
    }

    Component.onCompleted: {
        loadShoppingList()
    }

    function loadShoppingList() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file:///home/ceres/shopper.txt")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var items = xhr.responseText.split('\n').filter(item => item.trim() !== '')
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
        xhr.send()
    }

    function saveShoppingList() {
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "file:///home/ceres/shopper.txt")
        var data = ""
        for (var i = 0; i < shoppingModel.count; i++) {
            var item = shoppingModel.get(i)
            data += (item.checked ? "+" : "-") + item.name + "\n"
        }
        xhr.send(data)
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
        interval: 500  // Match the fade animation duration
        repeat: false
        onTriggered: sortList()
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.topMargin: 40
        model: shoppingModel
        clip: true

        delegate: Item {
            width: listView.width
            height: 72
            opacity: checked ? 0.6 : 1.0  // Fade to 0.6 when checked, 1.0 when unchecked

            Behavior on opacity {
                NumberAnimation {
                    duration: 500  // 500ms fade
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: checked ? "#808080" : "#00000000"
                opacity: checked ? 0.3 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                Rectangle {
                    id: clickFeedback
                    anchors.fill: parent
                    color: "#E09891"
                    opacity: 0.0
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 16

                Icon {
                    name: checked ?
                        "ios-checkmark-circle-outline" :
                        "ios-circle-outline"
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    Layout.leftMargin: 60
                }

                Label {
                    text: name
                    font.pixelSize: 28
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clickFeedbackAnimation.start()
                    shoppingModel.setProperty(index, "checked", !checked)
                    sortDelayTimer.start()
                }
            }

            SequentialAnimation {
                id: clickFeedbackAnimation
                NumberAnimation {
                    target: clickFeedback
                    property: "opacity"
                    from: 0.0
                    to: 0.5
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: clickFeedback
                    property: "opacity"
                    from: 0.5
                    to: 0.0
                    duration: 50
                    easing.type: Easing.InOutQuad
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
