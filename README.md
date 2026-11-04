# 土豆兄弟：可逐项开关的自动战斗辅助 / Tong AutoDodge

这是用于 **《土豆兄弟》（Brotato，Blobfish 开发）单人游戏**的 GDScript Mod，当前版本 **0.2.0**，ModLoader 标识为 **`Tong-AutoDodge`**。

它帮助角色自动走位、躲避敌人和弹幕，并允许你分别决定是否交给机器人购买装备、选择升级、处理宝箱和进入下一波。默认预设是 **“手选成长”**：自动走位，其余成长选择保留给玩家。它不会像上游原版入口那样要求先点击难度页机器人按钮，也不会由本入口强制改成 Danger 6；进入单人对局后按当前开关运行。

本项目基于 Black Triangle / HelpFreedom 的 [Full Auto Bot](https://github.com/HelpFreedom/brotato-full-autobot) 修改，继承其角色策略、战斗评分与走位计算。Tong 的修改集中在独立自动化开关、预设、安全控制、暂停菜单设置、挑战 HUD 和 ModLoader 接线；**并非所有代码都由 Tong 从零编写**。原署名和 GNU GPL-3.0 许可随仓库保留，详见 [AUTHORS](AUTHORS)、[CONTRIBUTORS.md](CONTRIBUTORS.md) 和 [LICENSE](LICENSE)。

## 适用环境

| 项目 | 当前源码声明 |
| --- | --- |
| 游戏 | Brotato / 土豆兄弟，单人模式 |
| 游戏版本 | manifest 列出的 `1.1.15` 至 `1.1.15.4` |
| ModLoader | manifest 列出的 `6.0.0`、`6.1.0`、`6.3.0`，属于 Godot 3 系列 |
| 可选依赖 | `Oudstand-ModOptions`，用于完整设置页与其配置存储 |
| 互斥项目 | 不要同时启用上游 `BlackTriangle-FullAutoBot` 和本修改版 |
| 源码语言 | Godot 3 GDScript；这不是可单独启动的 Godot 游戏工程 |

这些是当前文件中的适配声明，不能当作新版本游戏、所有 DLC 或所有操作系统已经通过本次实测的保证。ModLoader 项目及文档见 [GodotModding/godot-mod-loader](https://github.com/GodotModding/godot-mod-loader)。本仓库不附游戏、ModLoader、Mod Options 或任何反编译游戏源码。

## 可以控制什么

- **自动走位与躲避**：按武器射程、敌人、Boss、子弹、墙壁和拾取物计算移动方向。
- **独立商店操作**：分别开关自动买武器、自动买道具、自动重随、自动出售与合成。
- **成长界面**：分别开关自动选择升级和自动处理宝箱；关闭时停留给玩家处理。
- **波次衔接**：单独决定是否自动进入下一波。
- **安全设置**：调整低血量保命阈值、常规安全距离和 Boss 安全距离。
- **HUD 与挑战记录**：显示当前预设、危险程度、本波伤害、走位原因及决策统计；可选无伤波次、单武器族提醒、不重随记录或 Boss 波记录。它们只记录和提醒，不提供额外奖励，也不阻止玩家选择。

### 三个预设

| 预设 | 机器人处理 | 玩家处理 |
| --- | --- | --- |
| 手选成长（默认） | 自动走位与躲避 | 购买、重随、出售合成、升级、宝箱和下一波 |
| 半自动构筑 | 走位、购买、重随、出售合成和下一波 | 升级与宝箱 |
| 全自动 | 所有列出的自动化项目 | 随时暂停或手动接管 |

预设只是批量设置开关，选好后仍可逐项调整。

## 安装

1. 准备与你的游戏版本匹配、可以正常加载 ZIP Mod 的 ModLoader。先确认其他 Mod 和原存档可以正常使用。
2. 下载源码后按下文打包，或使用经过核对的 `Tong-AutoDodge-0.2.0.zip`。**GitHub 的“Download ZIP”源码下载包含仓库外层目录，不能直接当作游戏 Mod ZIP 使用。**
3. 将打包好的 ZIP 放入游戏安装目录中的本地 `mods` 文件夹，或你的 ModLoader 已配置扫描的本地 Mod 位置；保持 ZIP 内的目录结构，不要只放一个裸 `Tong-AutoDodge` 文件夹。ModLoader 的标准 ZIP 结构见 [官方结构说明](https://github.com/GodotModding/godot-mod-loader/wiki/Mod-Structure)。
4. 在游戏的 Mods / ModLoader 配置中启用 `Tong-AutoDodge`，关闭 `BlackTriangle-FullAutoBot`，然后重新启动游戏。不同游戏发行版本的扫描位置和界面可能不同，以对应版本的 ModLoader 设置为准。
5. 进入单人对局，暂停游戏并选择 **“自动战斗设置”**。如安装了 Mod Options，也能在其 **“土豆兄弟自动战斗”**设置页中修改同一组参数。

本 Mod 不需要替换游戏原始 `.pck`。多人场景或玩家死亡时，移动控制会停止输出；此保护不代表多人玩法已经适配。

## 操作与配置保存

- **F8**：暂停／恢复自动控制，不是打开设置面板。
- **手柄开关**：默认使用 Godot 的 `JOY_SELECT`，通常对应 View / Share；可在设置里改为 Start / Menu 或关闭。实际按键映射取决于手柄和驱动。
- **临时接管**：玩家主动推动方向输入时，机器人让出移动控制约 0.4 秒；松开后按当前开关恢复，手柄死区可调。
- **调整选项**：在游戏暂停菜单中打开“自动战斗设置”，使用鼠标或手柄导航；按返回按钮退出面板。

装有兼容的 Mod Options 时，选项经其 API 同步，配置持久化由该组件负责。**没有 Mod Options 时，暂停菜单面板仍可使用，但本修改版不会自行把界面改动写回配置文件；不要依赖这些会话内改动在重启后保留。**源码只会尝试读取 `user://tong_auto_dodge_settings.json` 作为可选初始设置。本仓库不附个人设置、存档或 ModLoader 用户配置文件。

机器人购买、升级、出售和继续波次使用正常游戏操作，因此启用这些选项后产生的进度可能随正常游戏保存；禁用或卸载 Mod 不会撤销已经发生的操作。首次测试请使用独立测试角色或存档副本。

## 从源码打包

在本仓库根目录运行结构检查：

```sh
python3 tools/verify_source.py
```

macOS / Linux 安装有 `zip` 时，可在同一目录打包：

```sh
zip -r Tong-AutoDodge-0.2.0.zip mods-unpacked/Tong-AutoDodge \
  -x "*/.DS_Store" "*/Thumbs.db" "*~" "*.swp"
```

ZIP 顶层必须是 `mods-unpacked`，例如：

```text
mods-unpacked/
└── Tong-AutoDodge/
    ├── manifest.json
    ├── mod_main.gd
    ├── bot/
    ├── extensions/
    └── ui/
```

不要把 `.git`、README、私有记录、游戏文件或整个仓库外层目录一起当作 Mod 打包。其他压缩工具也可以使用，但须得到相同的 ZIP 内部路径。

## 源码结构

| 路径 | 作用 |
| --- | --- |
| `mod_main.gd` | 注册脚本扩展并创建机器人运行节点 |
| `bot/bot_runner.gd` | 接入战斗、商店、升级、宝箱、暂停与 HUD |
| `bot/settings.gd`、`ui/pause_settings.gd` | 独立开关、预设、Mod Options 与暂停设置界面 |
| `bot/potential_field.gd` | 敌人、弹幕、墙壁与拾取物的走位计算 |
| `bot/build_profiles.gd`、`bot/build_profile.gd` | 沿用的角色构筑策略 |
| `bot/combat_model.gd`、`bot/shop_strategy.gd` | 战斗属性和装备选择评分 |
| `extensions/` | 保留玩家手动输入并加入暂停菜单入口 |

上述路径都相对于 `mods-unpacked/Tong-AutoDodge`。保留该 Mod 目录名；直接改名会破坏代码中的预加载和节点路径。

## 卸载与排查

退出游戏后，在 ModLoader 中禁用本 Mod，或移走它的 ZIP，再重新启动。源码开发安装则只移走你安装的 `mods-unpacked/Tong-AutoDodge`，不要删除整个公共 Mod 目录。

如入口或 HUD 不出现，先查 ModLoader 日志是否加载了 `Tong-AutoDodge`，再核对 ZIP 顶层结构、游戏版本、互斥 Mod 和 ModLoader 版本。如果自动成长与预期不同，先回到“手选成长”，检查具体开关。保留你自己的存档与配置，不要用覆盖原游戏 `.pck` 的方式排错。

## 本次验证与已知限制

本次发布整理只复制必要源码和许可文件，没有改变机器人业务逻辑。已核对 manifest、必需文件、预加载路径、选项、控制保护与 HUD 接线，运行随仓库提供的结构自检，并检查构建 ZIP 的路径与 CRC。自检仅验证文件和源码接线，不会启动游戏。

本次没有重新运行 Brotato、Godot 3 引擎解析、完整角色通关测试或实体手柄测试。走位和商店策略是启发式判断，不能保证无伤、最佳构筑或必定通关；旧版 Godot API、游戏内部节点和方法变化后可能需要适配。多 Mod 叠加、未来游戏版本、新 DLC 和极端弹幕场景需要另行实测。

[UPSTREAM_CHANGELOG.md](UPSTREAM_CHANGELOG.md) 保留的是上游 Full Auto Bot 的 `0.1.x` 历史记录；其中角色覆盖和旧安装结果不代表本修改版已经重新完成相同验证。旧上游自动发布工作流仍指向 `BlackTriangle-FullAutoBot`，没有作为本仓库的可执行 CI 启用。
