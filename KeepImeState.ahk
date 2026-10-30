#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib\ImeStateKeeper.ahk

Persistent()
TraySetIcon(A_ScriptDir "\icons\keyboard.ico")
keeper := ImeStateKeeper()
keeper.Configure(true)
