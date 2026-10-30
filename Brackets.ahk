#Requires AutoHotkey v2.0
#SingleInstance Force
#Include lib\BracketMapper.ahk

A_IconTip := "Brackets · 中文直角引号"
mapper := BracketMapper()
mapper.Configure(true)
