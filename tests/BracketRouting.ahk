#Requires AutoHotkey v2.0
#NoTrayIcon
#Warn All, StdOut
#Include ..\lib\BracketMapper.ahk

class RoutingFixture {
    __New(className) {
        this.ClassName := className
        this.Received := ""
        this.Packets := 0
        this.Module := DllCall("GetModuleHandleW", "Ptr", 0, "Ptr")
        this.Callback := CallbackCreate(ObjBindMethod(this, "WindowProc"), , 4)
        this.ClassBuffer := Buffer((StrLen(className) + 1) * 2, 0)
        StrPut(className, this.ClassBuffer, "UTF-16")
        windowClass := Buffer(16 + 8 * A_PtrSize, 0)
        NumPut("UInt", windowClass.Size, windowClass)
        NumPut("Ptr", this.Callback, windowClass, 8)
        NumPut("Ptr", this.Module, windowClass, 16 + A_PtrSize)
        NumPut("Ptr", 6, windowClass, 16 + 4 * A_PtrSize)
        NumPut("Ptr", this.ClassBuffer.Ptr, windowClass, 16 + 6 * A_PtrSize)
        if !DllCall("RegisterClassExW", "Ptr", windowClass, "UShort")
            throw OSError()
        this.Hwnd := DllCall("CreateWindowExW", "UInt", 0, "Str", className, "Str", "字符发送兼容验证", "UInt", 0xCF0000, "Int", 80, "Int", 80, "Int", 420, "Int", 150, "Ptr", 0, "Ptr", 0, "Ptr", this.Module, "Ptr", 0, "Ptr")
        if !this.Hwnd
            throw OSError()
        DllCall("ShowWindow", "Ptr", this.Hwnd, "Int", 5)
        WinActivate(this.Hwnd)
        if !WinWaitActive(this.Hwnd, , 2)
            throw Error("Test window did not gain focus")
    }

    WindowProc(hwnd, message, wParam, lParam) {
        if message = 0x100 && wParam = 0xE7
            this.Packets += 1
        if message = 0x102 {
            this.Received .= Chr(wParam)
            return 0
        }
        return DllCall("DefWindowProcW", "Ptr", hwnd, "UInt", message, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }

    Destroy() {
        DllCall("DestroyWindow", "Ptr", this.Hwnd)
        DllCall("UnregisterClassW", "Ptr", this.ClassBuffer, "Ptr", this.Module)
        CallbackFree(this.Callback)
    }
}

RunRoutingTests() {
    mapper := BracketMapper()
    mapper.Configure(true, "「」", false)
    try {
        for sample in [["Qt5152QWindowIcon", true], ["Qt683QWindowIcon", true], ["Qt683dQWindowOwnDCIcon", true], ["Qt683CustomNamespaceQWindowPopupSaveBits", true], ["Qt683QWindowIcon{e01702dd-3b5c-48ee-8181-f5301e62d284}", true], ["Qt683NativeInputFixture", false], ["NativeCharacterInputFixture", false]] {
            className := sample[1]
            fixture := RoutingFixture(className)
            try {
                for character in ["「", "」", "『", "』", "〖", "〗", "〔", "〕"] {
                    if !WinActive(fixture.Hwnd)
                        throw Error("Test window lost focus")
                    mapper.SendCharacter(character)
                    Sleep(20)
                }
                if fixture.Received != "「」『』〖〗〔〕"
                    throw Error("Character delivery mismatch for " className ": " fixture.Received)
                expectedQt := sample[2]
                if expectedQt && fixture.Packets
                    throw Error("Qt framework window still received Unicode key packets: " className)
                if !expectedQt && !fixture.Packets
                    throw Error("Native window no longer uses standard text input")
            } finally {
                fixture.Destroy()
            }
        }
        FileAppend("PASS: framework routing, version/debug/namespace/suffix classes, Unicode character delivery and native fallback`n", "*")
    } finally {
        mapper.Configure(false)
    }
}

try {
    RunRoutingTests()
    ExitApp(0)
} catch as routingFailure {
    FileAppend("FAIL: " routingFailure.Message "`n" routingFailure.Stack "`n", "*")
    ExitApp(1)
}
