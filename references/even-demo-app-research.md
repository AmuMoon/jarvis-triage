# Even Demo App 代码研究笔记

研究日期: 2026-02-12
项目: https://github.com/even-realities/EvenDemoApp

## 项目结构

这是一个 **Flutter** 项目，支持 iOS/Android/macOS/Windows/Linux/Web 全平台。

```
EvenDemoApp/
├── ios/Runner/
│   ├── BluetoothManager.swift      # 核心蓝牙管理
│   ├── ServiceIdentifiers.swift    # UUID 定义
│   ├── SpeechStreamRecognizer.swift # 语音识别
│   └── lc3/                        # LC3 音频编解码
├── android/                        # Android 实现
├── lib/                           # Flutter Dart 代码
└── assets/                        # 图片资源
```

## 核心发现

### 1. 双蓝牙连接

G2 使用 **双 BLE 连接**，左右眼镜腿各一个：

```swift
var leftPeripheral:CBPeripheral?
var rightPeripheral:CBPeripheral?

// 服务 UUID
UARTServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
UARTRXCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
UARTTXCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
```

**关键**：数据先发送到左眼，收到确认后再发送到右眼。

### 2. 文本发送协议

根据 README，文本发送分为 3 步：

#### 步骤 1: 分行
- 显示宽度: **488 像素**
- 字体大小: **21px**（可自定义）
- 每屏行数: **5 行**

**计算**:
- 中文: 488/21 ≈ **23 字/行**
- 英文: 488/10 ≈ **48 字符/行**

#### 步骤 2: 分包
- 每屏 5 行分为 2 个数据包
- 第 1 包: 前 3 行
- 第 2 包: 后 2 行
- 每包大小受 BLE 限制

#### 步骤 3: 发送
- 使用 **0x4E 命令** 发送文本
- 格式: `[0x4E, seq, total_package_num, current_package_num, newscreen]`
- 支持自动翻页和手动翻页模式

### 3. Even AI 流程

```
用户长按眼镜 TouchBar
    ↓
眼镜发送 [0xF5, 0x17] → App
    ↓
App 发送 [0x0E, 0x01] → 开启右眼麦克风
    ↓
眼镜发送 LC3 音频流 [0xF1, seq, data]
    ↓
App 解码 LC3 → PCM → 语音识别
    ↓
App 发送结果 [0x4E, ...] → 眼镜显示
```

**关键点**:
- 音频格式: **LC3**（Low Complexity Communication Codec）
- 最大录音: **30 秒**
- 实时流传输

### 4. TouchBar 事件

| 操作 | 命令 | 功能 |
|------|------|------|
| 单击 | 0xF5 0x01 | 翻页（左=上页，右=下页） |
| 双击 | 0xF5 0x00 | 关闭/返回主屏 |
| 三连击 | 0xF5 0x04/05 | 静音切换 |
| 长按 | 0xF5 0x17 | 激活 Even AI |

### 5. Even R1 戒指

Demo App 中没有直接提到戒指的蓝牙协议，推测：
- 戒指可能通过 G2 中转（不直接连手机）
- 或者戒指直接作为蓝牙 HID 设备
- 需要进一步研究或等 Even Hub SDK

## Jarvis Triage 集成要点

### 需要开发的组件

1. **iOS/Android App**
   - 蓝牙连接管理（参考 BluetoothManager.swift）
   - LC3 解码（使用项目中的 lc3 库）
   - 语音识别（可以用 Even AI 或自定义）
   - HUD 内容生成

2. **OpenClaw 端**
   - HTTP API 接收语音命令
   - Jarvis Triage 处理
   - 返回 5 行 HUD 格式

3. **通信协议**
   - App ↔ OpenClaw: HTTP/WebSocket
   - App ↔ G2: BLE 协议（参考本研究）

### 开发优先级

**Phase 1: 原型验证**（等 Even Hub）
- 使用 Even Hub SDK（如果提供）
- 避免处理底层蓝牙

**Phase 2: 深度集成**（如果需要）
- Fork EvenDemoApp
- 添加 OpenClaw API 调用
- 自定义 HUD 生成

**Phase 3: 优化**
- 优化语音命令识别
- 添加 Even R1 戒指支持
- 性能优化

## 关键代码片段

### 发送数据到眼镜
```swift
func writeData(writeData: Data, lr: String? = nil) {
    if lr == "L" {
        self.leftPeripheral?.writeValue(writeData, for: self.leftWChar!, type: .withoutResponse)
    } else if lr == "R" {
        self.rightPeripheral?.writeValue(writeData, for: self.rightWChar!, type: .withoutResponse)
    }
}
```

### 发送 AI 结果
```swift
// 命令: 0x4E
// 参数: seq, total_package_num, current_package_num, newscreen
let data: [UInt8] = [0x4E, seq, total, current, newscreen]
writeData(writeData: Data(data), lr: "L") // 先左眼
// 等确认后再发右眼
```

### 接收音频数据
```swift
case .BLE_REQ_TRANSFER_MIC_DATA:
    let effectiveData = data.subdata(in: 2..<data.count)
    let pcmConverter = PcmConverter()
    var pcmData = pcmConverter.decode(effectiveData)
    // pcmData 是解码后的音频
```

## 参考文件

- `BluetoothManager.swift` - 蓝牙连接核心
- `ServiceIdentifiers.swift` - UUID 定义
- `SpeechStreamRecognizer.swift` - 语音识别
- `lc3/` - LC3 编解码库

## 下一步行动

1. **等待 Even Hub 申请结果**
   - 如果批准：使用官方 SDK（更简单）
   - 如果未批准：Fork Demo App 自己开发

2. **准备开发环境**
   - 安装 Flutter
   - 配置 iOS/Android 开发环境
   - 准备测试设备（G2 + R1）

3. **设计 API 接口**
   - 定义 OpenClaw ↔ App 的通信协议
   - 设计 HUD 内容格式

4. **原型开发**
   - 先实现基础文本显示
   - 再添加语音命令
   - 最后优化交互

## 相关文档

- [G2 适配指南](./g2-compatibility.md)
- [Even Demo App](https://github.com/even-realities/EvenDemoApp)
- [Even Hub](https://evenhub.evenrealities.com/)
