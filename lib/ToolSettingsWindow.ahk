class ToolSettingsWindow {
    static Width := 640
    static HeaderHeight := 92
    static ContentHeight := 828
    static MinHeight := 332
    static MaxHeight := 920

    __New(settings, onChange, onStartupChange) {
        this.OnChange := onChange
        this.OnStartupChange := onStartupChange
        this.Theme := SettingsTheme()
        this.Canvas := SettingsCanvas(this.Theme)
        this.Toggles := []
        this.ToggleHandles := Map()
        this.SubTextGroups := Map()
        this.Handlers := Map()
        this.KeyboardFocusVisible := false
        this.Loading := true
        this.Destroyed := false
        this.HasBeenShown := false
        this.ScrollPosition := 0
        this.ViewportHeight := this.Theme.Px(ToolSettingsWindow.ContentHeight)
        this.WheelRemainder := 0
        this.ExclusionPending := false
        this.HoveredToggle := 0
        this.HotkeySubclassCallback := 0
        this._StatusKind := "idle"
        this.SaveExcludedTimer := ObjBindMethod(this, "FlushExcluded")
        this.HoverTimer := ObjBindMethod(this, "CheckHover")
        this.Window := Gui("+Resize -MaximizeBox -DPIScale", "Windows 小工具")
        this.Window.BackColor := SettingsTheme.Background
        this.Window.SetFont("s10 c" SettingsTheme.Text, this.Theme.Font)
        this.Window.Opt("+MinSize" this.Theme.Px(640) "x" this.Theme.Px(332) " +MaxSize" this.Theme.Px(640) "x" this.Theme.Px(920))
        this.Title := this.Window.AddText(this.Rect(24, 24, 592, 32) " Background" SettingsTheme.Background, "Windows 小工具")
        this.Title.SetFont("s18 Bold")
        this.StatusIcon := this.Window.AddText(this.Rect(24, 61, 16, 18) " +0x200 Background" SettingsTheme.Background, "")
        this.StatusIcon.SetFont("s10", this.Theme.IconFont)
        this.Status := this.Window.AddText(this.Rect(24, 60, 592, 20) " +0x4200 Background" SettingsTheme.Background, "")
        this.Status.SetFont("s9 c" SettingsTheme.Secondary)

        this.Viewport := Gui("-Caption +Parent" this.Window.Hwnd " -DPIScale +0x2200000 +E0x10000")
        this.Viewport.BackColor := SettingsTheme.Background
        this.Content := Gui("-Caption +Parent" this.Viewport.Hwnd " -DPIScale +0x2000000 +E0x10000")
        this.Content.BackColor := SettingsTheme.Background
        this.Content.SetFont("s10 c" SettingsTheme.Text, this.Theme.Font)
        this.Background := this.Content.AddPicture(this.Rect(0, 0, 640, 828) " +0x4000000", "HBITMAP:*" this.Canvas.DrawBackground())
        changed := ObjBindMethod(this, "Changed")

        this.CardTitle(4, "中文标点", 0xE765)
        this.BracketsEnabled := SettingsToggle(this, "中文标点", 4, 68, changed)
        this.CardDescription(4, "用 Shift + [ 和 Shift + ] 输入中文引号或括号")
        this.SubTextGroups["Brackets"] := []
        this.RowText(73, "符号样式", "Shift + [ 输入左侧，Shift + ] 输入右侧", 296, "Brackets")
        this.BracketPair := this.AddInput("DropDownList", 376, 200, 73, ["「 」 直角引号", "『 』 双直角引号", "〖 〗 空心方头括号", "〔 〕 六角括号", "《 》 书名号", "〈 〉 单书名号", "【 】 方头括号"])
        this.RowTitle(134, "仅在简体中文键盘布局下生效", 424, "Brackets")
        this.ChineseOnly := SettingsToggle(this, "仅在简体中文键盘布局下生效", 134, 60, changed)
        this.RowDescription(134, "切换到英语键盘布局时，仍输入 { 和 }", 424, "Brackets")

        this.CardTitle(198, "保持拼音中文模式", 0xE8C1)
        this.ImeEnabled := SettingsToggle(this, "保持拼音中文模式", 198, 68, changed)
        this.CardDescription(198, "简体中文键盘布局下，微软拼音自动回到中文输入模式")
        this.SubTextGroups["Ime"] := []
        this.RowText(267, "排除的应用", "填写进程名，以逗号分隔", 236, "Ime")
        this.ImeExcludedProcesses := this.AddInput("Edit", 316, 260, 267)
        DllCall("SendMessageW", "Ptr", this.ImeExcludedProcesses.Hwnd, "UInt", 0x1501, "Ptr", 1, "Str", "例如 game.exe, example.exe", "Ptr")

        this.CardTitle(331, "同应用窗口切换", 0xE7C4)
        this.WindowSwitchEnabled := SettingsToggle(this, "同应用窗口切换", 331, 68, changed)
        this.CardDescription(331, "按快捷键在同一应用的多个窗口之间循环切换")
        this.SubTextGroups["Window"] := []
        this.RowText(400, "快捷键", "选中输入框后按下新的组合键", 336, "Window")
        this.WindowShortcut := this.AddInput("Hotkey", 416, 160, 400)
        this.RowTitle(461, "资源管理器仅切换文件夹窗口", 424, "Window")
        this.ExplorerFoldersOnly := SettingsToggle(this, "资源管理器仅切换文件夹窗口", 461, 60, changed)
        this.RowDescription(461, "跳过桌面和任务栏", 424, "Window")

        this.CardTitle(525, "通信音频跟随", 0xE95B)
        this.AudioEnabled := SettingsToggle(this, "通信音频跟随", 525, 68, changed)
        this.CardDescription(525, "让默认通信设备始终与默认播放设备一致")
        this.SubTextGroups["Audio"] := []
        this.RowText(594, "检查间隔", "切换播放设备后，最多在此时间内同步", 376, "Audio")
        this.AudioInterval := this.AddInput("DropDownList", 456, 120, 594, ["1 秒", "2 秒", "5 秒", "10 秒"])

        general := this.Content.AddText(this.Rect(24, 678, 592, 20) " Background" SettingsTheme.Background, "常规")
        general.SetFont("s10 Bold")
        this.CardTitle(706, "登录 Windows 时自动运行", 0xE7E8)
        this.StartupEnabled := SettingsToggle(this, "登录 Windows 时自动运行", 706, 68, ObjBindMethod(this, "StartupChanged"))
        this.CardDescription(706, "在后台启动，不打开此窗口")
        footer := this.Content.AddText(this.Rect(24, 786, 592, 18) " +0x200 Background" SettingsTheme.Background, "关闭窗口后功能仍在后台运行。如需退出，请右键单击通知区域图标并选择“退出”。")
        footer.SetFont("s9 c" SettingsTheme.Secondary)
        DllCall("SetWindowPos", "Ptr", this.Background.Hwnd, "Ptr", 1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)

        for control in [this.BracketPair, this.WindowShortcut, this.AudioInterval]
            control.OnEvent("Change", changed)
        this.ImeExcludedProcesses.OnEvent("Change", ObjBindMethod(this, "QueueExcluded"))
        this.ImeExcludedProcesses.OnEvent("LoseFocus", ObjBindMethod(this, "FlushExcluded"))
        this.Window.OnEvent("Close", ObjBindMethod(this, "Hide"))
        this.Window.OnEvent("Escape", ObjBindMethod(this, "Hide"))
        this.Content.OnEvent("Escape", ObjBindMethod(this, "Hide"))
        this.Viewport.OnEvent("Escape", ObjBindMethod(this, "Hide"))
        this.Window.OnEvent("Size", ObjBindMethod(this, "Sized"))
        for message, method in Map(0x200, "MouseMoved", 0x201, "MouseDown", 0x100, "KeyDown", 0x115, "VerticalScroll", 0x20A, "MouseWheel") {
            handler := ObjBindMethod(this, method)
            this.Handlers[message] := handler
            OnMessage(message, handler)
        }
        this.ExitHandler := ObjBindMethod(this, "Destroy")
        OnExit(this.ExitHandler)
        this.Saved := settings.Clone()
        this.Load(settings)
        this.SetStatus("idle")
        this.CaptionTheme()
        this.ResizeContent(this.Theme.Px(920))
    }

    Rect(x, y, width, height) {
        theme := this.Theme
        return "x" theme.Px(x) " y" theme.Px(y) " w" theme.Px(width) " h" theme.Px(height)
    }

    CardTitle(top, title, icon) {
        control := this.Content.AddText(this.Rect(38, top + 22, 24, 24) " +Center +0x200 Background" SettingsTheme.Card, Chr(icon))
        control.SetFont("s15", this.Theme.IconFont)
        this.CardText(title, 80, top + 15, 424, 20)
    }

    CardDescription(top, description) {
        this.CardText(description, 80, top + 35, 424, 18, true)
    }

    CardText(text, x, y, width, height, secondary := false, group := "") {
        control := this.Content.AddText(this.Rect(x, y, width, height) " +0x200 Background" SettingsTheme.Card, text)
        control.SetFont("s" (secondary ? 9 : 10) " c" (secondary ? SettingsTheme.Secondary : SettingsTheme.Text))
        if group != ""
            this.SubTextGroups[group].Push({Control: control, Secondary: secondary})
        return control
    }

    RowTitle(top, text, width, group) {
        this.CardText(text, 80, top + 11, width, 20, false, group)
    }

    RowDescription(top, text, width, group) {
        this.CardText(text, 80, top + 31, width, 18, true, group)
    }

    RowText(top, title, description, width, group) {
        this.RowDescription(top, description, width, group)
        this.RowTitle(top, title, width, group)
    }

    AddInput(type, x, width, top, items := "") {
        options := "x" this.Theme.Px(24 + x) " y" this.Theme.Px(top) " w" this.Theme.Px(width)
        control := type = "DropDownList" ? this.Content.AddDropDownList(options " r7 Choose1", items) : this.Content.Add(type, options)
        control.GetPos(, , , &height)
        control.Move(, this.Theme.Px(top) + Round((this.Theme.Px(60) - height) / 2))
        this.RegisterFocus(control, top, 60)
        return control
    }

    RegisterFocus(control, top, height) {
        if control.Type = "Hotkey" {
            this.HotkeyControl := control
            this.HotkeyRowTop := top
            this.HotkeyRowHeight := height
            this.HotkeySubclassCallback := CallbackCreate(ObjBindMethod(this, "HotkeySubclass"), , 6)
            if !DllCall("comctl32\SetWindowSubclass", "Ptr", control.Hwnd, "Ptr", this.HotkeySubclassCallback, "UPtr", 1, "UPtr", 0, "Int")
                throw OSError()
        } else {
            control.OnEvent("Focus", ObjBindMethod(this, "FocusControl", top, height))
        }
    }

    HotkeySubclass(hwnd, message, wParam, lParam, id, data) {
        if !this.Destroyed {
            if message = 7
                this.FocusControl(this.HotkeyRowTop, this.HotkeyRowHeight)
            else if message = 8
                this.RestoreEmptyShortcut()
        }
        return DllCall("comctl32\DefSubclassProc", "Ptr", hwnd, "UInt", message, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }

    FocusControl(top, height, *) {
        if GetKeyState("Tab")
            this.KeyboardFocusVisible := true
        this.EnsureVisible(top, height)
    }

    CaptionTheme() {
        try {
            mode := Buffer(4, 0)
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Window.Hwnd, "UInt", 20, "Ptr", mode, "UInt", 4)
            NumPut("UInt", 0xF3F3F3, mode)
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Window.Hwnd, "UInt", 35, "Ptr", mode, "UInt", 4)
        }
    }

    Load(settings) {
        this.Loading := true
        try {
            this.BracketsEnabled.Value := settings.BracketsEnabled
            this.BracketPair.Choose(ToolSettings.IndexOf(ToolSettings.Pairs, settings.BracketPair))
            this.ChineseOnly.Value := settings.ChineseOnly
            this.WindowSwitchEnabled.Value := settings.WindowSwitchEnabled
            this.WindowShortcut.Value := settings.WindowShortcut
            this.ExplorerFoldersOnly.Value := settings.ExplorerFoldersOnly
            this.ImeEnabled.Value := settings.ImeEnabled
            this.ImeExcludedProcesses.Value := settings.ImeExcludedProcesses
            this.AudioEnabled.Value := settings.AudioEnabled
            this.AudioInterval.Choose(ToolSettings.IndexOf(ToolSettings.AudioIntervals, settings.AudioIntervalMs))
            this.SyncStartup()
            this.UpdateControlStates()
        } finally {
            this.Loading := false
        }
    }

    Read() {
        return {
            BracketsEnabled: !!this.BracketsEnabled.Value,
            BracketPair: ToolSettings.Pairs[this.BracketPair.Value],
            ChineseOnly: !!this.ChineseOnly.Value,
            WindowSwitchEnabled: !!this.WindowSwitchEnabled.Value,
            WindowShortcut: this.WindowShortcut.Value,
            ExplorerFoldersOnly: !!this.ExplorerFoldersOnly.Value,
            ImeEnabled: !!this.ImeEnabled.Value,
            ImeExcludedProcesses: this.ImeExcludedProcesses.Value,
            AudioEnabled: !!this.AudioEnabled.Value,
            AudioIntervalMs: ToolSettings.AudioIntervals[this.AudioInterval.Value]
        }
    }

    Changed(*) {
        if this.Loading || this.Destroyed
            return
        SetTimer(this.SaveExcludedTimer, 0)
        this.ExclusionPending := false
        settings := this.Read()
        if settings.WindowShortcut = "" {
            this.SetStatus("warning", "请按下新的组合键，快捷键为空时不会保存")
            this.UpdateControlStates()
            return false
        }
        try {
            this.OnChange.Call(settings)
            this.Saved := settings.Clone()
            this.SetStatus("saved", "已于 " FormatTime(, "HH:mm:ss") " 保存")
        } catch as err {
            this.Load(this.Saved)
            this.SetStatus("error", "未能保存，已恢复之前的设置。" err.Message)
        }
        this.UpdateControlStates()
    }

    QueueExcluded(*) {
        if this.Loading || this.Destroyed
            return
        this.ExclusionPending := true
        SetTimer(this.SaveExcludedTimer, -500)
    }

    FlushExcluded(*) {
        if !this.ExclusionPending || this.Destroyed
            return
        this.Changed()
    }

    RestoreEmptyShortcut(*) {
        if this.Loading || this.Destroyed
            return
        if this.WindowShortcut.Value = "" {
            this.WindowShortcut.Value := this.Saved.WindowShortcut
            this.SetStatus("idle")
        }
    }

    UpdateControlStates() {
        for group, enabled in Map("Brackets", this.BracketsEnabled.Value, "Ime", this.ImeEnabled.Value, "Window", this.WindowSwitchEnabled.Value, "Audio", this.AudioEnabled.Value) {
            for item in this.SubTextGroups[group]
                item.Control.SetFont("c" (!enabled ? SettingsTheme.Disabled : item.Secondary ? SettingsTheme.Secondary : SettingsTheme.Text))
        }
        this.BracketPair.Enabled := this.BracketsEnabled.Value
        this.ChineseOnly.Enabled := this.BracketsEnabled.Value
        this.WindowShortcut.Enabled := this.WindowSwitchEnabled.Value
        this.ExplorerFoldersOnly.Enabled := this.WindowSwitchEnabled.Value
        this.ImeExcludedProcesses.Enabled := this.ImeEnabled.Value
        this.AudioInterval.Enabled := this.AudioEnabled.Value
    }

    StartupChanged(*) {
        if this.Loading
            return
        try {
            this.OnStartupChange.Call(!!this.StartupEnabled.Value)
            this.SetStatus("saved", this.StartupEnabled.Value ? "已开启登录时自动运行" : "已关闭登录时自动运行")
        } catch as err {
            this.SyncStartup()
            this.SetStatus("error", "未能更改登录时自动运行。" err.Message)
        }
    }

    SyncStartup() {
        this.StartupEnabled.Value := ToolStartup.IsEnabled()
    }

    StatusKind {
        get => this._StatusKind
    }

    SetStatus(kind, text := "") {
        this._StatusKind := kind
        if kind = "idle" {
            this.StatusIcon.Visible := false
            this.Status.Move(this.Theme.Px(24), , this.Theme.Px(592))
            this.Status.Text := "更改会立即生效并自动保存"
            this.Status.SetFont("c" SettingsTheme.Secondary)
            return
        }
        symbols := Map("saved", [0xE73E, "0F7B0F"], "warning", [0xE7BA, "9D5D00"], "error", [0xE783, "C42B1C"])
        symbol := symbols[kind]
        this.StatusIcon.Text := Chr(symbol[1])
        this.StatusIcon.SetFont("c" symbol[2])
        this.StatusIcon.Visible := true
        this.Status.Move(this.Theme.Px(44), , this.Theme.Px(572))
        this.Status.Text := text
        this.Status.SetFont("c" (kind = "saved" ? SettingsTheme.Secondary : SettingsTheme.Text))
    }

    Show(*) {
        if this.Destroyed
            return
        this.SyncStartup()
        this.SetStatus("idle")
        if this.Theme.RefreshAccent() {
            previousBitmaps := this.Canvas.Toggles
            this.Canvas.Toggles := Map()
            for toggle in this.Toggles
                toggle.Redraw()
            for key, bitmap in previousBitmaps
                DllCall("DeleteObject", "Ptr", bitmap)
        }
        if !this.HasBeenShown {
            MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
            height := Max(this.Theme.Px(332), Min(this.Theme.Px(920), bottom - top - this.Theme.Px(96)))
            this.Window.Show("Hide w" this.Theme.Px(640) " h" height)
            bounds := Buffer(16, 0)
            if !DllCall("GetWindowRect", "Ptr", this.Window.Hwnd, "Ptr", bounds)
                throw OSError()
            width := NumGet(bounds, 8, "Int") - NumGet(bounds, 0, "Int")
            outerHeight := NumGet(bounds, 12, "Int") - NumGet(bounds, 4, "Int")
            x := left + Round((right - left - width) / 2)
            y := top + Round((bottom - top - outerHeight) / 2)
            this.Window.Show("x" x " y" y)
            this.HasBeenShown := true
        } else {
            this.Window.Show()
        }
        for toggle in this.Toggles
            toggle.Picture.Redraw()
    }

    Hide(*) {
        this.RestoreEmptyShortcut()
        this.FlushExcluded()
        this.Window.Hide()
        return true
    }

    Sized(gui, state, width, height) {
        if state = -1 || this.Destroyed
            return
        this.ResizeContent(height)
    }

    ResizeContent(height) {
        this.ViewportHeight := Max(1, height - this.Theme.Px(ToolSettingsWindow.HeaderHeight))
        DllCall("SetWindowPos", "Ptr", this.Viewport.Hwnd, "Ptr", 0, "Int", 0, "Int", this.Theme.Px(92), "Int", this.Theme.Px(640), "Int", this.ViewportHeight, "UInt", 0x54)
        contentHeight := this.Theme.Px(ToolSettingsWindow.ContentHeight)
        DllCall("ShowScrollBar", "Ptr", this.Viewport.Hwnd, "Int", 1, "Int", this.ViewportHeight < contentHeight)
        info := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 7, "Int", 0, "Int", contentHeight - 1, "UInt", this.ViewportHeight, "Int", this.ScrollPosition, info)
        DllCall("SetScrollInfo", "Ptr", this.Viewport.Hwnd, "Int", 1, "Ptr", info, "Int", 1)
        this.ScrollTo(this.ScrollPosition)
    }

    ScrollTo(position) {
        maximum := Max(0, this.Theme.Px(ToolSettingsWindow.ContentHeight) - this.ViewportHeight)
        this.ScrollPosition := Max(0, Min(maximum, Round(position)))
        DllCall("SetWindowPos", "Ptr", this.Content.Hwnd, "Ptr", 0, "Int", 0, "Int", -this.ScrollPosition, "Int", this.Theme.Px(640), "Int", this.Theme.Px(828), "UInt", 0x54)
        DllCall("SetScrollPos", "Ptr", this.Viewport.Hwnd, "Int", 1, "Int", this.ScrollPosition, "Int", 1)
    }

    EnsureVisible(top, height) {
        rowTop := this.Theme.Px(top - 8)
        rowBottom := this.Theme.Px(top + height + 8)
        if rowTop < this.ScrollPosition
            this.ScrollTo(rowTop)
        else if rowBottom > this.ScrollPosition + this.ViewportHeight
            this.ScrollTo(rowBottom - this.ViewportHeight)
    }

    Owns(hwnd) {
        return !this.Destroyed && DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr") = this.Window.Hwnd
    }

    VerticalScroll(wParam, lParam, message, hwnd) {
        if this.Destroyed || hwnd != this.Viewport.Hwnd || lParam
            return
        action := wParam & 0xFFFF
        position := this.ScrollPosition
        switch action {
            case 0: position -= this.Theme.Px(24)
            case 1: position += this.Theme.Px(24)
            case 2: position -= Max(1, this.ViewportHeight - this.Theme.Px(48))
            case 3: position += Max(1, this.ViewportHeight - this.Theme.Px(48))
            case 4, 5:
                info := Buffer(28, 0)
                NumPut("UInt", 28, "UInt", 0x10, info)
                DllCall("GetScrollInfo", "Ptr", hwnd, "Int", 1, "Ptr", info)
                position := NumGet(info, 24, "Int")
            case 6: position := 0
            case 7: position := this.Theme.Px(828)
            default: return
        }
        this.ScrollTo(position)
        return 0
    }

    MouseWheel(wParam, lParam, message, hwnd) {
        MouseGetPos(, , &windowUnderMouse, &controlUnderMouse, 2)
        if !this.Owns(windowUnderMouse)
            return
        for control in [this.BracketPair, this.AudioInterval] {
            if DllCall("SendMessageW", "Ptr", control.Hwnd, "UInt", 0x157, "Ptr", 0, "Ptr", 0, "Ptr")
                return
        }
        delta := (wParam >> 16) & 0xFFFF
        if delta >= 0x8000
            delta -= 0x10000
        this.WheelRemainder += delta
        steps := this.WheelRemainder >= 0 ? Floor(this.WheelRemainder / 120) : Ceil(this.WheelRemainder / 120)
        this.WheelRemainder -= steps * 120
        this.ScrollTo(this.ScrollPosition - steps * this.Theme.Px(48))
        return 0
    }

    KeyDown(wParam, lParam, message, hwnd) {
        if !this.Owns(hwnd)
            return
        if wParam = 9 || (wParam >= 0x25 && wParam <= 0x28) {
            this.KeyboardFocusVisible := true
            for toggle in this.Toggles {
                if toggle.HasFocus
                    toggle.Redraw()
            }
        }
    }

    MouseDown(wParam, lParam, message, hwnd) {
        if !this.Owns(hwnd)
            return
        this.KeyboardFocusVisible := false
        for toggle in this.Toggles {
            if toggle.HasFocus
                toggle.Redraw()
        }
    }

    MouseMoved(wParam, lParam, message, hwnd) {
        if !this.Owns(hwnd)
            return
        toggle := this.ToggleHandles.Has(hwnd) ? this.ToggleHandles[hwnd] : 0
        if toggle = this.HoveredToggle
            return
        this.SetHovered(toggle)
    }

    SetHovered(toggle) {
        if this.HoveredToggle {
            this.HoveredToggle.Hover := false
            this.HoveredToggle.Redraw()
        }
        this.HoveredToggle := toggle
        if toggle && toggle.Enabled {
            toggle.Hover := true
            toggle.Redraw()
            SetTimer(this.HoverTimer, 50)
        } else {
            SetTimer(this.HoverTimer, 0)
        }
    }

    CheckHover() {
        if this.Destroyed
            return
        MouseGetPos(, , , &controlUnderMouse, 2)
        if !this.ToggleHandles.Has(controlUnderMouse) || this.ToggleHandles[controlUnderMouse] != this.HoveredToggle
            this.SetHovered(0)
    }

    Destroy(*) {
        if this.Destroyed
            return
        this.Destroyed := true
        SetTimer(this.SaveExcludedTimer, 0)
        SetTimer(this.HoverTimer, 0)
        for message, handler in this.Handlers
            OnMessage(message, handler, 0)
        OnExit(this.ExitHandler, 0)
        if this.HotkeySubclassCallback {
            DllCall("comctl32\RemoveWindowSubclass", "Ptr", this.HotkeyControl.Hwnd, "Ptr", this.HotkeySubclassCallback, "UPtr", 1, "Int")
            CallbackFree(this.HotkeySubclassCallback)
        }
        this.Content.Destroy()
        this.Viewport.Destroy()
        this.Window.Destroy()
        this.Canvas.Dispose()
    }
}
