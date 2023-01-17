# bililive-shell

一个使用纯shell编写的bilibili直播录制工具，仅依赖`curl`和`jq`，你甚至可以在路由器上运行此脚本

# 动机

之前用某个bilibili直播录制工具录制一场较为重要的直播时，出bug了。

录制了几个小时，最后只输出了一个文件夹，里面没有视频文件。并且，开始录制时，没有任何报错提示，当时想哭的心情都有了

一气之下，自己写了这个bilibili直播录制脚本

# 依赖

`curl`: https://curl.se/

`jq`: https://github.com/stedolan/jq

也可以用各系统自带的包管理工具安装

以debian为例

```bash
apt install curl jq -y
```

# 使用方法

./blive_curl.sh 直播间号(支持短号)

例如:

```bash
./blive_curl.sh 3394945
```

# TODO

- [x] H.264编码的直播
- [ ] H.265编码的直播
- [x] 提前监控直播间
- [x] 断线重新拉起

# 一些闲话

当主播网络不稳定时，可能会产生多个分段文件

建议在录制后将flv转换为mp4封装

Windows

```cmd
for %a in ("*.flv") do ffmpeg -i "%a" -c copy -f mp4 "%~na.mp4"
```

Linux

```bash
for i in $(ls *.flv);do ffmpeg -i "${i}" -c copy -f mp4 "${i%.flv}.mp4";done
```

支持H.265编码的直播录制工具会放在另一个项目，主要使用ffmpeg录制



如有bug，请提交issue

