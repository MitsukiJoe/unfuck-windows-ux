#Requires AutoHotkey v2.0
#NoTrayIcon
#Warn All, StdOut
#Include ..\lib\ToolSettings.ahk
#Include ..\lib\ToolStartup.ahk
#Include ..\lib\SettingsControls.ahk
#Include ..\lib\ToolSettingsWindow.ahk

RunLaunchTest() {
    settings := ToolSettings.Defaults()
    window := ToolSettingsWindow(settings, (*) => 0, (*) => 0)
    try {
        window.Show()
        if !DllCall("IsWindowVisible", "Ptr", window.Window.Hwnd)
            throw Error("Settings window did not open")
        Sleep(100)
        window.Window.GetClientPos(, , &width, &height)
        if width != window.Theme.Px(640)
            throw Error("Unexpected window width: " width)
        if WinGetStyle("ahk_id " window.Window.Hwnd) & 0x10000
            throw Error("Maximize must remain disabled")
        window.Window.Show("h" window.Theme.Px(332))
        Sleep(50)
        if window.ViewportHeight != window.Theme.Px(240)
            throw Error("Native resize did not update scroll viewport")
        window.WindowShortcut.Focus()
        if !window.WindowShortcut.Focused || window.ScrollPosition < window.Theme.Px(228)
            throw Error("Hotkey focus did not scroll into view")
        window.WindowShortcut.Value := ""
        window.Changed()
        if window.StatusKind != "warning"
            throw Error("Empty hotkey warning not shown")
        window.ImeExcludedProcesses.Focus()
        if window.WindowShortcut.Value != settings.WindowShortcut
            throw Error("Hotkey blur did not restore the previous shortcut")
        window.BracketsEnabled.Proxy.Focus()
        Sleep(50)
        if window.ScrollPosition
            throw Error("Keyboard focus did not scroll back to top")
        window.Hide()
        if DllCall("IsWindowVisible", "Ptr", window.Window.Hwnd)
            throw Error("Settings window did not hide")
        window.Show()
        if !DllCall("IsWindowVisible", "Ptr", window.Window.Hwnd)
            throw Error("Settings window did not reopen")
        FileAppend("PASS: first show, hidden centering, native resize, hotkey focus and blur, focus scrolling, hide and reopen`n", "*")
    } finally {
        window.Destroy()
    }
}

try {
    RunLaunchTest()
    ExitApp(0)
} catch as launchFailure {
    FileAppend("FAIL: " launchFailure.Message "`n" launchFailure.Stack "`n", "*")
    ExitApp(1)
}
