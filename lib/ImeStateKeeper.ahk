class ImeStateKeeper {
    Enabled := false
    ExcludedProcesses := ""
    CHECK_INTERVAL_MS := 150
    RETRY_DELAY_MS := 80
    IME_CMODE_NATIVE := 0x0001
    WM_IME_CONTROL := 0x0283
    IMC_GETCONVERSIONMODE := 0x0001
    IMC_SETCONVERSIONMODE := 0x0002
    IMC_GETSENTENCEMODE := 0x0003
    IMC_SETSENTENCEMODE := 0x0004
    IMC_GETOPENSTATUS := 0x0005
    IMC_SETOPENSTATUS := 0x0006
    g_debugEnabled := false
    g_lastSnapshotKey := ""
    LOG_PATH := A_ScriptDir "\KeepImeState.log"

    __New() {
        this.Timer := ObjBindMethod(this, "EnsureChineseMode")
    }

    Configure(enabled, excludedProcesses := "", interval := 150) {
        changed := this.Enabled != enabled || this.CHECK_INTERVAL_MS != interval
        this.Enabled := enabled
        this.ExcludedProcesses := excludedProcesses
        this.CHECK_INTERVAL_MS := interval
        if changed {
            SetTimer(this.Timer, enabled ? interval : 0)
            if enabled
                this.EnsureChineseMode()
        }
    }

    EnsureChineseMode() {
        if !this.Enabled
            return

        hwnd := this.GetImeTargetHwnd()
        if !hwnd
            return

        if !this.IsSimplifiedChineseLayout(hwnd)
            return

        state := this.GetImeState(hwnd)
        if !state.ok
            return
        if this.ShouldSkipState(state)
            return

        snapshotKey := this.MakeSnapshotKey(state)
        if (snapshotKey != this.g_lastSnapshotKey) {
            this.g_lastSnapshotKey := snapshotKey
            this.LogLine("state changed: " this.DescribeStateInline(state))
        }

        if !this.NeedsChineseFix(state)
            return

        this.ApplyChineseFix(hwnd, state, "timer")
    }

    ForceChineseModeWithReport() {
        hwnd := this.GetImeTargetHwnd()
        if !hwnd {
            MsgBox("No active IME target window was found.", "KeepImeState")
            return
        }

        before := this.GetImeState(hwnd)
        this.ApplyChineseFix(hwnd, before, "hotkey")
        Sleep(60)
        after := this.GetImeState(hwnd)

        MsgBox("Before:`n" this.DescribeState(before) "`n`nAfter:`n" this.DescribeState(after), "KeepImeState")
    }

    ApplyChineseFix(hwnd, state := "", reason := "manual", attempt := 1) {
        if !this.Enabled
            return false

        if !WinExist("ahk_id " hwnd)
            return false

        if !this.IsSimplifiedChineseLayout(hwnd)
            return false

        if !IsObject(state)
            state := this.GetImeState(hwnd)

        if !state.ok
            return false
        if this.ShouldSkipState(state)
            return false

        changed := false
        if !state.open {
            changed := this.SetImeOpenStatus(state, 1) || changed
        }

        if state.hasConversion {
            desiredConversion := state.conversion | this.IME_CMODE_NATIVE
            if (desiredConversion != state.conversion) {
                changed := this.SetImeConversionStatus(state, desiredConversion, state.sentence) || changed
            }
        }

        Sleep(30)
        after := this.GetImeState(hwnd)
        this.LogLine(
            "force(" reason ", attempt " attempt "): before=[" this.DescribeStateInline(state)
            "] after=[" this.DescribeStateInline(after) "]"
        )

        if this.NeedsChineseFix(after) && (attempt < 2) {
            SetTimer(ObjBindMethod(this, "ApplyChineseFix", hwnd, after, reason, attempt + 1), -this.RETRY_DELAY_MS)
        }

        return changed
    }

    ShowImeSnapshot() {
        hwnd := this.GetImeTargetHwnd()
        if !hwnd {
            MsgBox("No active IME target window was found.", "KeepImeState")
            return
        }

        state := this.GetImeState(hwnd)
        MsgBox(this.DescribeState(state), "KeepImeState")
    }

    NeedsChineseFix(state) {

        if !state.ok
            return false

        if !state.open
            return true

        if state.hasConversion && !(state.conversion & this.IME_CMODE_NATIVE)
            return true

        return false
    }

    ShouldSkipState(state) {
        proc := StrLower(state.processName)
        if (proc = "autohotkey64.exe" || proc = "autohotkey.exe")
            return true

        for excluded in StrSplit(this.ExcludedProcesses, [",", ";", "`n"]) {
            if proc = StrLower(Trim(excluded))
                return true
        }
        return false
    }

    GetImeState(hwnd) {
        state := {
            ok: false,
            hwnd: hwnd,
            sourceHwnd: 0,
            rootHwnd: this.GetTopLevelHwnd(hwnd),
            imeWnd: 0,
            queryMethod: "none",
            failureReason: "",
            windowTitle: "",
            processName: "",
            className: "",
            layout: 0,
            open: 0,
            hasConversion: false,
            conversion: 0,
            sentence: 0
        }

        try state.windowTitle := WinGetTitle("ahk_id " hwnd)
        try state.processName := WinGetProcessName("ahk_id " hwnd)
        try state.className := WinGetClass("ahk_id " hwnd)

        state.layout := this.GetKeyboardLayoutId(hwnd)

        for _, candidateHwnd in this.GetImeCandidateHwnds(hwnd) {
            immState := this.TryGetImmState(candidateHwnd)
            if IsObject(immState)
                return this.MergeImeState(state, immState)

            imeWndState := this.TryGetImeWindowState(candidateHwnd)
            if IsObject(imeWndState)
                return this.MergeImeState(state, imeWndState)
        }

        state.failureReason := "no IMM context and no default IME window response"
        return state
    }

    GetImeTargetHwnd() {
        hwnd := WinExist("A")
        if !hwnd
            return 0

        try {
            ctrl := ControlGetFocus("ahk_id " hwnd)
            if ctrl
                return ControlGetHwnd(ctrl, "ahk_id " hwnd)
        }

        return hwnd
    }

    IsSimplifiedChineseLayout(hwnd) {
        return this.GetKeyboardLayoutId(hwnd) = 0x0804
    }

    GetKeyboardLayoutId(hwnd) {
        pidBuf := Buffer(4, 0)
        tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", pidBuf, "uint")
        hkl := DllCall("GetKeyboardLayout", "uint", tid, "ptr")
        return hkl & 0xFFFF
    }

    GetImeCandidateHwnds(hwnd) {
        hwnds := []
        rootHwnd := this.GetTopLevelHwnd(hwnd)

        if hwnd
            hwnds.Push(hwnd)
        if rootHwnd && (rootHwnd != hwnd)
            hwnds.Push(rootHwnd)

        return hwnds
    }

    GetTopLevelHwnd(hwnd) {
        rootHwnd := DllCall("GetAncestor", "ptr", hwnd, "uint", 2, "ptr")
        return rootHwnd ? rootHwnd : hwnd
    }

    TryGetImmState(hwnd) {
        himc := DllCall("Imm32\ImmGetContext", "ptr", hwnd, "ptr")
        if !himc
            return ""

        state := {
            ok: true,
            sourceHwnd: hwnd,
            imeWnd: 0,
            queryMethod: "imm",
            failureReason: "",
            open: 0,
            hasConversion: false,
            conversion: 0,
            sentence: 0
        }

        try {
            state.open := DllCall("Imm32\ImmGetOpenStatus", "ptr", himc, "int")

            conversionBuf := Buffer(4, 0)
            sentenceBuf := Buffer(4, 0)
            if DllCall(
                "Imm32\ImmGetConversionStatus",
                "ptr", himc,
                "ptr", conversionBuf,
                "ptr", sentenceBuf,
                "int"
            ) {
                state.hasConversion := true
                state.conversion := NumGet(conversionBuf, 0, "uint")
                state.sentence := NumGet(sentenceBuf, 0, "uint")
            }
        } finally {
            DllCall("Imm32\ImmReleaseContext", "ptr", hwnd, "ptr", himc, "int")
        }

        return state
    }

    TryGetImeWindowState(hwnd) {

        imeWnd := DllCall("Imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr")
        if !imeWnd
            return ""

        state := {
            ok: true,
            sourceHwnd: hwnd,
            imeWnd: imeWnd,
            queryMethod: "imewnd",
            failureReason: "",
            open: this.SendImeControl(imeWnd, this.IMC_GETOPENSTATUS),
            hasConversion: true,
            conversion: this.SendImeControl(imeWnd, this.IMC_GETCONVERSIONMODE),
            sentence: this.SendImeControl(imeWnd, this.IMC_GETSENTENCEMODE)
        }

        if (state.open < 0 || state.conversion < 0 || state.sentence < 0)
            return ""
        return state
    }

    MergeImeState(baseState, methodState) {
        baseState.ok := methodState.ok
        baseState.sourceHwnd := methodState.sourceHwnd
        baseState.imeWnd := methodState.imeWnd
        baseState.queryMethod := methodState.queryMethod
        baseState.failureReason := methodState.failureReason
        baseState.open := methodState.open
        baseState.hasConversion := methodState.hasConversion
        baseState.conversion := methodState.conversion
        baseState.sentence := methodState.sentence
        return baseState
    }

    SetImeOpenStatus(state, isOpen) {

        if (state.queryMethod = "imm")
            return this.SetImmOpenStatus(state.sourceHwnd, isOpen)

        if (state.queryMethod = "imewnd")
            return this.SendImeControl(state.imeWnd, this.IMC_SETOPENSTATUS, isOpen) = 0

        return false
    }

    SetImeConversionStatus(state, conversion, sentence := 0) {

        if (state.queryMethod = "imm")
            return this.SetImmConversionStatus(state.sourceHwnd, conversion, sentence)

        if (state.queryMethod = "imewnd") {
            this.SendImeControl(state.imeWnd, this.IMC_SETSENTENCEMODE, sentence)
            return this.SendImeControl(state.imeWnd, this.IMC_SETCONVERSIONMODE, conversion) = 0
        }

        return false
    }

    SetImmOpenStatus(hwnd, isOpen) {
        himc := DllCall("Imm32\ImmGetContext", "ptr", hwnd, "ptr")
        if !himc
            return false

        try {
            return !!DllCall("Imm32\ImmSetOpenStatus", "ptr", himc, "int", isOpen, "int")
        } finally {
            DllCall("Imm32\ImmReleaseContext", "ptr", hwnd, "ptr", himc, "int")
        }
    }

    SetImmConversionStatus(hwnd, conversion, sentence) {
        himc := DllCall("Imm32\ImmGetContext", "ptr", hwnd, "ptr")
        if !himc
            return false

        try {
            return !!DllCall("Imm32\ImmSetConversionStatus", "ptr", himc, "uint", conversion, "uint", sentence, "int")
        } finally {
            DllCall("Imm32\ImmReleaseContext", "ptr", hwnd, "ptr", himc, "int")
        }
    }

    SendImeControl(imeWnd, command, value := 0) {

        result := 0
        ok := DllCall("SendMessageTimeoutW", "ptr", imeWnd, "uint", this.WM_IME_CONTROL, "uptr", command, "ptr", value, "uint", 2, "uint", 50, "uptr*", &result, "ptr")
        return ok ? result : -1
    }

    DescribeState(state) {
        text := ""
        text .= "hwnd: " this.FormatHwnd(state.hwnd) "`n"
        text .= "source-hwnd: " this.FormatHwnd(state.sourceHwnd) "`n"
        text .= "root-hwnd: " this.FormatHwnd(state.rootHwnd) "`n"
        text .= "query-method: " state.queryMethod "`n"
        text .= "ime-window: " this.FormatHwnd(state.imeWnd) "`n"
        text .= "process: " this.SafeText(state.processName) "`n"
        text .= "class: " this.SafeText(state.className) "`n"
        text .= "title: " this.SafeText(state.windowTitle) "`n"
        text .= "layout: " this.FormatHex(state.layout) "`n"

        if !state.ok {
            text .= "status: failed to query IME state`n"
            text .= "reason: " this.SafeText(state.failureReason)
            return text
        }

        text .= "open: " state.open "`n"
        if state.hasConversion {
            text .= "conversion: " this.FormatHex(state.conversion) "`n"
            text .= "sentence: " this.FormatHex(state.sentence) "`n"
            text .= "native-bit: " ((state.conversion & 0x0001) ? "on" : "off")
        } else {
            text .= "conversion: unavailable"
        }

        return text
    }

    DescribeStateInline(state) {
        if !state.ok
            return "hwnd=" this.FormatHwnd(state.hwnd) ", layout=" this.FormatHex(state.layout) ", query=failed, reason=" this.SafeText(state.failureReason)

        text := "hwnd=" this.FormatHwnd(state.hwnd)
        text .= ", src=" this.FormatHwnd(state.sourceHwnd)
        text .= ", proc=" this.SafeText(state.processName)
        text .= ", layout=" this.FormatHex(state.layout)
        text .= ", method=" state.queryMethod
        text .= ", open=" state.open

        if state.hasConversion
            text .= ", conv=" this.FormatHex(state.conversion) ", sent=" this.FormatHex(state.sentence)
        else
            text .= ", conv=unavailable"

        return text
    }

    MakeSnapshotKey(state) {
        key := state.hwnd "|" state.layout "|" state.open "|" state.hasConversion "|" state.conversion "|" state.sentence
        return key
    }

    FormatHex(value) {
        return Format("0x{:X}", value)
    }

    FormatHwnd(hwnd) {
        return Format("0x{:X}", hwnd)
    }

    SafeText(value) {
        return (value = "") ? "(empty)" : value
    }

    LogLine(text) {

        if !this.g_debugEnabled
            return

        line := FormatTime(, "yyyy-MM-dd HH:mm:ss") " | " text "`n"
        FileAppend(line, this.LOG_PATH, "UTF-8")
    }
}
