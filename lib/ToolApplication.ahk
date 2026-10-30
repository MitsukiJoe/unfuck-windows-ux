class ToolApplication {
    __New(configPath := "") {
        this.ConfigPath := configPath = "" ? ToolSettings.DefaultPath() : configPath
        this.Settings := ToolSettings.Load(this.ConfigPath)
        this.Brackets := BracketMapper()
        this.WindowSwitcher := AppWindowSwitcher()
        this.Ime := ImeStateKeeper()
        this.Audio := AudioSynchronizer()
        try {
            this.Apply(this.Settings)
        } catch {
            this.Settings.WindowShortcut := "!``"
            this.Apply(this.Settings)
        }
        this.SettingsWindow := ToolSettingsWindow(this.Settings, ObjBindMethod(this, "SaveSettings"), ObjBindMethod(this, "SetStartup"))
        this.ShowSettingsCallback := ObjBindMethod(this.SettingsWindow, "Show")
        A_TrayMenu.Delete()
        A_TrayMenu.Add("设置…", this.ShowSettingsCallback)
        A_TrayMenu.Default := "设置…"
        A_TrayMenu.Add("登录时自动运行", ObjBindMethod(this, "ToggleStartup"))
        A_TrayMenu.Add()
        A_TrayMenu.Add("退出", (*) => ExitApp())
        OnMessage(0x404, ObjBindMethod(this, "TrayClick"))
        OnExit(ObjBindMethod(this, "Stop"))
        ToolStartup.RefreshIcon()
        this.UpdateTray()
    }

    Apply(settings) {
        this.WindowSwitcher.Configure(settings.WindowSwitchEnabled, settings.WindowShortcut, settings.ExplorerFoldersOnly)
        this.Brackets.Configure(settings.BracketsEnabled, settings.BracketPair, settings.ChineseOnly)
        this.Ime.Configure(settings.ImeEnabled, settings.ImeExcludedProcesses)
        this.Audio.Configure(settings.AudioEnabled, settings.AudioIntervalMs)
    }

    SaveSettings(settings) {
        previous := this.Settings
        try {
            this.Apply(settings)
            ToolSettings.Save(settings, this.ConfigPath)
        } catch as err {
            this.Apply(previous)
            throw err
        }
        this.Settings := settings
        this.UpdateTray()
    }

    SetStartup(enabled) {
        ToolStartup.Configure(enabled)
        this.UpdateTray()
    }

    ToggleStartup(*) {
        this.SetStartup(!ToolStartup.IsEnabled())
        this.SettingsWindow.SyncStartup()
    }

    UpdateTray() {
        settings := this.Settings
        count := settings.BracketsEnabled + settings.WindowSwitchEnabled + settings.ImeEnabled + settings.AudioEnabled
        A_IconTip := "Windows 小工具 · " count "/4 已启用"
        if ToolStartup.IsEnabled()
            A_TrayMenu.Check("登录时自动运行")
        else
            A_TrayMenu.Uncheck("登录时自动运行")
    }

    TrayClick(wParam, lParam, *) {
        if (lParam = 0x202 || lParam = 0x203)
            SetTimer(this.ShowSettingsCallback, -1)
    }

    Stop(*) {
        this.Brackets.Configure(false)
        this.WindowSwitcher.Configure(false)
        this.Ime.Configure(false)
        this.Audio.Configure(false)
    }
}
