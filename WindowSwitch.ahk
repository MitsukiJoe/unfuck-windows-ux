#Requires AutoHotkey v2.0
TraySetIcon(A_ScriptDir "\icons\window.ico")

; 按下 Alt + ` (Tab上方那个键)
!`::
{
    try {
        ; 1. 获取当前活动窗口的进程名称 (例如 chrome.exe, Code.exe)
        activeProcName := WinGetProcessName("A")
        activeClass := WinGetClass("A")

        ; 2. 针对资源管理器 (Explorer) 的特殊处理
        ; 因为任务栏和桌面也属于 explorer.exe，我们只针对文件夹窗口类切换
        if (activeProcName = "explorer.exe") {
            if (activeClass = "CabinetWClass") {
                WinActivateBottom("ahk_class CabinetWClass")
            }
            return
        }

        ; 3. 针对普通应用，按进程名精确匹配切换
        ; 这样 Chrome (chrome.exe) 和 VS Code (Code.exe) 就会被彻底分开
        WinActivateBottom("ahk_exe " activeProcName)
    }
}
