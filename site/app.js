'use strict';

(() => {
  const root = document.documentElement;
  const $ = (selector, parent = document) => parent.querySelector(selector);
  const $$ = (selector, parent = document) => [...parent.querySelectorAll(selector)];
  const repo = 'https://github.com/MitsukiJoe/unfuck-windows-ux';
  const text = {
    skip: ['跳到正文', 'Skip to content'], nav: ['主导航', 'Main navigation'],
    navFeatures: ['功能体验', 'Try the features'], navArchitecture: ['代码结构', 'Under the hood'], navInstall: ['开始使用', 'Get started'],
    menu: ['打开导航', 'Open navigation'],
    heroEyebrow: ['几个 Windows 本来就该有的小功能', 'A few things Windows should already do.'],
    heroTagline: ['让 Windows 顺手一点。', 'Windows, with a little less friction.'],
    heroDescription: ['中文输入、窗口切换、耳机音频。那些每天都遇到的小别扭，用四个 AutoHotkey 脚本补上。', 'Chinese input, app windows, headphone audio. Four small AutoHotkey scripts for the little things that get in your way.'],
    heroStart: ['下载使用', 'Get the scripts'], heroDemo: ['看看怎么用', 'Try the demos'],
    heroNote: ['Windows 10 / 11 · AutoHotkey v2 · 免费，非商用', 'Windows 10 / 11 · AutoHotkey v2 · Free for noncommercial use'], scroll: ['往下，试试看', 'Scroll to try it'],
    playgroundTitle: ['小改动，用起来不一样。', 'Small fixes. A better everyday.'],
    playgroundIntro: ['点开一个功能，试试它的工作方式。<br>这里是网页演示，不会改变你的系统设置。', 'Pick a feature and see how it works.<br>This is a web demo. It does not change your system settings.'],
    featureTabs: ['功能演示', 'Feature demos'], interactiveDemo: ['交互演示', 'WEB DEMO'],
    bracketsName: ['中文标点', 'Chinese punctuation'], bracketsShort: ['Shift + [，直接输入「', 'Shift + [ → 「'],
    imeName: ['保持拼音中文模式', 'Keep Pinyin in Chinese'], imeShort: ['切回中文布局，继续打中文', 'Back to Chinese. Still in Chinese.'],
    windowsName: ['同应用窗口切换', 'Same-app window switching'], windowsShort: ['Alt + ~，只切当前应用的窗口', 'Alt + ~. Just this app’s windows.'],
    audioName: ['通信音频跟随', 'Keep communication audio in sync'], audioShort: ['换了播放设备，语音也跟着走', 'New output? Voice audio follows.'],
    featureFootnote: ['每个功能都可以单独开关。快捷键、符号样式和同步间隔，都由你决定。', 'Toggle each feature independently. Set your own shortcut, bracket style and audio sync interval.'],
    settingsTitle: ['四个功能。<br>一个托盘图标。', 'Four fixes.<br>One tray icon.'],
    settingsDescription: ['运行 AutoHotkeyTools.ahk，就能在同一个设置窗口里管理所有功能。修改立即生效，下次打开也还在。', 'Run AutoHotkeyTools.ahk to manage every feature in one settings window. Changes apply immediately and stay saved between sessions.'],
    settingsOneTitle: ['打开即用，关上继续', 'Open settings. Close and carry on.'],
    settingsOneBody: ['单击托盘图标打开设置。关闭窗口后，脚本继续在后台运行。', 'Click the tray icon to open settings. Close the window and the scripts keep running in the background.'],
    settingsTwoTitle: ['跟着 Windows 一起启动', 'Ready when you sign in'],
    settingsTwoBody: ['在「常规」里开启登录自启。下次登录时在后台启动，不弹窗口。', 'Enable startup in General. It starts quietly at your next Windows sign-in, with no settings window.'],
    settingsDocs: ['查看完整使用说明', 'Read the full guide'], settingsWindowTitle: ['Windows 小工具', 'Windows utilities'],
    settingsPreviewNote: ['设置窗口示意 · 所有修改自动保存', 'Settings illustration · Changes save automatically'], settingsStartup: ['登录 Windows 时自动运行', 'Run at Windows sign-in'],
    settingsCaption: ['各项独立设置，按自己的习惯来。', 'Independent settings, the way you like them.'],
    architectureTitle: ['小工具，结构也简单。', 'Small scripts. Simple structure.'],
    architectureIntro: ['统一入口负责管理，四个模块各做各的。<br>想单独跑某个脚本，也可以。', 'One entry point manages four focused modules.<br>Prefer a standalone script? That works too.'],
    entryDescription: ['统一入口 · 托盘 · 设置 · 登录自启', 'Tray · Settings · Startup management'], sourceLabel: ['SOURCE / 源码', 'SOURCE / MODULE'],
    viewSource: ['在 GitHub 查看', 'View on GitHub'], localSettings: ['设置保存在本机', 'Settings stay on your PC'],
    migrationNote: ['使用统一入口前，请先退出旧的独立脚本，避免重复运行。', 'Exit standalone scripts before running the unified entry point to avoid duplicates.'],
    installTitle: ['几步，就用上了。', 'A few steps. You’re set.'],
    installIntro: ['不用编译，也不用配置一堆东西。<br>装好 AutoHotkey v2，运行脚本就行。', 'No build step. No long setup.<br>Install AutoHotkey v2, then run the scripts.'],
    stepOneTitle: ['安装 AutoHotkey v2', 'Install AutoHotkey v2'], stepOneBody: ['需要 v2，旧的 v1 版本不适用。', 'Version 2 is required. These scripts do not run on v1.'], getAhk: ['前往官网下载', 'Download from the official site'],
    stepTwoTitle: ['下载并解压整个项目', 'Download and extract the whole project'], stepTwoBody: ['保留 lib 和 icons 等文件夹，不要只下载入口脚本。', 'Keep the lib and icons folders. The entry script needs the rest of the project.'],
    stepThreeTitle: ['双击 AutoHotkeyTools.ahk', 'Double-click AutoHotkeyTools.ahk'], stepThreeBody: ['看到托盘图标就启动了。单击图标，按习惯调整设置。', 'Look for the tray icon. Click it and adjust the settings to suit you.'],
    downloadTabs: ['下载方式', 'Download method'], downloadTab: ['直接下载', 'Download ZIP'], cloneTab: ['Git 克隆', 'Git clone'],
    downloadDescription: ['完整源码，解压后即可运行。<br>脚本保持透明，想改也方便。', 'The complete source, ready to run after extraction.<br>Read it, change it, make it yours.'],
    downloadZip: ['下载项目 ZIP', 'Download project ZIP'], browseRepo: ['或先去 GitHub 看看 ↗', 'Or browse the source on GitHub ↗'],
    cloneDescription: ['进入项目文件夹，双击 AutoHotkeyTools.ahk。<br>之后可以用 git pull 更新源码。', 'Open the project folder and run AutoHotkeyTools.ahk.<br>Use git pull to get source updates later.'],
    cloneCaution: ['更新前先退出正在运行的脚本，更新后重新启动。', 'Exit running scripts before updating, then start them again.'], copy: ['复制', 'Copy'], copied: ['已复制', 'Copied'], copyFailed: ['未能复制，请手动选择命令', 'Could not copy. Please select the command manually.'],
    faqTitle: ['用之前，了解一下。', 'Before you get started.'],
    faqOneTitle: ['需要一直开着吗？<span>+</span>', 'Do the scripts need to keep running?<span>+</span>'],
    faqOneBody: ['需要。脚本在后台运行时功能才会生效。关闭设置窗口不会退出；要停止运行，右键托盘图标选择「退出」。', 'Yes. Features work while the scripts run in the background. Closing settings does not exit the app. To stop it, right-click the tray icon and choose Exit.'],
    faqTwoTitle: ['可以只用其中一个功能吗？<span>+</span>', 'Can I use just one feature?<span>+</span>'],
    faqTwoBody: ['可以。在统一设置里关闭不需要的功能，或单独运行 Brackets.ahk、KeepImeState.ahk、WindowSwitch.ahk、SyncAudioComm.ahk。不要与统一入口同时运行。', 'Yes. Turn off unneeded features in settings, or run Brackets.ahk, KeepImeState.ahk, WindowSwitch.ahk or SyncAudioComm.ahk on its own. Do not run standalone scripts alongside the unified entry point.'],
    faqThreeTitle: ['中文标点在英文模式下也生效吗？<span>+</span>', 'Do Chinese brackets apply in English mode?<span>+</span>'],
    faqThreeBody: ['默认按键盘布局判断，不按微软拼音内部的中／英模式判断。在简体中文布局下生效；切换到独立的 ENG 英文键盘布局后，仍然输入原来的花括号。', 'By default, the script checks the keyboard layout, not Microsoft Pinyin’s internal Chinese/English mode. Chinese brackets apply in the Simplified Chinese layout. A separate ENG layout restores the original braces.'],
    faqFourTitle: ['免费吗？可以商用吗？<span>+</span>', 'Is it free? What about commercial use?<span>+</span>'],
    faqFourBody: ['完全免费，采用 CC BY-NC-SA 4.0 协议，仅限非商业使用。转载请署名并以相同协议分享。如果你花钱买到了这个项目，请退款并举报卖家。', 'Completely free under CC BY-NC-SA 4.0, for noncommercial use only. Give credit and share adaptations under the same license. If someone sold you this project, request a refund and report the seller.'],
    footerTagline: ['就是几个让日常顺手一点的小脚本。', 'Just a few scripts for a smoother everyday.'], feedback: ['反馈问题 ↗', 'Report an issue ↗'], backTop: ['回到顶部 ↑', 'Back to top ↑'],
    bracketsDemoTitle: ['换一组自己喜欢的符号。', 'Your keyboard. Your punctuation.'],
    bracketsDemoDescription: ['选好样式，点下面的按键试试。也可以在输入框里按 Shift + [ 或 Shift + ]。', 'Pick a style and try the keys below, or press Shift + [ and Shift + ] in the text field.'],
    bracketStyle: ['符号样式', 'Bracket style'], chineseLayout: ['简体中文布局', 'Chinese layout'], englishLayout: ['ENG 英文布局', 'ENG layout'], demoInput: ['试输入一句话', 'Try typing a sentence'], bracketInitial: ['让输入顺手一点', 'A little less friction'],
    bracketsResult: ['中文布局使用所选符号；ENG 布局保留 { }。', 'Selected brackets in Chinese; original { } in ENG.'],
    imeDemoTitle: ['切换应用，不用再切一次中英文。', 'Switch apps. Keep your Chinese input.'],
    imeDemoDescription: ['点击不同的应用，模拟窗口切换。终端在此示例中使用 ENG 布局，其余使用微软拼音。', 'Switch between apps below. This demo uses ENG for Terminal and Microsoft Pinyin for the other apps.'],
    imeSwitch: ['保持拼音中文模式', 'Keep Pinyin in Chinese mode'], appChat: ['聊天', 'Chat'], appBrowser: ['浏览器', 'Browser'], appTerminal: ['终端', 'Terminal'],
    imeOnText: ['你好，继续刚才的话题。', '你好，继续刚才的话题。'], imeOffText: ['ni hao, ji xu gang cai de hua ti.', 'ni hao, ji xu gang cai de hua ti.'],
    imeResultOn: ['切回微软拼音时，自动保持中文模式。', 'Switching back to Microsoft Pinyin keeps Chinese mode.'], imeResultOff: ['已关闭保持功能，模拟拼音停留在英文模式。', 'Keeper off: this demo leaves Pinyin in English mode.'], imeResultTerminal: ['独立 ENG 布局保持英文，不受影响。', 'The separate ENG layout stays in English.'],
    windowsDemoTitle: ['当前应用的下一个窗口，按一下就到。', 'The next window. Of this app.'],
    windowsDemoDescription: ['点击 Alt + ~，在三个文件夹窗口间循环。实际快捷键可以在设置中修改。', 'Press the button to cycle through three folder windows. The actual shortcut is configurable in settings.'],
    folderWork: ['工作', 'Work'], folderDownloads: ['下载', 'Downloads'], folderPictures: ['图片', 'Pictures'], folderContents: ['文件夹内容', 'Folder contents'], windowsResult: ['资源管理器只在文件夹窗口间切换，跳过桌面和任务栏。', 'Explorer cycles through folder windows, skipping the desktop and taskbar.'],
    audioDemoTitle: ['播放设备切换了，通信设备也同步。', 'Switch output. Keep voice audio with it.'],
    audioDemoDescription: ['选一个播放设备，看看通信设备如何跟随。实际脚本按设置的间隔检查并同步。', 'Choose an output and watch communication audio follow. The real script syncs at your configured interval.'],
    deviceSpeakers: ['扬声器', 'Speakers'], deviceHeadphones: ['耳机', 'Headphones'], deviceMonitor: ['显示器', 'Monitor'], defaultPlayback: ['默认播放设备', 'Default playback'], defaultCommunications: ['默认通信设备', 'Default communications'], audioSwitch: ['通信音频自动跟随', 'Auto-sync communication audio'],
    audioResultOn: ['演示已同步。实际可选择 1、2、5 或 10 秒检查间隔。', 'Demo synced. The real check interval can be 1, 2, 5 or 10 seconds.'], audioResultOff: ['自动跟随已关闭。切换设备，比较两边的结果。', 'Auto-sync is off. Change output and compare the two devices.'],
    moduleBrackets: ['按键盘布局映射七组中文符号。针对 Qt 5/6 标准窗口类使用字符消息，兼容不同窗口的输入方式。', 'Maps seven Chinese bracket pairs by keyboard layout. Standard Qt 5/6 window classes receive character messages for compatible input.'],
    moduleIme: ['在简体中文键盘布局下，让微软拼音回到中文模式。支持按进程名排除应用。', 'Keeps Microsoft Pinyin in Chinese mode under the Simplified Chinese keyboard layout, with process-name exclusions.'],
    moduleWindows: ['按进程分组，在同一应用的窗口之间循环切换。资源管理器可只保留文件夹窗口，快捷键可自定义。', 'Cycles through windows belonging to the same process. Supports a custom shortcut and folder-only filtering for File Explorer.'],
    moduleAudio: ['通过 Windows Core Audio 接口，将默认通信播放设备同步到默认播放设备。检查间隔可设为 1、2、5 或 10 秒。', 'Uses Windows Core Audio to sync the default communication playback device with the default playback device, at 1, 2, 5 or 10-second intervals.']
  };
  const isEnglish = () => root.lang === 'en';
  const t = (key) => text[key][isEnglish() ? 1 : 0];
  const icon = (name) => `<svg class="icon small" aria-hidden="true"><use href="#i-${name}"/></svg>`;
  const state = { feature: 'brackets', module: 'brackets', pair: '「」', layout: 'zh', editor: null, ime: true, app: 'chat', window: 0, audio: true, output: 'speakers', communications: 'speakers' };
  const features = ['brackets', 'ime', 'windows', 'audio'];
  const files = { brackets: 'Brackets.ahk', ime: 'KeepImeState.ahk', windows: 'WindowSwitch.ahk', audio: 'SyncAudioComm.ahk' };
  const modules = { brackets: ['BracketMapper.ahk', 'moduleBrackets'], ime: ['ImeStateKeeper.ahk', 'moduleIme'], windows: ['AppWindowSwitcher.ahk', 'moduleWindows'], audio: ['AudioSynchronizer.ahk', 'moduleAudio'] };
  let copyTimer;

  function remember(key, value) {
    try { localStorage.setItem(key, value); } catch {}
  }

  function paintTheme() {
    const dark = root.dataset.theme === 'dark';
    $('#theme-button').innerHTML = `<svg class="icon" aria-hidden="true"><use href="#i-${dark ? 'sun' : 'moon'}"/></svg>`;
    $('#theme-button').setAttribute('aria-label', isEnglish() ? `Switch to ${dark ? 'light' : 'dark'} mode` : `切换到${dark ? '浅' : '深'}色模式`);
    $('meta[name="theme-color"]').content = dark ? '#101216' : '#f7f8fa';
  }

  function paintLanguage() {
    $$('[data-i18n]').forEach((element) => { element.innerHTML = t(element.dataset.i18n); });
    $$('[data-i18n-aria]').forEach((element) => { element.setAttribute('aria-label', t(element.dataset.i18nAria)); });
    $('#language-button').textContent = isEnglish() ? '中文' : 'EN';
    $('#language-button').setAttribute('aria-label', isEnglish() ? '切换到中文' : 'Switch to English');
    document.title = isEnglish() ? 'unfuck windows ux. — Windows, with a little less friction.' : 'unfuck windows ux. — 让 Windows 顺手一点。';
    const description = isEnglish() ? 'Four AutoHotkey v2 utilities for Chinese input, same-app window switching and communication audio on Windows. One tray icon. Free for noncommercial use.' : '四个 AutoHotkey v2 小工具，让 Windows 的中文输入、窗口切换和通信音频顺手一点。一个托盘图标，统一管理。免费，非商用。';
    $('meta[name="description"]').content = description;
    $('meta[property="og:title"]').content = document.title;
    $('meta[property="og:description"]').content = description;
    $('.brand').setAttribute('aria-label', isEnglish() ? 'unfuck windows ux. Home' : 'unfuck windows ux. 首页');
    $('.feature-tabs').setAttribute('aria-orientation', matchMedia('(max-width: 640px)').matches ? 'horizontal' : 'vertical');
    paintTheme();
    renderDemo();
    renderModule();
  }

  function renderDemo() {
    const content = $('#demo-content');
    const heading = (title, description) => `<h3>${t(title)}</h3><p class="demo-description">${t(description)}</p>`;
    const switchButton = (id, enabled, label) => `<button type="button" id="${id}" class="switch" role="switch" aria-checked="${enabled}" aria-label="${t(label)}"></button>`;
    $('#demo-filename').textContent = files[state.feature];
    content.classList.remove('entering');

    if (state.feature === 'brackets') {
      content.innerHTML = heading('bracketsDemoTitle', 'bracketsDemoDescription') + `<div class="demo-toolbar"><label for="pair-select" class="demo-field-label">${t('bracketStyle')}</label><div class="bracket-controls"><select id="pair-select" class="compact-select" aria-label="${t('bracketStyle')}">${['「」', '『』', '〖〗', '〔〕', '《》', '〈〉', '【】'].map((pair) => `<option value="${pair}"${pair === state.pair ? ' selected' : ''}>${pair[0]} ${pair[1]}</option>`).join('')}</select><select id="layout-select" class="compact-select" aria-label="${isEnglish() ? 'Keyboard layout' : '键盘布局'}"><option value="zh"${state.layout === 'zh' ? ' selected' : ''}>${t('chineseLayout')}</option><option value="en"${state.layout === 'en' ? ' selected' : ''}>${t('englishLayout')}</option></select></div></div><textarea id="bracket-input" class="demo-editor" aria-label="${t('demoInput')}" spellcheck="false"></textarea><div class="demo-keyboard"><button type="button" class="keyboard-button" data-bracket="0">Shift + [ <span>→ ${state.layout === 'zh' ? state.pair[0] : '{'}</span></button><button type="button" class="keyboard-button" data-bracket="1">Shift + ] <span>→ ${state.layout === 'zh' ? state.pair[1] : '}'}</span></button></div><p class="demo-result">${icon('check')}${t('bracketsResult')}</p>`;
      $('#bracket-input').value = state.editor === null ? t('bracketInitial') : state.editor;
      $('#pair-select').addEventListener('change', (event) => { state.pair = event.target.value; updateBracketKeys(); });
      $('#layout-select').addEventListener('change', (event) => { state.layout = event.target.value; updateBracketKeys(); });
      $('#bracket-input').addEventListener('input', (event) => { state.editor = event.target.value; });
      $('#bracket-input').addEventListener('keydown', (event) => {
        if (event.isComposing || !event.shiftKey || event.ctrlKey || event.altKey || event.metaKey || !['BracketLeft', 'BracketRight'].includes(event.code)) return;
        event.preventDefault();
        insertBracket(event.code === 'BracketLeft' ? 0 : 1);
      });
      $$('[data-bracket]').forEach((button) => {
        button.addEventListener('pointerdown', (event) => event.preventDefault());
        button.addEventListener('click', () => insertBracket(Number(button.dataset.bracket)));
      });
    }

    if (state.feature === 'ime') {
      content.innerHTML = heading('imeDemoTitle', 'imeDemoDescription') + `<div class="app-choices">${['chat', 'browser', 'terminal'].map((app) => `<button type="button" class="app-choice" data-app="${app}" aria-pressed="${app === state.app}">${t({ chat: 'appChat', browser: 'appBrowser', terminal: 'appTerminal' }[app])}</button>`).join('')}</div><div class="ime-preview"><div class="ime-preview-top"><span id="ime-app-name"></span><span class="ime-language" id="ime-language"></span></div><div class="ime-typed" id="ime-typed"></div></div><div class="demo-switch-row"><span>${t('imeSwitch')}</span>${switchButton('ime-switch', state.ime, 'imeSwitch')}</div><p class="demo-result" id="ime-result" role="status"></p>`;
      $$('[data-app]').forEach((button) => button.addEventListener('click', () => { state.app = button.dataset.app; updateIme(); }));
      $('#ime-switch').addEventListener('click', (event) => { state.ime = !state.ime; event.currentTarget.setAttribute('aria-checked', String(state.ime)); updateIme(); });
      updateIme();
    }

    if (state.feature === 'windows') {
      content.innerHTML = heading('windowsDemoTitle', 'windowsDemoDescription') + `<div class="mini-windows">${['folderWork', 'folderDownloads', 'folderPictures'].map((folder, i) => `<div class="mini-window${i === state.window ? ' active' : ''}"><div class="mini-window-title">${icon('window')}<span>${t(folder)}</span></div><div class="mini-window-body"><span class="folder-icon"></span><br>${t('folderContents')}</div></div>`).join('')}</div><div class="window-demo-bottom"><button type="button" class="keyboard-button" id="next-window">Alt + ~ <span>↻</span></button><span class="window-counter" id="window-counter" role="status">0${state.window + 1} / 03</span></div><p class="demo-result">${icon('check')}${t('windowsResult')}</p>`;
      $('#next-window').addEventListener('click', () => {
        state.window = (state.window + 1) % 3;
        $$('.mini-window').forEach((element, i) => element.classList.toggle('active', i === state.window));
        $('#window-counter').textContent = `0${state.window + 1} / 03`;
      });
    }

    if (state.feature === 'audio') {
      content.innerHTML = heading('audioDemoTitle', 'audioDemoDescription') + `<div class="audio-choices">${['speakers', 'headphones', 'monitor'].map((device) => `<button type="button" class="app-choice" data-device="${device}" aria-pressed="${device === state.output}">${t(deviceKey(device))}</button>`).join('')}</div><div class="audio-routing" role="status"><div class="audio-endpoint"><span>${t('defaultPlayback')}</span><strong id="playback-device"></strong></div><span class="audio-routing-arrow" aria-hidden="true">→</span><div class="audio-endpoint"><span>${t('defaultCommunications')}</span><strong id="communications-device"></strong></div></div><div class="demo-switch-row"><span>${t('audioSwitch')}</span>${switchButton('audio-switch', state.audio, 'audioSwitch')}</div><p class="demo-result" id="audio-result"></p>`;
      $$('[data-device]').forEach((button) => button.addEventListener('click', () => {
        state.output = button.dataset.device;
        if (state.audio) state.communications = state.output;
        updateAudio();
      }));
      $('#audio-switch').addEventListener('click', (event) => {
        state.audio = !state.audio;
        event.currentTarget.setAttribute('aria-checked', String(state.audio));
        if (state.audio) state.communications = state.output;
        updateAudio();
      });
      updateAudio();
    }
    requestAnimationFrame(() => content.classList.add('entering'));
  }

  function updateBracketKeys() {
    $$('[data-bracket]').forEach((button, i) => { $('span', button).textContent = `→ ${state.layout === 'zh' ? state.pair[i] : '{}'[i]}`; });
  }

  function insertBracket(index) {
    const field = $('#bracket-input');
    const character = state.layout === 'zh' ? state.pair[index] : '{}'[index];
    const start = field.selectionStart;
    const end = field.selectionEnd;
    field.setRangeText(character, start, end, 'end');
    state.editor = field.value;
    field.focus({ preventScroll: true });
  }

  function updateIme() {
    $$('[data-app]').forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.app === state.app)));
    $('#ime-app-name').textContent = t({ chat: 'appChat', browser: 'appBrowser', terminal: 'appTerminal' }[state.app]);
    const terminal = state.app === 'terminal';
    $('#ime-language').textContent = terminal ? 'ENG' : isEnglish() ? `Microsoft Pinyin · ${state.ime ? '中' : 'EN'}` : state.ime ? '微软拼音 · 中' : '微软拼音 · 英';
    $('#ime-typed').textContent = terminal ? '> npm run dev' : t(state.ime ? 'imeOnText' : 'imeOffText');
    $('#ime-result').textContent = t(terminal ? 'imeResultTerminal' : state.ime ? 'imeResultOn' : 'imeResultOff');
  }

  function deviceKey(device) {
    return { speakers: 'deviceSpeakers', headphones: 'deviceHeadphones', monitor: 'deviceMonitor' }[device];
  }

  function updateAudio() {
    $$('[data-device]').forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.device === state.output)));
    $('#playback-device').textContent = t(deviceKey(state.output));
    $('#communications-device').textContent = t(deviceKey(state.communications));
    $('#audio-result').textContent = t(state.audio ? 'audioResultOn' : 'audioResultOff');
  }

  function selectFeature(feature, focus = false) {
    if (!features.includes(feature)) return;
    state.feature = feature;
    $$('[data-feature]').forEach((button) => {
      const selected = button.dataset.feature === feature;
      button.setAttribute('aria-selected', String(selected));
      button.tabIndex = selected ? 0 : -1;
      if (selected && focus) button.focus();
    });
    $('#demo-panel').setAttribute('aria-labelledby', `tab-${feature}`);
    renderDemo();
  }

  function renderModule() {
    const [file, description] = modules[state.module];
    $('#module-title').textContent = file;
    $('#module-description').textContent = t(description);
    $('#module-source').href = `${repo}/blob/main/lib/${file}`;
    $$('[data-module]').forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.module === state.module)));
  }

  function selectInstall(id, focus = false) {
    $$('[data-install]').forEach((button) => {
      const selected = button.dataset.install === id;
      button.setAttribute('aria-selected', String(selected));
      button.tabIndex = selected ? 0 : -1;
      $(`#${button.getAttribute('aria-controls')}`).hidden = !selected;
      if (selected && focus) button.focus();
    });
  }

  function tabKeys(event, items, current, select) {
    const moves = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 };
    if (event.key === 'Home') { event.preventDefault(); select(items[0], true); }
    else if (event.key === 'End') { event.preventDefault(); select(items.at(-1), true); }
    else if (moves[event.key]) { event.preventDefault(); select(items[(items.indexOf(current) + moves[event.key] + items.length) % items.length], true); }
  }

  function closeMenu() {
    $('#navigation').classList.remove('open');
    $('#menu-button').setAttribute('aria-expanded', 'false');
    $('#menu-button use').setAttribute('href', '#i-menu');
    $('#menu-button').setAttribute('aria-label', t('menu'));
  }

  $('#theme-button').addEventListener('click', () => {
    root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
    remember('uwux-theme', root.dataset.theme);
    paintTheme();
  });
  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
    try { if (localStorage.getItem('uwux-theme')) return; } catch {}
    root.dataset.theme = event.matches ? 'dark' : 'light';
    paintTheme();
  });
  $('#language-button').addEventListener('click', () => {
    root.lang = isEnglish() ? 'zh-CN' : 'en';
    remember('uwux-language', root.lang);
    clearTimeout(copyTimer);
    paintLanguage();
    closeMenu();
  });
  $$('[data-feature]').forEach((button) => button.addEventListener('click', () => selectFeature(button.dataset.feature)));
  $('.feature-tabs').addEventListener('keydown', (event) => tabKeys(event, features, state.feature, selectFeature));
  $$('[data-module]').forEach((button) => button.addEventListener('click', () => { state.module = button.dataset.module; renderModule(); }));
  $$('[data-install]').forEach((button) => button.addEventListener('click', () => selectInstall(button.dataset.install)));
  $('.install-tabs').addEventListener('keydown', (event) => tabKeys(event, ['download', 'clone'], $('[data-install][aria-selected="true"]').dataset.install, selectInstall));
  $('#copy-button').addEventListener('click', async () => {
    const button = $('#copy-button');
    const value = $('#clone-command').textContent;
    clearTimeout(copyTimer);
    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(value);
      } else {
        const field = document.createElement('textarea');
        field.value = value;
        field.className = 'sr-only';
        document.body.append(field);
        try {
          field.select();
          if (!document.execCommand('copy')) throw new Error('Copy unavailable');
        } finally { field.remove(); button.focus({ preventScroll: true }); }
      }
      button.innerHTML = `${icon('check')}<span>${t('copied')}</span>`;
      $('#announcement').textContent = t('copied');
      copyTimer = setTimeout(() => { button.innerHTML = `${icon('copy')}<span>${t('copy')}</span>`; }, 2200);
    } catch {
      $('#announcement').textContent = t('copyFailed');
      button.innerHTML = `<span>${isEnglish() ? 'Select command' : '请手动复制'}</span>`;
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents($('#clone-command'));
      selection.removeAllRanges();
      selection.addRange(range);
    }
  });
  $('#menu-button').addEventListener('click', () => {
    const open = $('#menu-button').getAttribute('aria-expanded') !== 'true';
    $('#navigation').classList.toggle('open', open);
    $('#menu-button').setAttribute('aria-expanded', String(open));
    $('#menu-button use').setAttribute('href', open ? '#i-close' : '#i-menu');
    $('#menu-button').setAttribute('aria-label', open ? isEnglish() ? 'Close navigation' : '关闭导航' : t('menu'));
  });
  $$('#navigation a').forEach((link) => link.addEventListener('click', closeMenu));
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && $('#menu-button').getAttribute('aria-expanded') === 'true') { closeMenu(); $('#menu-button').focus(); }
  });
  document.addEventListener('click', (event) => { if (!$('.site-header').contains(event.target)) closeMenu(); });
  matchMedia('(max-width: 640px)').addEventListener('change', (event) => {
    $('.feature-tabs').setAttribute('aria-orientation', event.matches ? 'horizontal' : 'vertical');
    closeMenu();
  });
  paintLanguage();
  if ('IntersectionObserver' in window) {
    const reduced = matchMedia('(prefers-reduced-motion: reduce)');
    const revealObserver = new IntersectionObserver((entries) => entries.forEach((entry) => {
      if (entry.isIntersecting) { entry.target.classList.remove('is-pending'); revealObserver.unobserve(entry.target); }
    }), { threshold: .06 });
    if (!reduced.matches) $$('.reveal').forEach((element) => { element.classList.add('is-pending'); revealObserver.observe(element); });
    reduced.addEventListener('change', (event) => {
      if (event.matches) { $$('.is-pending').forEach((element) => element.classList.remove('is-pending')); revealObserver.disconnect(); }
    });
    const navObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const link = $(`#navigation a[href="#${entry.target.id}"]`);
        if (entry.isIntersecting) { $$('#navigation a').forEach((item) => item.removeAttribute('aria-current')); link?.setAttribute('aria-current', 'location'); }
        else link?.removeAttribute('aria-current');
      });
    }, { rootMargin: '-20% 0px -55% 0px' });
    ['playground', 'arch-sec', 'install'].forEach((id) => navObserver.observe($(`#${id}`)));
  }
})();
