#Requires AutoHotkey v2.0
#NoTrayIcon
#Warn All, StdOut
#Include ..\lib\BracketMapper.ahk
#Include ..\lib\AppWindowSwitcher.ahk
#Include ..\lib\ImeStateKeeper.ahk
#Include ..\lib\AudioSynchronizer.ahk
#Include ..\lib\ToolSettings.ahk
#Include ..\lib\ToolStartup.ahk
#Include ..\lib\SettingsControls.ahk
#Include ..\lib\ToolSettingsWindow.ahk
#Include ..\lib\ToolApplication.ahk
#Include SettingsWindowSmoke.ahk

Assert(condition, message) {
    if !condition
        throw Error(message)
}

class ImeTimerProbe extends ImeStateKeeper {
    Calls := 0
    EnsureChineseMode() {
        this.Calls += 1
    }
}

class AudioTimerProbe extends AudioSynchronizer {
    Calls := 0
    SyncAudioDevices() {
        this.Calls += 1
    }
}

RunSmoke() {
try {
    path := A_Temp "\AutoHotkeyTools-test-" DllCall("GetCurrentProcessId", "UInt") ".ini"
    defaults := ToolSettings.Load(path)
    Assert(defaults.BracketPair = "「」" && defaults.BracketsEnabled, "Missing settings must preserve defaults")
    for pair in ToolSettings.Pairs {
        settings := ToolSettings.Defaults()
        settings.BracketPair := pair
        settings.ChineseOnly := false
        settings.BracketsEnabled := false
        settings.WindowShortcut := "^!q"
        settings.ExplorerFoldersOnly := false
        settings.WindowSwitchEnabled := false
        settings.ImeEnabled := false
        settings.ImeExcludedProcesses := "game.exe, example.exe"
        settings.AudioEnabled := false
        settings.AudioIntervalMs := 5000
        ToolSettings.Save(settings, path)
        loaded := ToolSettings.Load(path)
        for name, value in settings.OwnProps()
            Assert(loaded.%name% = value, "Settings round trip failed: " name " / " pair)
    }
    IniWrite("invalid", path, "Brackets", "Pair")
    IniWrite("not a number", path, "Audio", "IntervalMs")
    IniWrite("invalid", path, "Ime", "Enabled")
    loaded := ToolSettings.Load(path)
    Assert(loaded.BracketPair = "「」", "Invalid pair must fall back")
    Assert(loaded.AudioIntervalMs = 2000 && loaded.ImeEnabled, "Invalid values must fall back")
    FileDelete(path)

    ime := ImeTimerProbe()
    audio := AudioTimerProbe()
    ime.Configure(true, "", 50)
    audio.Configure(true, 50)
    Sleep(180)
    Assert(ime.Calls >= 2 && audio.Calls >= 2, "Enabled timers must run")
    ime.Configure(false)
    audio.Configure(false)
    imeCalls := ime.Calls
    audioCalls := audio.Calls
    Sleep(180)
    Assert(ime.Calls = imeCalls && audio.Calls = audioCalls, "Disabled timers must stop")
    Assert(!ime.ApplyChineseFix(0), "Queued IME retry must not run while disabled")

    mapper := BracketMapper()
    mapper.Configure(true, "『』", false)
    Assert(mapper.IsActive(), "Global bracket mapping must be active")
    mapper.Configure(false)
    Assert(!mapper.IsActive(), "Disabled bracket mapping must pass through")

    switcher := AppWindowSwitcher()
    switcher.Configure(true, "^!q")
    switcher.Configure(true, "^!w")
    switcher.Configure(false)
    switcher.Configure(false, "^!e")
    switcher.Configure(true, "^!e")
    switcher.Configure(false)
    Assert(!switcher.Enabled, "Window switcher must disable")

    keeper := ImeStateKeeper()
    Assert(keeper.ShouldSkipState({processName: "AutoHotkey64.exe"}), "Settings window must be excluded from IME lock")
    keeper.Configure(false, "game.exe, EXAMPLE.EXE")
    Assert(keeper.ShouldSkipState({processName: "example.exe"}), "IME process exclusions must ignore case")
    Assert(!keeper.ShouldSkipState({processName: "editor.exe"}), "Other applications must remain eligible")
    audioDevice := AudioSynchronizer().GetDefaultAudioEndpointId(0, 0)
    Assert(Type(audioDevice) = "String", "Audio endpoint lookup must return a string")
    RunSettingsWindowSmoke()
    FileAppend("PASS: settings, timers, hotkeys, IME, audio, UI toggles, rollback, debounce, scrolling, drawing scales and cleanup`n", "*")
    ExitApp(0)
} catch as err {
    FileAppend("FAIL: " err.Message "`n" err.Stack "`n", "*")
    ExitApp(1)
}
}

RunSmoke()
