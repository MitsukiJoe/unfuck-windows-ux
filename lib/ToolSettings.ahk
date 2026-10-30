class ToolSettings {
    static Pairs := ["「」", "『』", "〖〗", "〔〕", "《》", "〈〉", "【】"]
    static AudioIntervals := [1000, 2000, 5000, 10000]

    static DefaultPath() {
        return A_AppData "\AutoHotkeyTools\settings.ini"
    }

    static Defaults() {
        return {
            BracketsEnabled: true, BracketPair: "「」", ChineseOnly: true,
            WindowSwitchEnabled: true, WindowShortcut: "!``", ExplorerFoldersOnly: true,
            ImeEnabled: true, ImeExcludedProcesses: "",
            AudioEnabled: true, AudioIntervalMs: 2000
        }
    }

    static Load(path) {
        data := this.Defaults()
        data.BracketsEnabled := this.ReadBool(path, "Brackets", "Enabled", true)
        pair := IniRead(path, "Brackets", "Pair", "「」")
        if this.IndexOf(this.Pairs, pair)
            data.BracketPair := pair
        data.ChineseOnly := this.ReadBool(path, "Brackets", "ChineseOnly", true)
        data.WindowSwitchEnabled := this.ReadBool(path, "WindowSwitch", "Enabled", true)
        data.WindowShortcut := IniRead(path, "WindowSwitch", "Shortcut", "!``")
        if data.WindowShortcut = ""
            data.WindowShortcut := "!``"
        data.ExplorerFoldersOnly := this.ReadBool(path, "WindowSwitch", "ExplorerFoldersOnly", true)
        data.ImeEnabled := this.ReadBool(path, "Ime", "Enabled", true)
        data.ImeExcludedProcesses := IniRead(path, "Ime", "ExcludedProcesses", "")
        data.AudioEnabled := this.ReadBool(path, "Audio", "Enabled", true)
        interval := IniRead(path, "Audio", "IntervalMs", "2000")
        if IsInteger(interval) && this.IndexOf(this.AudioIntervals, Integer(interval))
            data.AudioIntervalMs := Integer(interval)
        return data
    }

    static Save(data, path) {
        SplitPath(path, , &directory)
        DirCreate(directory)
        temporaryPath := path "." DllCall("GetCurrentProcessId", "UInt") ".tmp"
        try {
            IniWrite(data.BracketsEnabled ? 1 : 0, temporaryPath, "Brackets", "Enabled")
            IniWrite(data.BracketPair, temporaryPath, "Brackets", "Pair")
            IniWrite(data.ChineseOnly ? 1 : 0, temporaryPath, "Brackets", "ChineseOnly")
            IniWrite(data.WindowSwitchEnabled ? 1 : 0, temporaryPath, "WindowSwitch", "Enabled")
            IniWrite(data.WindowShortcut, temporaryPath, "WindowSwitch", "Shortcut")
            IniWrite(data.ExplorerFoldersOnly ? 1 : 0, temporaryPath, "WindowSwitch", "ExplorerFoldersOnly")
            IniWrite(data.ImeEnabled ? 1 : 0, temporaryPath, "Ime", "Enabled")
            IniWrite(data.ImeExcludedProcesses, temporaryPath, "Ime", "ExcludedProcesses")
            IniWrite(data.AudioEnabled ? 1 : 0, temporaryPath, "Audio", "Enabled")
            IniWrite(data.AudioIntervalMs, temporaryPath, "Audio", "IntervalMs")
            FileMove(temporaryPath, path, 1)
        } finally {
            if FileExist(temporaryPath)
                FileDelete(temporaryPath)
        }
    }

    static ReadBool(path, section, key, fallback) {
        value := IniRead(path, section, key, fallback ? "1" : "0")
        return value = "1" ? true : value = "0" ? false : fallback
    }

    static IndexOf(items, value) {
        for index, item in items {
            if item = value
                return index
        }
        return 0
    }
}
