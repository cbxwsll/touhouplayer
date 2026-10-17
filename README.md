# touhouplayer

东方 Project 官作（TH06+）在树莓派 4B 掌机上的原生 ARM64 移植补丁集。

## 上游与许可

本仓库的补丁基于 [YomotsuHisami](https://github.com/YomotsuHisami) 各作仓库的 `eagler` 分支（如 [th06](https://github.com/YomotsuHisami/th06)、[th07](https://github.com/YomotsuHisami/th07)），上游代码以 **CC0 1.0 Universal** 发布。补丁本身同样以 CC0 发布。版权归原作者所有，此处仅作学习与个人设备使用。游戏资源文件（.dat 等）为 ZUN 版权，本仓库不包含也不会包含。

## 内容

- `patches/th07-eagler-hitbox.patch` —— TH07 eagler 分支的 native 构建补丁：
  - `TH_HITBOX` 环境变量三档判定点控制（off 默认 / focus / always；TH07 专注时原生显示判定点，补丁实现 always 强制常显）
  - 补上游缺失的 `src/i18n.hpp`（MidiAlsa.cpp 引用但上游未提交）
  - 补上游缺失的 `utils::DebugPrint2`（对齐 TH06 实现）
- `patches/th06/EaglerOptions.hpp` —— TH06 eagler 分支同款 `TH_HITBOX` 三档补丁（完整文件，直接替换 `src/EaglerOptions.hpp`）。TH06 需要额外放置 `eagler-hitbox.png`（可用 eagler-touhou 仓库的 `scripts/touhou_formats.py extract-th07-texture` 从 th07.dat 提取）
- `launcher/launcher.sh` —— 掌机启动菜单（fbcon 英文菜单，含判定点模式切换项，持久化到 `~/.touhou_hitbox`）

## 构建（树莓派 OS Lite 64 位）

```bash
git clone -b eagler https://github.com/YomotsuHisami/th07.git
cd th07 && git submodule update --init --depth 1 third_party/eagler-common
git apply /path/to/th07-eagler-hitbox.patch
cmake -B build -G Ninja -DTH_EXTERNAL_ASSETS=ON -DCMAKE_BUILD_TYPE=Release \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=ON -DSDL_UNIX_CONSOLE_BUILD=ON \
  -DOPENGL_gles3_LIBRARY=/usr/lib/aarch64-linux-gnu/libGLESv2.so
cmake --build build
```

链接系统 SDL3 / SDL3_image / SDL3_ttf（无需 vendored SDL 子模块）。二进制加载资源以**可执行文件所在目录**为基准，需复制到游戏目录运行：

```bash
cp build/th07 ~/games/th07/th07e
cd ~/games/th07 && TH_HITBOX=always ./th07e
```

控制台分辨率建议在 `/boot/firmware/cmdline.txt` 锁定 `video=HDMI-A-1:800x480@60`（按屏幕原生分辨率调整），否则终端字体会因模式切换忽大忽小。
