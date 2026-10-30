class BracketMapper {
    Enabled := false
    Pair := "「」"
    ChineseOnly := true

    __New() {
        this.Condition := ObjBindMethod(this, "IsActive")
        HotIf(this.Condition)
        try {
            Hotkey("+[", ObjBindMethod(this, "SendLeft"), "Off")
            Hotkey("+]", ObjBindMethod(this, "SendRight"), "Off")
        } finally {
            HotIf()
        }
    }

    Configure(enabled, pair := "「」", chineseOnly := true) {
        this.Pair := pair
        this.ChineseOnly := chineseOnly
        this.Enabled := enabled
        HotIf(this.Condition)
        try {
            Hotkey("+[", enabled ? "On" : "Off")
            Hotkey("+]", enabled ? "On" : "Off")
        } finally {
            HotIf()
        }
    }

    IsActive(*) {
        if !this.Enabled
            return false
        if !this.ChineseOnly
            return true
        hwnd := WinExist("A")
        if !hwnd
            return false
        tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")
        return tid && (DllCall("GetKeyboardLayout", "UInt", tid, "Ptr") & 0xFFFF) = 0x0804
    }

    SendLeft(*) {
        this.SendCharacter(SubStr(this.Pair, 1, 1))
    }

    SendRight(*) {
        this.SendCharacter(SubStr(this.Pair, 2, 1))
    }

    static IsQtWindowClass(className) {
        return !!RegExMatch(className, "^Qt[0-9]+[A-Za-z0-9_]*QWindow")
    }

    SendCharacter(text) {
        if !this.Enabled
            return
        hwnd := WinExist("A")
        if !hwnd
            return
        if BracketMapper.IsQtWindowClass(WinGetClass("ahk_id " hwnd))
            ControlSendText(text, hwnd)
        else
            SendText(text)
    }
}
