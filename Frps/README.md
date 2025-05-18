# Magisk-Frp
基于 [Magisk](https://github.com/topjohnwu/Magisk) 在Android设备上启用 [Frp](https://gofrp.org/) 客户端，实现Android设备服务公网可访问。

# 如何使用
1. 新建一个Fprc配置文件，路径为 `/sdcard/Documents/Configs/Frps/frps.toml`。
2. 安装模块，模块安装时之后会自动读取配置文件，无需重启手机。
3. 模块目录下有`start.sh`、`stop.sh`脚本文件，分别可以控制 Frp 客户端的启动和暂停。

# frps.toml 模板
这里提供一个简易模板，想了解更多可以去查看[Frp官方示例](https://gofrp.org/zh-cn/docs/examples/)。
```toml
# bind
bindAddr = "0.0.0.0"
bindPort = 23333

# dashboard
webServer.addr = "127.0.0.1"
webServer.port = 28888
webServer.user = "Echo"
webServer.password = "WebPassword"

# log
log.to = "./frps.log"
log.level = "info"
log.maxDays = 7
log.disablePrintColor = false

# auth
auth.method = "token"
auth.token = "AuthPassword"
```

# Q&A
