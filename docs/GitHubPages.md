# GitHub Pages

项目介绍页源码位于 `site/`，使用原生 HTML、CSS 和 JavaScript，无需安装依赖或构建。演示仅在网页中模拟，不操作 Windows 设置。

## 本地预览

在仓库根目录运行：

```powershell
python -m http.server 4173 --bind 127.0.0.1 --directory site
```

打开 http://127.0.0.1:4173/ 。用 `Ctrl + C` 停止预览。

## 发布

1. 在 GitHub 仓库的 **Settings → Pages → Build and deployment** 中，将 **Source** 设为 **GitHub Actions**。
2. 将页面和 `.github/workflows/pages.yml` 提交并推送到 `main`。
3. 工作流会自动发布 `site/`。也可以在 **Actions → Deploy GitHub Pages → Run workflow** 手动触发。

预期地址：https://mitsukijoe.github.io/unfuck-windows-ux/

工作流只上传 `site/`，不会公开仓库里的其他本地文件。资源使用相对路径，兼容 GitHub Pages 的项目子路径。若部署到其他仓库或自定义域名，需要修改 `site/index.html` 的 canonical、Open Graph URL，以及页面中的 GitHub 链接。

## 页面维护

- `site/index.html`：页面内容与结构。
- `site/styles.css`：布局、响应式、明暗主题、减少动态效果适配。
- `site/app.js`：中英文本、交互演示、主题切换和复制命令。
- `site/assets/logo.svg`：沿用 `assets/logo/corner.svg` 的项目图标；更新图标时同步替换。

中英切换和手动主题选择保存在访问者的浏览器中。默认中文，主题跟随系统。没有统计服务、第三方字体或外部脚本。

发布配置参考 [GitHub Pages 官方文档](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)。
