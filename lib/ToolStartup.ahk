class ToolStartup {
    static LinkPath() {
        return A_Startup "\AutoHotkeyTools.lnk"
    }

    static IsEnabled() {
        if !FileExist(this.LinkPath())
            return false
        try {
            FileGetShortcut(this.LinkPath(), &target, , &arguments)
            return StrLower(target) = StrLower(A_AhkPath) && InStr(arguments, '"' A_ScriptFullPath '"')
        }
        return false
    }

    static IconPath() {
        return A_ScriptDir "\icons\app.ico"
    }

    static RefreshIcon() {
        if !this.IsEnabled()
            return
        try {
            FileGetShortcut(this.LinkPath(), , , , , &icon)
            if StrLower(icon) != StrLower(this.IconPath())
                this.Configure(true)
        }
    }

    static Configure(enabled) {
        if enabled {
            FileCreateShortcut(A_AhkPath, this.LinkPath(), A_ScriptDir, '"' A_ScriptFullPath '" --startup', "Windows 小工具", this.IconPath(), , , 7)
        } else if this.IsEnabled() {
            FileDelete(this.LinkPath())
        }
    }
}
