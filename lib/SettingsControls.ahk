class SettingsTheme {
    static Background := "F3F3F3"
    static Card := "FBFBFB"
    static Border := "E5E5E5"
    static Divider := "EAEAEA"
    static Text := "1B1B1B"
    static Secondary := "5F5F5F"
    static Disabled := "A0A0A0"

    __New(scale := 0) {
        this.Scale := scale ? scale : A_ScreenDPI / 96
        this.Font := "Microsoft YaHei UI"
        this.IconFont := "Segoe MDL2 Assets"
        try {
            RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts", "Segoe Fluent Icons (TrueType)")
            this.IconFont := "Segoe Fluent Icons"
        }
        this.RefreshAccent()
    }

    Px(dip) {
        return Round(dip * this.Scale)
    }

    RefreshAccent() {
        color := "005FB8"
        try {
            palette := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent", "AccentPalette")
            if StrLen(palette) >= 38
                color := StrUpper(SubStr(palette, 33, 6))
        }
        changed := !this.HasOwnProp("Accent") || this.Accent != color
        this.Accent := color
        blended := []
        Loop 3
            blended.Push(Round(Integer("0x" SubStr(color, A_Index * 2 - 1, 2)) * 0.9 + 251 * 0.1))
        this.AccentHover := Format("{:02X}{:02X}{:02X}", blended*)
        return changed
    }
}

class SettingsCanvas {
    __New(theme) {
        this.Theme := theme
        this.Toggles := Map()
        this.BackgroundBitmap := 0
        this.Disposed := false
        this.Module := DllCall("LoadLibrary", "Str", "gdiplus.dll", "Ptr")
        startup := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
        NumPut("UInt", 1, startup)
        token := 0
        this.Check(DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", startup, "Ptr", 0))
        this.Token := token
    }

    Check(status) {
        if status
            throw Error("绘图组件初始化失败（" status "）")
    }

    Begin(width, height, background) {
        bitmap := 0
        graphics := 0
        this.Check(DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", width, "Int", height, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bitmap))
        this.Check(DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bitmap, "Ptr*", &graphics))
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", graphics, "Int", 4)
        DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", graphics, "Int", 4)
        DllCall("gdiplus\GdipGraphicsClear", "Ptr", graphics, "UInt", Integer("0xFF" background))
        return {Bitmap: bitmap, Graphics: graphics}
    }

    Finish(surface) {
        handle := 0
        try {
            this.Check(DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", surface.Bitmap, "Ptr*", &handle, "UInt", 0xFFFFFFFF))
            return handle
        } finally {
            DllCall("gdiplus\GdipDeleteGraphics", "Ptr", surface.Graphics)
            DllCall("gdiplus\GdipDisposeImage", "Ptr", surface.Bitmap)
        }
    }

    RoundRect(graphics, x, y, width, height, radius, fill, outline := "", thickness := 1) {
        path := 0
        brush := 0
        pen := 0
        this.Check(DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path))
        try {
            diameter := radius * 2
            for arc in [[x, y, 180], [x + width - diameter, y, 270], [x + width - diameter, y + height - diameter, 0], [x, y + height - diameter, 90]]
                DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", arc[1], "Float", arc[2], "Float", diameter, "Float", diameter, "Float", arc[3], "Float", 90)
            DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
            if fill != "" {
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", Integer("0xFF" fill), "Ptr*", &brush)
                DllCall("gdiplus\GdipFillPath", "Ptr", graphics, "Ptr", brush, "Ptr", path)
            }
            if outline != "" {
                DllCall("gdiplus\GdipCreatePen1", "UInt", Integer("0xFF" outline), "Float", thickness, "Int", 2, "Ptr*", &pen)
                DllCall("gdiplus\GdipDrawPath", "Ptr", graphics, "Ptr", pen, "Ptr", path)
            }
        } finally {
            if pen
                DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
            if brush
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
            DllCall("gdiplus\GdipDeletePath", "Ptr", path)
        }
    }

    FillRect(graphics, x, y, width, height, color) {
        brush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", Integer("0xFF" color), "Ptr*", &brush)
        try DllCall("gdiplus\GdipFillRectangle", "Ptr", graphics, "Ptr", brush, "Float", x, "Float", y, "Float", width, "Float", height)
        finally DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    }

    DrawBackground() {
        theme := this.Theme
        surface := this.Begin(theme.Px(640), theme.Px(828), SettingsTheme.Background)
        line := Max(1, theme.Px(1))
        for card in [[4, 190, [68, 129]], [198, 129, [68]], [331, 190, [68, 129]], [525, 129, [68]], [706, 68, []]] {
            this.RoundRect(surface.Graphics, theme.Px(24) + line / 2, theme.Px(card[1]) + line / 2, theme.Px(592) - line, theme.Px(card[2]) - line, theme.Px(4), SettingsTheme.Card, SettingsTheme.Border, line)
            for separator in card[3]
                this.FillRect(surface.Graphics, theme.Px(25), theme.Px(card[1] + separator), theme.Px(590), line, SettingsTheme.Divider)
        }
        this.BackgroundBitmap := this.Finish(surface)
        return this.BackgroundBitmap
    }

    ToggleBitmap(value, hover, enabled, focus) {
        key := value "|" hover "|" enabled "|" focus "|" this.Theme.Accent
        if this.Toggles.Has(key)
            return this.Toggles[key]
        theme := this.Theme
        surface := this.Begin(theme.Px(48), theme.Px(28), SettingsTheme.Card)
        outline := ""
        if !enabled {
            fill := value ? "C5C5C5" : SettingsTheme.Card
            thumb := value ? "FFFFFF" : "C5C5C5"
            if !value
                outline := "C5C5C5"
        } else if value {
            fill := hover ? theme.AccentHover : theme.Accent
            thumb := "FFFFFF"
        } else {
            fill := hover ? "ECECEC" : "F5F5F5"
            outline := "8B8B8B"
            thumb := "5F5F5F"
        }
        border := Max(1, theme.Px(1))
        this.RoundRect(surface.Graphics, theme.Px(4) + border / 2, theme.Px(4) + border / 2, theme.Px(40) - border, theme.Px(20) - border, theme.Px(10) - border / 2, fill, outline, border)
        diameter := enabled && hover ? 14 : 12
        center := value ? 34 : 14
        this.RoundRect(surface.Graphics, theme.Px(center - diameter / 2), theme.Px(14 - diameter / 2), theme.Px(diameter), theme.Px(diameter), theme.Px(diameter / 2), thumb)
        if focus && enabled
            this.RoundRect(surface.Graphics, theme.Px(1), theme.Px(1), theme.Px(46), theme.Px(26), theme.Px(13), "", SettingsTheme.Text, Max(1, theme.Px(2)))
        handle := this.Finish(surface)
        this.Toggles[key] := handle
        return handle
    }

    Dispose() {
        if this.Disposed
            return
        this.Disposed := true
        for key, handle in this.Toggles
            DllCall("DeleteObject", "Ptr", handle)
        this.Toggles.Clear()
        if this.BackgroundBitmap
            DllCall("DeleteObject", "Ptr", this.BackgroundBitmap)
        if this.Token
            DllCall("gdiplus\GdiplusShutdown", "Ptr", this.Token)
        if this.Module
            DllCall("FreeLibrary", "Ptr", this.Module)
    }
}

class SettingsToggle {
    __New(owner, title, rowTop, rowHeight, callback) {
        this.Owner := owner
        this.Callback := callback
        this.Hover := false
        this.HasFocus := false
        theme := owner.Theme
        this.Proxy := owner.Content.AddCheckBox("x-2000 y" theme.Px(rowTop) " w" theme.Px(300) " h" theme.Px(20), title)
        this.Picture := owner.Content.AddPicture("x" theme.Px(24 + 532) " y" theme.Px(rowTop + (rowHeight - 28) / 2) " w" theme.Px(48) " h" theme.Px(28))
        this.Label := owner.Content.AddText("x" theme.Px(24 + 496) " y" theme.Px(rowTop + (rowHeight - 20) / 2) " w" theme.Px(28) " h" theme.Px(20) " +Right +0x200 Background" SettingsTheme.Card, "关")
        this.Proxy.OnEvent("Click", ObjBindMethod(this, "ProxyChanged"))
        this.Proxy.OnEvent("Focus", ObjBindMethod(this, "Focused"))
        this.Proxy.OnEvent("LoseFocus", ObjBindMethod(this, "Blurred"))
        for control in [this.Picture, this.Label] {
            control.OnEvent("Click", ObjBindMethod(this, "MouseToggle"))
            control.OnEvent("DoubleClick", ObjBindMethod(this, "MouseToggle"))
            owner.ToggleHandles[control.Hwnd] := this
        }
        owner.RegisterFocus(this.Proxy, rowTop, rowHeight)
        owner.Toggles.Push(this)
        this.Redraw()
    }

    Value {
        get => !!this.Proxy.Value
        set {
            this.Proxy.Value := !!value
            this.Redraw()
        }
    }

    Enabled {
        get => this.Proxy.Enabled
        set {
            this.Proxy.Enabled := !!value
            this.Redraw()
        }
    }

    Toggle(*) {
        if !this.Enabled
            return
        this.Proxy.Value := !this.Proxy.Value
        this.ProxyChanged()
    }

    MouseToggle(*) {
        if !this.Enabled
            return
        this.Owner.KeyboardFocusVisible := false
        this.Proxy.Focus()
        this.Toggle()
    }

    ProxyChanged(*) {
        this.Redraw()
        this.Callback.Call()
    }

    Focused(*) {
        this.HasFocus := true
        if GetKeyState("Tab")
            this.Owner.KeyboardFocusVisible := true
        this.Redraw()
    }

    Blurred(*) {
        this.HasFocus := false
        this.Redraw()
    }

    Redraw() {
        bitmap := this.Owner.Canvas.ToggleBitmap(this.Value, this.Hover && this.Enabled, this.Enabled, this.HasFocus && this.Owner.KeyboardFocusVisible)
        this.Picture.Value := "HBITMAP:*" bitmap
        this.Picture.Redraw()
        this.Label.Text := this.Value ? "开" : "关"
        this.Label.SetFont("c" (this.Enabled ? SettingsTheme.Text : SettingsTheme.Disabled))
    }
}
