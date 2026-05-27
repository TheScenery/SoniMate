# MicMonitor — macOS 麦克风社交音量状态栏应用

## 概述

macOS 状态栏应用，实时监听麦克风输入音量，通过动态波形图标提示当前说话音量是否处于礼貌的社交范围，避免打扰周围同事。

## 技术栈

- 语言：Swift
- 框架：AppKit + AVFoundation (AVAudioEngine)
- 最低部署：macOS 13
- 构建：Xcode 原生项目

## 功能需求

1. 应用启动后在状态栏（menu bar）显示一个波形图标
2. 实时监听麦克风输入音量，每 100ms 更新一次状态
3. 三个音量等级：
   - **安静（quiet）**：音量过低，绿色波形图标，提示可适当提高音量
   - **适中（moderate）**：社交适宜音量，黄色波形图标，提示当前音量合适
   - **过响（loud）**：音量过高，红色波形图标，提示需要降低音量
4. 右键菜单提供「退出」选项
5. 首次启动时请求麦克风权限

## 架构设计

### 项目结构

```
MicMonitor/
├── AppDelegate.swift          # 应用入口，初始化各模块
├── StatusBarController.swift  # NSStatusItem 管理，图标更新
├── AudioMonitor.swift         # AVAudioEngine 音频捕获 + 音量分析
├── VolumeLevel.swift          # 音量等级枚举和阈值定义
├── IconGenerator.swift        # Core Graphics 按需绘制波形图标
├── Assets.xcassets/           # 应用图标
├── Info.plist                 # NSMicrophoneUsageDescription
└── MicMonitor.xcodeproj/      # Xcode 项目文件
```

### 模块职责

| 模块 | 职责 |
|------|------|
| `AppDelegate` | 状态栏应用入口，负责生命周期管理，初始化 `StatusBarController` 和 `AudioMonitor` |
| `StatusBarController` | 创建 `NSStatusItem`，接收音量等级回调并更新 `button.image`，提供右键退出菜单 |
| `AudioMonitor` | 管理 `AVAudioEngine`，在 `inputNode` 上安装 tap，计算 RMS 并映射为音量等级，通过闭包通知外部 |
| `VolumeLevel` | 定义 `VolumeLevel` 枚举（quiet / moderate / loud），包含阈值判定逻辑和关联颜色 |
| `IconGenerator` | 使用 `Core Graphics` 按需绘制三态波形 `NSImage`，避免维护外部资源文件 |

### 数据流

```
麦克风 → AVAudioEngine.inputNode → tap 回调获取 AudioBuffer
    → AudioMonitor 计算 RMS → 转换为 dB → 映射到 0.0~1.0
    → VolumeLevel 判定等级 (quiet < 0.3 / moderate 0.3~0.7 / loud > 0.7)
    → StatusBarController 调用 IconGenerator 绘制对应图标
    → 更新 NSStatusItem.button.image
```

### 音量计算

- 从 `AVAudioPCMBuffer` 读取 float 类型音频样本
- 计算 RMS（Root Mean Square）：`sqrt(mean(samples^2))`
- 转换为 dB：`20 * log10(rms)`
- 归一化到 0.0~1.0（假设典型范围 -60dB ~ 0dB）
- 阈值：quiet < 0.3, moderate 0.3~0.7, loud > 0.7

### 图标设计（方案 A — 波形）

- 使用 Core Graphics 绘制，确保像素级清晰
- 安静：小幅低波形 + 绿色色调
- 适中：中等幅度波形 + 黄色色调
- 过响：大幅高波形 + 红色色调
- 图标尺寸：20x20 pt（标准状态栏图标尺寸）

## 边界情况处理

- **无麦克风权限**：显示灰色禁用图标，应用保持运行但不监听
- **无麦克风硬件**：检测并显示「无输入设备」状态
- **应用启动/退出**：正确清理 `AVAudioEngine` 资源，避免音频残留
- **后台运行**：作为 `LSUIElement` 运行，无 Dock 图标

## 测试策略

- 单元测试 `VolumeLevel` 阈值逻辑
- 单元测试 `AudioMonitor` 的 RMS 计算
- 手动测试不同音量下的图标切换
- 权限提示流程测试
