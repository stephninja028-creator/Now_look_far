# Now Look Far

Now Look Far（当前产品名：EyeBreak）是一款本地运行的 macOS 护眼助手。
它根据键盘和鼠标的活跃时间判断持续工作，在 45 分钟后先给出轻量提醒；
只有用户选择休息时，才进入两分钟的沉浸式远眺画面。

它不记录按键内容、访问的网站、打开的文件、屏幕内容或应用名称。

## 让你的 Agent 安装

复制下面整段文字，发送给你信任的本地 Agent：

> 请阅读 Now Look Far 官方 Agent 安装协议，并严格按照协议完成安装：
> https://github.com/stephninja028-creator/Now_look_far/blob/main/AGENT_INSTALL.md
>
> 安装前请向我说明将要下载和修改的内容；只允许从该仓库声明的 GitHub
> Release 下载；必须验证 SHA-256、Apple Developer ID 签名和公证状态；
> 不要使用 sudo；完成后运行健康检查，并用中文告诉我安装结果和当前设置。

用户不需要打开终端。Agent 会负责阅读协议、请求必要授权、安装、启动和检查。

> 当前公开版本 `v0.3.1` 已完成 Developer ID 签名、Apple 公证和远端哈希
> 验证，可以按照上面的 Agent 安装协议安全安装。

## 使用方式

安装完成后，Now Look Far 会在菜单栏运行：

- 默认累计活跃工作 45 分钟后提醒。
- 离开电脑 3 分钟后暂停累计，但不清零。
- 可以跳过本次、今天不再提醒或进入两分钟休息。
- 进入休息后按 `Esc` 随时返回。

如果 Agent 支持本地命令，可以让它执行：

```text
~/Library/Application Support/NowLookFar/bin/now-look-far status
```

也可以直接对已安装 EyeBreak Skill 的 Codex 说：

- “暂停护眼两小时”
- “恢复护眼提醒”
- “护眼改成 50 分钟”
- “查看护眼状态”

## 隐私与权限

- 所有计时和设置都保存在本机。
- 只读取“距离上次键盘、鼠标或滚轮操作多久”。
- 不需要管理员权限。
- 不安装系统扩展、浏览器扩展或网络服务。
- App 安装在当前用户的 `~/Applications`。
- 登录启动项安装在当前用户的 `~/Library/LaunchAgents`。

## 手动管理

Agent 安装协议包含安装、更新、健康检查和可恢复卸载步骤：

- [Agent 安装协议](AGENT_INSTALL.md)
- [安全模型](SECURITY.md)
- [健康检查脚本](scripts/health-check.sh)
- [卸载脚本](scripts/uninstall.sh)

## 系统要求

- macOS 14 或更高版本
- Apple Silicon 或 Intel Mac（最终 Release 将使用 Universal 构建）

## 发布状态

本仓库只公开分发协议、安装脚本、Agent Skill 和经过验证的 Release。
Swift App 源码不在此公开仓库中。
