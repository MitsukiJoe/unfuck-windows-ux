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

本质上这是一堆 Windows 用的 AutoHotkey 小工具。

我自己用来解决 日常使用 Windows 中遇到的痛点的 小脚本。

运行环境为 [AutoHotkey v2](https://www.autohotkey.com/download/)。

## AutoHotkeyTools.ahk：统一托盘与设置

推荐双击 `AutoHotkeyTools.ahk`，用一个托盘图标管理全部四个功能。单击托盘图标打开设置，关闭设置窗口后继续在后台运行，右键托盘图标可以退出。

- 中文标点：独立开关，选择 `「」`、`『』`、`〖〗`、`〔〕`、`《》`、`〈〉`、`【】`；默认只影响简体中文布局。
- 同应用窗口切换：独立开关，自定义快捷键，选择资源管理器是否只切换文件夹窗口。
- 微软拼音中文模式保持：独立开关，支持按进程名排除应用，多个名称用逗号分隔。
- 通信音频自动跟随：独立开关，选择 1、2、5 或 10 秒的同步频率。

修改立即生效并自动保存到 `%APPDATA%\AutoHotkeyTools\settings.ini`，重启后保留。在设置窗口的“常规”分组中开启“登录 Windows 时自动运行”，自启只启动统一入口，登录时不弹设置窗口。

从旧版迁移时，关闭旧的四个脚本，并移除它们各自的启动快捷方式，再启用统一入口的登录自启，避免重复运行。旧的脚本文件仍可单独运行，功能实现统一放在 `lib/`，不要同时运行独立入口和统一入口。

运行回归检查：`AutoHotkey64.exe /ErrorStdOut tests\Smoke.ahk`。

字符发送兼容回归：`AutoHotkey64.exe /ErrorStdOut tests\BracketRouting.ahk`，使用独立窗口验证 Qt 窗口类识别和字符消息，不依赖任何特定应用。

## KeepImeState.ahk

#### 用途：

**微软拼音一定要有拼音**

为直接使用 `Alt + Shift` 切换输入法语种的人所生的脚本。

我真的巨烦 微软拼音 只要一切到某个仅限英文的窗口后，它就会一直保持着英文。  
哪怕切回到之前一直在用拼音输入的地方它也还是保持英文，并且还有几率无法切换回拼音。  
这个 BUG 从 Win10 到 Win11 就一直没修复过。

而它，则是用来把微软拼音锁定为拼音输入。

#### 解决的痛点：

- 在聊天、浏览器、编辑器之间切换时，输入法状态经常不符合当前窗口预期
- 中文客户内容和代码/命令行之间来回切换时，需要反复手动改中英文状态
- Windows 对不同应用的 IME 状态记忆不够一致

## Brackets.ahk

使用简体中文输入布局时，`Shift + [` 输入 `「`，`Shift + ]` 输入 `」`。

切换到独立的 ENG 英文键盘布局后，恢复输入 `{}`。脚本按键盘布局判断，不区分微软拼音内部的中／英模式。

根据 Qt 5/6 的标准窗口类识别字符输入兼容模式，使用字符消息发送，避开 Unicode 模拟按键可能导致左右引号重复成同一个字符的问题。识别支持版本号、调试构建和命名空间，不依赖特定程序名；其他窗口沿用常规文本输入。

双击运行即可；需要开机自启时，将脚本的快捷方式放入 Windows 启动文件夹。

## SyncAudioComm.ahk

#### 用途：

现在的你！再也不需要忍受！  
**`控制面板 - 硬件和声音 - 声音 - 选择设备 - 设为默认值`**  
甚至是  
**`设置 - 系统 - 声音 - 选择设备 - 作为音频的默认使用 - 再按一次 - 作为通信的默认使用`**  
这种不知道是喝了多少才设计出来的繁琐至极的神人操作步骤的逻辑。  
**你只需要 `Ctrl + Win + V` 然后选择你想要的播放设备即可！**


脚本会把 **`默认通信播放设备`** 自动同步成当前 **`默认播放设备`** ，使用 Windows Core Audio 接口直接处理。

#### 解决的痛点：

- Windows 把 **`默认设备`** 和 **`默认通信设备`** 分开管理，切换耳机、音箱后，或者是用 `Ctrl + Win + V` 切换设备的话，某些会议/游戏语音软件用的是 **`默认通信设备`** 就会依然走旧设备
- Discord、Teamspeak、微信 等通信类应用容易和系统默认播放设备不一致
- 设备切换后需要手动进声音设置改通信设备

## WindowSwitch.ahk

#### 用途：

**和 macOS 的逻辑一样！使用 `Alt + ~` 在同一应用的窗口之间快速切换！**

并且由于这里是 Windows，你更是可以多一份 `Win + 数字键` 切应用的快切，然后 `Alt + ~` 切应用内的窗口。

对资源管理器做了单独处理，只在文件夹窗口之间切换，避免误切到桌面或任务栏。

#### 解决的痛点：

- `Alt + Tab` 在窗口很多时不够快
- 同一个应用开多个窗口时，系统默认切换路径太绕
- 多个资源管理器窗口之间切换不够顺手

---

**完全免费，严禁商用。** 本项目采用 CC BY-NC-SA 4.0 协议授权。如果你在任何平台付费购买了本项目的任何内容，说明你被骗了，请立即退款并举报。
