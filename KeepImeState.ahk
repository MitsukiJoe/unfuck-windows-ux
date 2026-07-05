#Requires AutoHotkey v2.0
TraySetIcon(A_ScriptDir "\icons\keyboard.ico")
#SingleInstance Force
Persistent

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
LOG_PATH := A_ScriptDir "\KeepImeState.log"

g_debugEnabled := false
g_lastSnapshotKey := ""

; Diagnostic hotkeys. Uncomment when you need to inspect or force IME state manually.
; ^!i::ShowImeSnapshot()
; ^!o::ForceChineseModeWithReport()

SetTimer(EnsureChineseMode, CHECK_INTERVAL_MS)
LogLine("script started")

EnsureChineseMode() {
    global g_lastSnapshotKey

    hwnd := GetImeTargetHwnd()
    if !hwnd
        return

    if !IsSimplifiedChineseLayout(hwnd)
        return

    state := GetImeState(hwnd)
    if !state.ok
        return
    if ShouldSkipState(state)
        return

    snapshotKey := MakeSnapshotKey(state)
    if (snapshotKey != g_lastSnapshotKey) {
        g_lastSnapshotKey := snapshotKey
        LogLine("state changed: " DescribeStateInline(state))
    }

    if !NeedsChineseFix(state)
        return

    ApplyChineseFix(hwnd, state, "timer")
}

ForceChineseModeWithReport() {
    hwnd := GetImeTargetHwnd()
    if !hwnd {
        MsgBox("No active IME target window was found.", "KeepImeState")
        return
    }

    before := GetImeState(hwnd)
    ApplyChineseFix(hwnd, before, "hotkey")
    Sleep(60)
    after := GetImeState(hwnd)

    MsgBox("Before:`n" DescribeState(before) "`n`nAfter:`n" DescribeState(after), "KeepImeState")
}

ApplyChineseFix(hwnd, state := "", reason := "manual", attempt := 1) {
    global IME_CMODE_NATIVE, RETRY_DELAY_MS

    if !WinExist("ahk_id " hwnd)
        return false

    if !IsSimplifiedChineseLayout(hwnd)
        return false

    if !IsObject(state)
        state := GetImeState(hwnd)

    if !state.ok
        return false
    if ShouldSkipState(state)
        return false

    changed := false
    if !state.open {
        changed := SetImeOpenStatus(state, 1) || changed
    }

    if state.hasConversion {
        desiredConversion := state.conversion | IME_CMODE_NATIVE
        if (desiredConversion != state.conversion) {
            changed := SetImeConversionStatus(state, desiredConversion, state.sentence) || changed
        }
    }

    Sleep(30)
    after := GetImeState(hwnd)
    LogLine(
        "force(" reason ", attempt " attempt "): before=[" DescribeStateInline(state)
        "] after=[" DescribeStateInline(after) "]"
    )

    if NeedsChineseFix(after) && (attempt < 2) {
        SetTimer(ApplyChineseFix.Bind(hwnd, after, reason, attempt + 1), -RETRY_DELAY_MS)
    }

    return changed
}

ShowImeSnapshot() {
    hwnd := GetImeTargetHwnd()
    if !hwnd {
        MsgBox("No active IME target window was found.", "KeepImeState")
        return
    }

    state := GetImeState(hwnd)
    MsgBox(DescribeState(state), "KeepImeState")
}

NeedsChineseFix(state) {
    global IME_CMODE_NATIVE

    if !state.ok
        return false

    if !state.open
        return true

    if state.hasConversion && !(state.conversion & IME_CMODE_NATIVE)
        return true

    return false
}

ShouldSkipState(state) {
    proc := StrLower(state.processName)
    if (proc = "autohotkey64.exe" || proc = "autohotkey.exe")
        return true

    return false
}

GetImeState(hwnd) {
    state := {
        ok: false,
        hwnd: hwnd,
        sourceHwnd: 0,
        rootHwnd: GetTopLevelHwnd(hwnd),
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

    state.layout := GetKeyboardLayoutId(hwnd)

    for _, candidateHwnd in GetImeCandidateHwnds(hwnd) {
        immState := TryGetImmState(candidateHwnd)
        if IsObject(immState)
            return MergeImeState(state, immState)

        imeWndState := TryGetImeWindowState(candidateHwnd)
        if IsObject(imeWndState)
            return MergeImeState(state, imeWndState)
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
    return GetKeyboardLayoutId(hwnd) = 0x0804
}

GetKeyboardLayoutId(hwnd) {
    pidBuf := Buffer(4, 0)
    tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", pidBuf, "uint")
    hkl := DllCall("GetKeyboardLayout", "uint", tid, "ptr")
    return hkl & 0xFFFF
}

GetImeCandidateHwnds(hwnd) {
    hwnds := []
    rootHwnd := GetTopLevelHwnd(hwnd)

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
    global IMC_GETCONVERSIONMODE, IMC_GETOPENSTATUS, IMC_GETSENTENCEMODE

    imeWnd := DllCall("Imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr")
    if !imeWnd
        return ""

    state := {
        ok: true,
        sourceHwnd: hwnd,
        imeWnd: imeWnd,
        queryMethod: "imewnd",
        failureReason: "",
        open: SendImeControl(imeWnd, IMC_GETOPENSTATUS),
        hasConversion: true,
        conversion: SendImeControl(imeWnd, IMC_GETCONVERSIONMODE),
        sentence: SendImeControl(imeWnd, IMC_GETSENTENCEMODE)
    }

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
    global IMC_SETOPENSTATUS

    if (state.queryMethod = "imm")
        return SetImmOpenStatus(state.sourceHwnd, isOpen)

    if (state.queryMethod = "imewnd")
        return SendImeControl(state.imeWnd, IMC_SETOPENSTATUS, isOpen) = 0

    return false
}

SetImeConversionStatus(state, conversion, sentence := 0) {
    global IMC_SETCONVERSIONMODE, IMC_SETSENTENCEMODE

    if (state.queryMethod = "imm")
        return SetImmConversionStatus(state.sourceHwnd, conversion, sentence)

    if (state.queryMethod = "imewnd") {
        SendImeControl(state.imeWnd, IMC_SETSENTENCEMODE, sentence)
        return SendImeControl(state.imeWnd, IMC_SETCONVERSIONMODE, conversion) = 0
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
    global WM_IME_CONTROL
    return DllCall("SendMessageW", "ptr", imeWnd, "uint", WM_IME_CONTROL, "uptr", command, "ptr", value, "ptr")
}

DescribeState(state) {
    text := ""
    text .= "hwnd: " FormatHwnd(state.hwnd) "`n"
    text .= "source-hwnd: " FormatHwnd(state.sourceHwnd) "`n"
    text .= "root-hwnd: " FormatHwnd(state.rootHwnd) "`n"
    text .= "query-method: " state.queryMethod "`n"
    text .= "ime-window: " FormatHwnd(state.imeWnd) "`n"
    text .= "process: " SafeText(state.processName) "`n"
    text .= "class: " SafeText(state.className) "`n"
    text .= "title: " SafeText(state.windowTitle) "`n"
    text .= "layout: " FormatHex(state.layout) "`n"

    if !state.ok {
        text .= "status: failed to query IME state`n"
        text .= "reason: " SafeText(state.failureReason)
        return text
    }

    text .= "open: " state.open "`n"
    if state.hasConversion {
        text .= "conversion: " FormatHex(state.conversion) "`n"
        text .= "sentence: " FormatHex(state.sentence) "`n"
        text .= "native-bit: " ((state.conversion & 0x0001) ? "on" : "off")
    } else {
        text .= "conversion: unavailable"
    }

    return text
}

DescribeStateInline(state) {
    if !state.ok
        return "hwnd=" FormatHwnd(state.hwnd) ", layout=" FormatHex(state.layout) ", query=failed, reason=" SafeText(state.failureReason)

    text := "hwnd=" FormatHwnd(state.hwnd)
    text .= ", src=" FormatHwnd(state.sourceHwnd)
    text .= ", proc=" SafeText(state.processName)
    text .= ", layout=" FormatHex(state.layout)
    text .= ", method=" state.queryMethod
    text .= ", open=" state.open

    if state.hasConversion
        text .= ", conv=" FormatHex(state.conversion) ", sent=" FormatHex(state.sentence)
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
    global g_debugEnabled, LOG_PATH

    if !g_debugEnabled
        return

    line := FormatTime(, "yyyy-MM-dd HH:mm:ss") " | " text "`n"
    FileAppend(line, LOG_PATH, "UTF-8")
}
