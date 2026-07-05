#Requires AutoHotkey v2.0
TraySetIcon("mmsys.cpl", 1) ; 扬声器图标
#SingleInstance Force
Persistent

global E_RENDER := 0
global E_CONSOLE := 0
global E_COMMUNICATIONS := 2
global g_syncing := false

; 立即运行一次，然后每 2 秒运行一次
SyncAudioDevices()
SetTimer(SyncAudioDevices, 2000)

SyncAudioDevices() {
    global E_RENDER, E_CONSOLE, E_COMMUNICATIONS, g_syncing

    if g_syncing
        return

    g_syncing := true
    try {
        defaultPlaybackId := GetDefaultAudioEndpointId(E_RENDER, E_CONSOLE)
        defaultCommPlaybackId := GetDefaultAudioEndpointId(E_RENDER, E_COMMUNICATIONS)

        if (defaultPlaybackId != "" && defaultPlaybackId != defaultCommPlaybackId)
            SetDefaultAudioEndpoint(defaultPlaybackId, E_COMMUNICATIONS)
    } finally {
        g_syncing := false
    }
}

GetDefaultAudioEndpointId(dataFlow, role) {
    static CLSID_MMDeviceEnumerator := "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
    static IID_IMMDeviceEnumerator := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"

    deviceEnumeratorObj := 0
    deviceEnumerator := 0
    device := 0
    idPtr := 0

    try {
        deviceEnumeratorObj := ComObject(CLSID_MMDeviceEnumerator, IID_IMMDeviceEnumerator)
        deviceEnumerator := ComObjValue(deviceEnumeratorObj)
        hr := DllCall(VTable(deviceEnumerator, 4), "ptr", deviceEnumerator, "int", dataFlow, "int", role, "ptr*", &device, "uint")
        if (hr != 0 || !device)
            return ""

        hr := DllCall(VTable(device, 5), "ptr", device, "ptr*", &idPtr, "uint")
        if (hr != 0 || !idPtr)
            return ""

        return StrGet(idPtr, "UTF-16")
    } catch {
        return ""
    } finally {
        if idPtr
            DllCall("Ole32\CoTaskMemFree", "ptr", idPtr)
        if device
            ObjRelease(device)
    }
}

SetDefaultAudioEndpoint(deviceId, role) {
    static CLSID_PolicyConfigClient := "{870AF99C-171D-4F9E-AF0D-E63DF40C2BC9}"
    static IID_IPolicyConfig := "{F8679F50-850A-41CF-9C72-430F290290C8}"

    policyConfigObj := 0
    policyConfig := 0

    try {
        policyConfigObj := ComObject(CLSID_PolicyConfigClient, IID_IPolicyConfig)
        policyConfig := ComObjValue(policyConfigObj)
        return DllCall(VTable(policyConfig, 13), "ptr", policyConfig, "wstr", deviceId, "int", role, "uint") == 0
    } catch {
        return false
    }
}

VTable(ptr, methodIndex) {
    return NumGet(NumGet(ptr, "ptr") + methodIndex * A_PtrSize, "ptr")
}
