<p align="center">
  <img src="assets/msbelike.png" alt="msbelike" width="720" />
  <br>
  <i>↑ Microsoft be like ↑</i>
</p>

<p align="center">
  <a href="README_EN.md">English</a> | <a href="README.md">中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AutoHotkey-2-red" alt="AutoHotkey v2" />
  <img src="https://img.shields.io/badge/platform-Windows-0078D6?logo=windows&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/fixes-decades%20overdue-red4" alt="Fixes" />
  <img src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-green" alt="License" />
  <img src="https://img.shields.io/badge/microsoft%20gave%20a%20shit-nope-lightgrey" alt="Microsoft" />
</p>

Essentially, this is a pile of AutoHotkey scripts for Windows.

Small utility scripts I wrote for myself to deal with the daily UX paper cuts that Microsoft has had decades and unlimited resources to fix, yet chose not to.

Runs on [AutoHotkey v2](https://www.autohotkey.com/download/).

## KeepImeState.ahk

#### What it for

**"Windows Pinyin IME must always stay in Pinyin mode"** — period.

A script born out of sheer rage for people who use `Alt + Shift` to switch input languages.

Here's the deal: if you're using Microsoft Pinyin and you switch to any window that happens to be locked to English, the IME immediately and permanently switches to English. And when you switch back? Still English. Sometimes it even refuses to switch back to Pinyin no matter what you do. This "feature" has persisted from Windows 10 straight through to Windows 11, completely unfixed.

This script locks the Microsoft Pinyin IME into Pinyin input mode and keeps it there, no matter what.

#### Pain points addressed:

- IME state constantly goes out of sync when tabbing between chat, browsers, and code editors
- Bouncing between Chinese client content and terminals forces manual IME toggling over and over
- Windows' per-application IME state memory is inconsistent garbage at best

## SyncAudioComm.ahk

#### What it for

Congratulations! You no longer have to endure this absolutely psychotic workflow:

**`Control Panel → Hardware and Sound → Sound → Playback devices → Set Default`**

Or even worse, the "modern" experience:

**`Settings → System → Sound → Output device → Set as default → click again → Also set as default communication device`**

Some engineer at Redmond must have been blackout drunk when they designed this convoluted, hostile UX.

Now just hit **`Ctrl + Win + V`** and pick the device you want.

The script uses the Windows Core Audio API to automatically sync the **Default Communication Device** to whatever the current **Default Playback Device** is.

#### Pain points addressed:

- Windows treats **Default Device** and **Default Communication Device** as two entirely separate things (why??), so after switching headphones or speakers — or using the `Ctrl + Win + V` picker — apps like Discord or Teamspeak that rely on the communication device still route audio to the old output
- Communication apps like Discord, Teamspeak, and WeChat routinely fall out of sync with the system default output
- You're forced to manually dig into Sound settings just to fix something that should have been automatic since day one

## WindowSwitch.ahk

#### What it for

**Cycle through windows of the same app using `Alt + ~` — just like macOS does natively.**

And because you're on Windows, you also get `Win + Number` to jump between apps, while `Alt + ~` handles cycling within the same app.

File Explorer windows get special treatment: the script only cycles between actual Explorer windows, avoiding the classic annoyance of accidentally switching to the desktop or taskbar.

#### Pain points addressed:

- `Alt + Tab` is sluggish and unwieldy when you have a lot of windows open
- The default Windows window-switching order for multi-window apps is unintuitive and roundabout
- Jumping between multiple File Explorer windows is far more painful than it needs to be

---

**Completely free. Commercial resale is strictly prohibited.** This project is licensed under CC BY-NC-SA 4.0. If you paid for any part of this project on any platform, you've been scammed — demand a refund and report the seller immediately.
