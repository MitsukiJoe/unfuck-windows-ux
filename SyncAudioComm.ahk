#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib\AudioSynchronizer.ahk

Persistent()
TraySetIcon("mmsys.cpl", 1)
audio := AudioSynchronizer()
audio.Configure(true)
