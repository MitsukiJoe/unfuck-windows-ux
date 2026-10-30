#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib\AppWindowSwitcher.ahk

TraySetIcon(A_ScriptDir "\icons\window.ico")
switcher := AppWindowSwitcher()
switcher.Configure(true)
