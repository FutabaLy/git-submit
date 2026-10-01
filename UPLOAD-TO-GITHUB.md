# 上传 GitHub

建议仓库名：`DeepSeek-Codex-Whale`。

1. 在 GitHub 新建空仓库，不勾选自动创建 README、许可证或 .gitignore。
2. 在此项目目录打开终端，将 YOUR_NAME 换成自己的用户名：

```sh
git init -b main
git add .
git diff --cached --stat
git commit -m "Add DeepSeek balance and Codex quota companion"
git remote add origin https://github.com/YOUR_NAME/DeepSeek-Codex-Whale.git
git push -u origin main
```

使用自己的 Git 提交信息。确保 `.codex-plugin`、`.mcp.json`、`.github` 等隐藏文件一起提交。仅上传本目录，不上传整个聊天工作目录或本机插件数据。

发布下载包时，在 Releases 新建 `v0.3.0-dual.1`，参考 `RELEASE_NOTES.md` 填说明，再附上源码 ZIP。此包不含 Electron 离线运行时。

发布前运行 `npm test` 和 `node scripts/check-package.mjs`。保留上游链接、来源记录、LICENSE 和 THIRD_PARTY_NOTICES。不要提交 `.env`、`auth.json`、`credential.json`、账本或运行日志。

如果希望 GitHub 显示 Fork 关系，先在 GitHub Fork 上游，检出其 For-Codex 分支，再复制本包内容并审阅差异后提交；保留该仓库原本的 `.git`。普通新建仓库不会建立 Fork 关系。
