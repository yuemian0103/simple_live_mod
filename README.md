# Simple Live（修改版）

> 基于 [xiaoyaocz/dart_simple_live](https://github.com/xiaoyaocz/dart_simple_live) 修改的聚合直播应用，遵循原项目 **GPL-3.0** 协议开源。
> 感谢原作者 [@xiaoyaocz](https://github.com/xiaoyaocz) 及所有上游贡献者的付出，请多多给原项目点 Star。

**原项目**：https://github.com/xiaoyaocz/dart_simple_live

---

## ⚠️ 免责声明

- 本项目仅供学习交流使用，不提供任何技术支持与保障
- 直播源均来自各官方平台的公开接口，如有侵权请联系删除
- 请支持正版：有能力请下载各平台官方 App 并订阅主播

## 本修改版更新的内容（基于上游 v1.11.4 代码，版本号顺延为 v1.15.0）

### 直播播放体验

1. **断流自动重连**：直播中断后先切换线路快速重试，无效则重新请求房间信息拉取全新流地址（直播平台流地址会定期更换，旧地址重试无效），快速 3 轮 + 慢速 30 轮（每 20 秒）持续等待网络恢复，网络恢复后自动续播
2. **只有平台接口确认主播下播才显示"未开播"**（含二次确认，防接口误报），彻底解决"看着看着掉到未直播"的问题
3. **播放看门狗**：播放器停滞且无事件时每 10 秒主动检查重连
4. **防闪退**：限制播放器解封装缓存上限（96MiB，低配 40MiB）+ 硬解异常自动回退软解 + 丢帧策略（参考 pure_live），解决长时间观看内存增长导致的 OOM 闪退

### 平台风控修复

5. **抖音 444/软拒绝修复**：
   - 通过字节官方 `ttwid.bytedance.com` 注册接口运行时申请新 ttwid（原内置 2023 年 ttwid 已被风控失效）
   - 移植 pure_live 的纯 Dart abogus 签名（不再依赖 quickjs）+ Chrome 134 UA + 对齐参数（修复 Request params error）
   - 抖音弹幕 WebSocket 的软拒绝识别与自动重试
6. **B站分区 -352 修复**：buvid 激活 + 直播首页完整 cookie 会话 + wbi 签名 + 自动重试，分区接口被限流时给出友好提示而非崩溃

### 功能新增

7. **全平台醒目留言（SC）**：SC 标签页不再仅限哔哩哔哩，斗鱼（醒目留言+语音醒目留言）、虎牙（官方面板接口）、抖音（背景气泡识别）的醒目留言均以统一卡片展示
8. **虎牙/抖音开播时长**：虎牙从房间数据提取 `iStartTime`，显示真实开播时长（抖音 web 接口不提供开播时间，显示 00:00:00）
9. **关注页改版**：平台分类改为顶部 Tab（默认不选中=全部平台），SC/状态/标签筛选分层，去重冗余项

### 其他

- B站登录 cookie 注入修复（登录后风控放行 + 高画质）
- 关注数据迁移：跨签名升级需在旧版导出 JSON 后在新版导入（同签名版本间覆盖安装数据自动继承）

## 与上游的主要差异文件

```
simple_live_core/lib/src/douyin_site.dart      # 抖音风控修复
simple_live_core/lib/src/bilibili_site.dart    # B站-352修复
simple_live_core/lib/src/danmaku/douyu_danmaku.dart   # 斗鱼SC
simple_live_core/lib/src/danmaku/douyin_danmaku.dart  # 抖音SC+时长
simple_live_core/lib/src/danmaku/huya_danmaku.dart    # 虎牙SC
simple_live_core/lib/src/model/tars/huya_sc.dart      # 虎牙SC结构体（新增）
simple_live_core/lib/src/scripts/douyin_abogus.dart   # 纯Dart abogus签名（新增）
simple_live_core/lib/src/common/http_client.dart      # get/post方法
simple_live_app/lib/modules/live_room/...      # 断流重连+SC+时长+防闪退
simple_live_app/lib/modules/follow_user/...    # 关注页改版
```

## 下载

前往 [Releases](https://github.com/yuemian0103/simple_live_mod/releases) 下载最新 APK。

## 构建

```bash
flutter build apk --release
```

- 需自行配置 `android/key.properties` 与签名文件（参考 Flutter 官方文档）
- Windows 桌面版需安装 Visual Studio C++ 工具链后 `flutter build windows --release`

## 原项目介绍

聚合直播：哔哩哔哩、斗鱼、虎牙、抖音、网易CC、艺气山……支持弹幕、多线路、跟随系统主题等，详见 [原项目 README](https://github.com/xiaoyaocz/dart_simple_live)。

## License

[GPL-3.0](LICENSE) — 与原项目一致。任何基于本项目的二次修改同样需要遵循 GPL-3.0 开源。
