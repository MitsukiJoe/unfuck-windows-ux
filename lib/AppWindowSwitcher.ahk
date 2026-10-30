class AppWindowSwitcher {
    Enabled := false
    Shortcut := ""
    ExplorerFoldersOnly := true

    __New() {
        this.Callback := ObjBindMethod(this, "Switch")
    }

    Configure(enabled, shortcut := "!``", explorerFoldersOnly := true) {
        this.ExplorerFoldersOnly := explorerFoldersOnly
        if (this.Enabled = enabled && this.Shortcut = shortcut)
            return
        if (shortcut != this.Shortcut && enabled)
            Hotkey(shortcut, this.Callback, "On")
        if (this.Enabled && this.Shortcut != "" && (this.Shortcut != shortcut || !enabled))
            Hotkey(this.Shortcut, "Off")
        if (this.Shortcut = shortcut && enabled)
            Hotkey(shortcut, this.Callback, "On")
        this.Shortcut := shortcut
        this.Enabled := enabled
    }

    Switch(*) {
        if !this.Enabled
            return
        try {
            processName := WinGetProcessName("A")
            if (StrLower(processName) = "explorer.exe" && this.ExplorerFoldersOnly) {
                if WinGetClass("A") = "CabinetWClass"
                    WinActivateBottom("ahk_class CabinetWClass")
                return
            }
            WinActivateBottom("ahk_exe " processName)
        }
    }
}
