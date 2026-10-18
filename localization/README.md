# 简体中文本地化管线

引擎（eagler 移植版）支持 thcrap 风格的整文件覆盖：游戏读取资源时优先查 `/thcrap/thXX/<相对路径>`。
本目录脚本在树莓派上把 thpatch 官方的 `lang_zh-hans` 补丁栈编译成引擎原生格式，实现界面 + 剧情全汉化。

## 一次性准备

```bash
apt-get install -y nodejs libpng-dev zlib1g-dev bison flex cmake
git clone --depth 1 https://github.com/thpatch/thtk.git ~/thtk && cd ~/thtk
# 国内网络代理：git config --global url."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"
git submodule update --init --depth 1
mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make -j4 thdat thmsg
```

再从上游 YomotsuHisami/eagler-touhou 仓库取 launcher 编译链到 `~/thcrap-pack/`：
`server/thcrap-compiler.mjs`、`server/thcrap-ascii-contract.mjs`、`server/thcrap-string-contract.mjs`、`server/thtk-runner.mjs`、`integrations/thcrap.mjs`（把 PRODUCT_CONTENT 依赖换成静态游戏列表后存为 `integrations/thcrap-local.mjs`）。

## 用法

```bash
cd ~/thcrap-pack && node pack-driver.mjs th08   # 生成 ~/games/lang/th08/
ln -sfn ~/games/lang /thcrap                     # 引擎读 /thcrap/th08/...
```

产物：msg 剧情（thtk dump→打补丁→重编）、结局、符卡/音乐评论/标题 .etl 表、ascii/strings 界面文本表、中文字体与贴图。原始日文资源不动，删掉 `/thcrap/thXX` 即回退日文。

## BGM

`extract-bgm-generic.py th07|th08`：用 thdat 从 thXX.dat 提出 thbgm.fmt，按偏移从 thbgm.dat 切 PCM，ffmpeg 转 OGG。th08 放 `/bgm-ogg/`（根链接），th07 放 `~/games/th07/bgm-ogg/`（相对路径）。循环点引擎自己从 fmt 读，OGG 不用带。

## 教训

改过头文件后必须 `rm -rf artifacts/native`（或对应构建目录）全量重编——陈旧 .o 的 ABI 不一致会让引用成员读到野值，崩得毫无征兆。
