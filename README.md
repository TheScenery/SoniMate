# SoniMate

macOS 状态栏应用，实时监听麦克风输入音量，通过动态波形图标提示当前说话音量是否处于礼貌的社交范围，避免打扰周围同事。

## 功能

- 状态栏实时显示麦克风音量等级
- 三级提示：安静（绿色）→ 适中（黄色）→ 过响（红色）
- 右键菜单快速退出
- 无 Dock 图标，后台静默运行

## 系统要求

- macOS 13+

## 使用

```bash
make build   # 编译
make bundle  # 生成 .app
make run     # 编译并启动
make clean   # 清理构建产物
```

首次启动会弹出麦克风权限请求。

## 技术栈

Swift + AppKit + AVFoundation (AVAudioEngine) + Core Graphics

## 许可证

MIT
