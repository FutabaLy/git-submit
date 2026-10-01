# DeepSeek + Codex 小鲸鱼

点击桌面小鲸鱼，同时查看 **DeepSeek 账户余额**、**Codex 5 小时剩余百分比**和 **Codex 7 天剩余百分比**。

基于 [上游 For-Codex 分支](https://github.com/MeteorNOX/DeepSeek-Balance-Whale-Widget/tree/For-Codex) 的独立修改版，不是上游官方发行。版本：`0.3.0+codex.dual.20261001`。来源见 [FORK-NOTES](docs/FORK-NOTES.md)。

## 功能

- 点击角色或打开概览，同时查看三项数据。
- 原有 API 与新增 DeepSeek 来源可切换，配置、余额缓存及账本分别保存。
- 在挂件内输入 DeepSeek API Key，通过 Electron safeStorage 加密后保存；不修改 Codex 的模型或登录配置。
- Codex 百分比取自官方额度快照，缺少或过期时明确提示，不用 token 数估算百分比。
- 保留上游拖拽、角色、声音、窗口跟随、桌面模式及本地工坊。

## 安装（Windows）

需要 **Node.js 24+（含 npm）** 和支持 `plugin add` 的 Codex 桌面端。首次安装联网下载 Electron 44.3.0。

1. 下载 ZIP，完整解压到固定目录。
2. 双击 `安装插件.cmd`，或执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-package.ps1 -CheckOnly
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-package.ps1
```

3. 打开 Codex；新建聊天以加载插件工具。

计划任务注册提示 `Access is denied` 时，可改用当前用户启动文件夹：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-package.ps1 -StartupFolder
```

已有小鲸鱼计划任务时，先运行旧安装目录中的 `停用自动跟随.cmd` 再选择此方式。安装器备份原有数据及启动配置。修改版沿用相同插件 ID，会替换上游版；不要同时安装两份。

## 配置与使用

1. 小鲸鱼菜单 → **概览**，选择 **API 余额**。
2. 点击 **配置 DeepSeek 密钥**，输入自己的 API Key 并保存。
3. 点击角色查看合并卡片，点击刷新更新数据。
4. 概览的“余额来源”可切换原有 API；合并卡片始终单独查询 DeepSeek。

DeepSeek 使用[官方余额接口](https://api-docs.deepseek.com/zh-cn/api/get-user-balance/)，不调用模型。Codex 额度需要可识别的 ChatGPT 订阅登录以及可用官方快照；API 登录或没有快照时显示暂无额度。

## 隐私与数据

数据默认在 `%USERPROFILE%\.codex\whale-widget`，可由 `CODEX_HOME` 或 `WHALE_HOME` 指定。DeepSeek 数据位于其 `sources/deepseek/` 子目录，`credential.json` 保存加密密钥。不要将用户数据目录、日志、账本、`runtime.json` 或凭据文件上传 GitHub。

## 开发与验证

```sh
npm test
node scripts/check-package.mjs
```

解析器与资源已包含，运行源码测试无需安装 Electron。CI 在 Windows 上运行；新增测试覆盖来源隔离、切换持久化、加密、合并接口及原配置保留。Windows 本机已验证三项真实数据读取。macOS 脚本保留自上游，本次修改未经过 macOS 实机验证。

## 停用与回滚

运行 `停用自动跟随.cmd` 停用自启并保留数据。运行 `回滚本次安装.cmd` 按有效的安装回执回滚。升级前保留备份。

## 上传与许可

上传步骤见 [UPLOAD-TO-GITHUB.md](UPLOAD-TO-GITHUB.md)。只上传本项目目录，不上传聊天工作目录。

保留 [MIT 许可证](LICENSE) 与 [第三方声明](THIRD_PARTY_NOTICES.md)。上游作者 MeteorNOX，Codex 适配维护者 Yang-huai406，macOS 贡献者 1llysviel。媒体资源沿用上游分发条款，不重新宣称原创。历史上游文档中的验证结论仅代表相应上游版本。
