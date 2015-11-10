/***************************************************************************
+ Copyright (c) 2015 Hendrik Lehmbruch <hendrikL@siduction.org>
* Copyright (c) 2013 Reza Fatahilah Shah <rshah0385@kireihana.com>
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0
import "./components"

Rectangle {
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

        TextConstants { id: textConstants }

        Connections {
            target: sddm

            onLoginSucceeded: {
                errorMessage.color = "white"
                errorMessage.text = textConstants.loginSucceeded
            }

            onLoginFailed: {
                errorMessage.color = "white"
                errorMessage.text = textConstants.loginFailed
            }
        }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.PreserveAspectCrop
            
            KeyNavigation.backtab: user_entry; KeyNavigation.tab: user_entry
            
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }
    

/* *****************************************************
 * workaround for light backgrounds, 
 * deeepspace is especially made for dark backgrounds
 * ****************************************************/
/* start blue box */

//     Rectangle {
//         width: parent.width; height: 34
//         color: "#053343"
//         border.color: "white"
//         border.width: 0.5
//         //opacity: 0.8 
//         radius: 3
//         
//         anchors.top: parent.top
//         anchors.horizontalCenter: parent.horizontalCenter
//     }
//     
//     
//     
//     Rectangle {
//         width: 612; height: 240
//         color: "#053343"
//         border.color: "white"
//         border.width: 1
//         //opacity: 0.8 
//         radius: 13
// 
//         anchors.centerIn: parent
//     }

/* end blue box */
    
    
    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"
        
        Rectangle {

            width: 612; height: 120
            color: "#00000000"

            anchors.centerIn: parent
            
            /* Messages and warnings */
            Column {

                
                anchors.centerIn: parent
                
                /* Capslock warning */                
                Rectangle {
                        
                    anchors.centerIn: parent
                    anchors.fill: parent
                    anchors.top: parent.top
                    anchors.topMargin: -80
                        
                    Text {
                        id: txtCaps
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0
                        state: keyboard.capsLock ? "activated" : ""
                        text: textConstants.capslockWarning
                        color:"white"
                        font.pixelSize: 14
                                        
                    states: [
                            State {
                                name: "activated"
                                PropertyChanges { target:txtCaps; opacity: 1; }
                                }
                                            ,
                            State {
                                name: ""
                                PropertyChanges { target: txtCaps; opacity: 0; }
                                }
                            ]
                        }
                    }
                    
                /* Login faild message */    
                Rectangle {
                           
                    anchors.centerIn: parent
                    anchors.fill: parent
                    anchors.top: parent.top
                    anchors.topMargin: -117
                             
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 17
                        color:"white"
                        }
                    }
                }
            /* End Messages and warnings */
                
            Item {
                anchors.margins: 20
                anchors.fill: parent

                /* workaround to focus the user_entry, see below the TextBox user_entry */
            	property alias user: user_entry.text

            	/* workaround to focus pw_entry if needed */
                property alias password: pw_entry.text

                Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        height: 51                    
                        
                        Row {
                            id:labelRow

                            spacing: 12
                                            
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: 250; height: 21
                                color: "transparent" 
                            
                                Text {
                                    id:userName
                                    color:"white"
                                    text:textConstants.userName
                                    //font.bold: true
                                    font.pixelSize: 12
                                }
                            }
                            
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: 250; height: 21
                                color: "transparent"
                                
                                Text {
                                    id: userPassword
                                    color: "white"
                                    text: textConstants.password
                                    //font.bold: true
                                    font.pixelSize: 12
                                }
                            }    
                        }                    

                        Row {
                            id: userRow
                            anchors.right: parent.right

                            spacing: 12

                            TextBox {
                                id: user_entry
                                
                                focus: true

                                /*** hack found in plasma breeze sddm as workaround to focus input field ***/
                                /***************************************************************************** 
                                * focus works in qmlscene
                                * but this seems to be needed when loaded from SDDM
                                * I don't understand why, but we have seen this before in the old lock screen
                                ******************************************************************************/ 
                                
                                /* start hack */
                                Timer {
                                    interval: 200
                                    running: true
                                    repeat: false
                                    onTriggered: user_entry.forceActiveFocus()
                                }
                                /* end hack */
                                
                                width: 250; height: 30

                                /***********************************************************************
                                * If you want the last successfully logged in user to be displayed,
                                * uncomment the "text: userModel.lastUser" row below
                                * for more informations why it isn't possible to configure it via
                                * /etc/sddm.conf see https://bugzilla.redhat.com/show_bug.cgi?id=1238889
                                * so i wait, till this is fixed in debian sid.
                                * Dont forget to enable it in the /etc/sddm.conf
                                * "RememberLastUser=true",
                                * also take a look to the pw_entry section below!
                                ************************************************************************/
                               
                                //text: userModel.lastUser

                                font.pixelSize: 14
                                radius: 3

                                KeyNavigation.backtab: user_entry; KeyNavigation.tab: pw_entry
                            }

                            PwBox {
                                id: pw_entry
                                
                                    /***************************************************************
                                    * if you uncomment the "text: userModel.lastUser" row above,
                                    * uncomment the Timer section below too,
                                    * But also comment the Timer section above, so that the
                                    * password box is focused and not the user box.
                                    * **************************************************************/
                                    
                                    /* start hack */
                                    //Timer {
                                    //	interval: 200
                                    //	running: true
                                    //	repeat: false
                                    //	onTriggered: pw_entry.forceActiveFocus()
                                    //}
                                    /* end hack */
                                    
                                width: 250; height: 30

                                font.pixelSize: 14
                                radius: 3

                                KeyNavigation.backtab: user_entry; KeyNavigation.tab: login_button

                                Keys.onPressed: {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        sddm.login(user_entry.text, pw_entry.text, menu_session.index)
                                        event.accepted = true
                                    }
                                }
                            }
                            
                            ImageButton {
                                id: login_button
                                height: 32
                                source: "images/login_normal.png"                                                    
            
                                    onClicked: sddm.login(user_entry.text, pw_entry.text, menu_session.index)
            
                                    KeyNavigation.backtab: pw_entry; KeyNavigation.tab: session_button
                                }
                                
                            /* tooltips for the input fields */    
                                
                            //ToolTip { /* no translation or text avialable */
                            //    id: tooltip0
                            //    target: user_entry
                            //    text: textConstants.prompt
                            //    }
                                
                            //ToolTip { /* no translation or text avialable */
                            //    id: tooltip1
                            //    target: pw_entry
                            //    text: textConstants.prompt
                            //    }
                                
                            ToolTip {
                                id: tooltip2
                                target: login_button
                                text: textConstants.login
                                }
                            }
                        }

                    Item {
                        
                        width: 512; height: 36 
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.leftMargin:5
                        
                        /* tooltips buttonRow */
                        ToolTip {
                            id: tooltip3
                                target: session_button
                                text: textConstants.session
                                //font.bold: true
                                }
                                
                        ToolTip {
                            id: tooltip4
                                target: system_button
                                text: textConstants.shutdown
                                }
                                
                        ToolTip {
                            id: tooltip5
                                target: reboot_button
                                text: textConstants.reboot
                                }
                                
                        /* there is no translation in sddm for it */
                        ToolTip {
                            id: tooltip6
                                target: suspend_button
                                text: "Suspend" // textConstants.suspend
                                }
                                
                        /* there is no translation in sddm for it */        
                        ToolTip {
                            id: tooltip7
                                target: hibernate_button
                                text: "Hibernate" //textConstants.hibernate
                                }
                        
                    Row {
                        
                        spacing: 15
                            
                        Rectangle {
                            
                            width: 250; height: 32
                            color: "transparent"
                            anchors.topMargin:15
                            anchors.top: parent.top
                        
                        Row {
                            
                            id: buttonRow
                            height: 36
                            anchors.topMargin:10

                            spacing: 8
                                                    
                            ImageButton {
                                id: session_button
                                height: 32
                                source: "images/siductionlogin-white.png" //"images/session_normal.png"
                                onClicked: if (menu_session.state === "visible") menu_session.state = ""; else 
menu_session.state = "visible"

                                KeyNavigation.backtab: login_button; KeyNavigation.tab: system_button

                            }

                            ImageButton {
                                id: system_button
                                height: 32
                                source: "images/system_shutdown.png"
                                onClicked: sddm.powerOff()

                                KeyNavigation.backtab: session_button; KeyNavigation.tab: reboot_button
                            }

                            ImageButton {
                                id: reboot_button
                                height: 32
                                source: "images/system_reboot.png"
                                onClicked: sddm.reboot()

                                KeyNavigation.backtab: system_button; KeyNavigation.tab: suspend_button
                            }

                            ImageButton {
                                id: suspend_button
                                height: 32
                                source: "images/system_suspend.png"
                                visible: sddm.canSuspend
                                onClicked: sddm.suspend()

                                KeyNavigation.backtab: reboot_button; KeyNavigation.tab: hibernate_button
                            }

                            ImageButton {
                                id: hibernate_button
                                height: 32
                                source: "images/system_hibernate.png"
                                visible: sddm.canHibernate
                                onClicked: sddm.hibernate()

                                KeyNavigation.backtab: suspend_button; KeyNavigation.tab: user_entry
                            }
                        }
                        
                            SessionMenu {
                                
                                id: menu_session
                                width: 200; height: 0
                                anchors.top: buttonRow.bottom; anchors.left: buttonRow.left

                                model: sessionModel
                                index: sessionModel.lastIndex                    
                            }
                        }
                    }
                }
            }
        }
         
        Rectangle {
            id: infoHost
            anchors.left: parent.left; anchors.top: parent.top
            anchors.topMargin:10
                                
            Text {
                id:hostName
                anchors.left: parent.left
                anchors.leftMargin:20
                anchors.topMargin:15
                color:"white"
                    
                    
                /*******************************************************************
                * Now, only the hostName is displayed.
                * "Welcome to" is not displayed
                * i decided that it looks nicer like it is, without the "welcome to"
                * Feel free to change it 
                *******************************************************************/
                    
                text:sddm.hostName //textConstants.welcomeText.arg(sddm.hostName)                    
                //font.bold: true
                font.pixelSize: 12
            }
        } 
        
        
        Rectangle {
            id: infoDate
            anchors.right: parent.right; anchors.top: parent.top
            anchors.topMargin:10

            Text {
                id: time_label
                anchors.right: parent.right
                anchors.rightMargin:20
                    
                /*************************************
                * feel free to change the time format
                *************************************/
                    
                text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy HH:mm AP")
                    
                horizontalAlignment: Text.AlignRight
                color:"white"
                //font.bold: true
                font.pixelSize: 12
            }
        }

        Component.onCompleted: {
            if (user_entry.text === "")
                user_entry.focus = true
            else
                pw_entry.focus = true
        }
    }
}
                                                                                
