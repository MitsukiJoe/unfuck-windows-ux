#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib\BracketMapper.ahk
#Include lib\AppWindowSwitcher.ahk
#Include lib\ImeStateKeeper.ahk
#Include lib\AudioSynchronizer.ahk
#Include lib\ToolSettings.ahk
#Include lib\ToolStartup.ahk
#Include lib\SettingsControls.ahk
#Include lib\ToolSettingsWindow.ahk
#Include lib\ToolApplication.ahk

Persistent()
TraySetIcon(A_ScriptDir "\icons\app.ico")
app := ToolApplication()
if !ToolSettings.IndexOf(A_Args, "--startup")
    app.SettingsWindow.Show()
