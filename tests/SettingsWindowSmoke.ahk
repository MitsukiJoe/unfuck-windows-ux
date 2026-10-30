class SettingsWindowFixture {
    Calls := 0
    Fail := false
    Last := 0

    Save(settings) {
        this.Calls += 1
        if this.Fail
            throw Error("测试写入失败")
        this.Last := settings.Clone()
    }

    Startup(enabled) {
        throw Error("测试启动项失败")
    }
}

RunSettingsWindowSmoke() {
    fixture := SettingsWindowFixture()
    defaults := ToolSettings.Defaults()
    window := ToolSettingsWindow(defaults, ObjBindMethod(fixture, "Save"), ObjBindMethod(fixture, "Startup"))
    try {
        initial := window.Read()
        for name, value in defaults.OwnProps()
            Assert(initial.%name% = value, "UI initial value mismatch: " name)
        Assert(window.StatusKind = "idle", "New UI must be idle")
        Assert(!DllCall("GetWindow", "Ptr", window.Background.Hwnd, "UInt", 2, "Ptr"), "Background must stay below interactive controls")
        for pair in ToolSettings.Pairs {
            sample := defaults.Clone()
            sample.BracketPair := pair
            window.Load(sample)
            Assert(window.Read().BracketPair = pair, "Display names must preserve raw bracket values")
        }
        window.Load(defaults)
        Assert(fixture.Calls = 0, "Loading settings must not trigger saves")
        window.BracketsEnabled.Toggle()
        Assert(fixture.Calls = 1 && !fixture.Last.BracketsEnabled, "Toggle must submit exactly once")
        Assert(!window.BracketPair.Enabled && !window.ChineseOnly.Enabled, "Disabled feature must disable children")
        saved := window.Read()
        fixture.Fail := true
        window.BracketPair.Choose(2)
        window.BracketsEnabled.Toggle()
        rolledBack := window.Read()
        for name, value in saved.OwnProps()
            Assert(rolledBack.%name% = value, "UI rollback mismatch: " name)
        Assert(window.StatusKind = "error", "UI must report save error")
        calls := fixture.Calls
        window.WindowShortcut.Value := ""
        window.Changed()
        Assert(fixture.Calls = calls && window.StatusKind = "warning", "Empty shortcut must not save")
        window.RestoreEmptyShortcut()
        Assert(window.WindowShortcut.Value = saved.WindowShortcut, "Empty shortcut must restore")
        fixture.Fail := false
        window.ImeExcludedProcesses.Value := "game.exe"
        window.QueueExcluded()
        Sleep(300)
        window.ImeExcludedProcesses.Value := "game.exe, example.exe"
        window.QueueExcluded()
        Sleep(300)
        Assert(fixture.Calls = calls, "Exclusions must debounce while typing")
        Sleep(300)
        Assert(fixture.Calls = calls + 1 && fixture.Last.ImeExcludedProcesses = "game.exe, example.exe", "Debounced change must save once")
        window.ImeExcludedProcesses.Value := "last.exe"
        window.QueueExcluded()
        window.Hide()
        Assert(fixture.Calls = calls + 2 && fixture.Last.ImeExcludedProcesses = "last.exe", "Hide must flush pending edits")
        startupState := ToolStartup.IsEnabled()
        window.StartupEnabled.Toggle()
        Assert(window.StatusKind = "error" && window.StartupEnabled.Value = startupState, "Startup failure must restore actual state")
        window.ResizeContent(window.Theme.Px(332))
        window.ScrollTo(window.Theme.Px(828))
        Assert(window.ScrollPosition = window.Theme.Px(828) - window.ViewportHeight, "Scrolling must clamp to content")
        window.ResizeContent(window.Theme.Px(920))
        Assert(window.ScrollPosition = 0, "Expanding window must reset unnecessary scrolling")
        for scale in [1, 1.25, 1.5, 2] {
            canvas := SettingsCanvas(SettingsTheme(scale))
            try {
                for state in [[false, false, true, false], [false, true, true, true], [true, false, true, false], [true, true, true, true], [false, false, false, false], [true, false, false, false]] {
                    bitmap := canvas.ToggleBitmap(state*)
                    info := Buffer(32, 0)
                    Assert(DllCall("GetObjectW", "Ptr", bitmap, "Int", info.Size, "Ptr", info), "Toggle bitmap must be valid")
                    Assert(NumGet(info, 4, "Int") = Round(48 * scale) && NumGet(info, 8, "Int") = Round(28 * scale), "Bitmap scale mismatch")
                }
            } finally {
                canvas.Dispose()
            }
        }
    } finally {
        window.Destroy()
    }
    Assert(window.Canvas.Disposed, "UI drawing resources must be released")
    process := DllCall("GetCurrentProcess", "Ptr")
    baselineGdi := DllCall("GetGuiResources", "Ptr", process, "UInt", 0, "UInt")
    Loop 3 {
        transient := ToolSettingsWindow(defaults, (*) => 0, (*) => 0)
        transient.Destroy()
    }
    finalGdi := DllCall("GetGuiResources", "Ptr", process, "UInt", 0, "UInt")
    Assert(finalGdi <= baselineGdi + 2, "Repeated UI creation must release GDI objects: " baselineGdi " -> " finalGdi)
}
