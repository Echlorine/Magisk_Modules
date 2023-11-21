# Magisk-Frp
基于 [Magisk](https://github.com/topjohnwu/Magisk) 在Android设备上启用 [Frp](https://gofrp.org/) 客户端，实现Android设备服务公网可访问。

# 如何使用
1. 新建一个Fprc配置文件，路径为 `/sdcard/Documents/Configs/Frpc/frpc.toml`。
2. 安装模块，模块安装时之后会自动读取配置文件，无需重启手机。
3. 模块目录下有`start.sh`、`stop.sh`脚本文件，分别可以控制 Frp 客户端的启动和暂停。

# frpc.toml 模板
这里提供一个简易模板，想了解更多可以去查看[Frp官方示例](https://gofrp.org/zh-cn/docs/examples/)。
```toml
user = "Username"
serverAddr = "xx.xx.xx.xx"
serverPort = 12345

loginFailExit = true
log.to = "./frpc.log"
# trace, debug, info, warn, error
log.level = "info"
log.maxDays = 5

# auth
auth.method = "token"
auth.token = "password"

webServer.addr = "127.0.0.1"
webServer.port = 7400
webServer.user = "admin"
webServer.password = "admin"

[[proxies]]
name = "Android_Kswb"
type = "tcp"
local_ip = "127.0.0.1"
localPort = 8080
remotePort = 8080
```

# Q&A
Q1：连接不上服务端？

A：需要确保服务端的 Frps 版本不小于客户端的 Frpc 版本。