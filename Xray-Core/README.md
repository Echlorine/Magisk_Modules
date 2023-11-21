# Magisk-Xray-Core

基于 [Magisk](https://github.com/topjohnwu/Magisk) 在Android设备上安装 [Xray-Core](https://github.com/xtls/Xray-core/) ，实现相关功能。

# 如何使用
1. 新建一个Xray客户端配置文件，路径为 `/sdcard/Documents/Configs/Xray/config.json`。
2. 安装模块，模块安装时之后会自动读取配置文件，无需重启手机。
3. 模块目录下有`start.sh`、`stop.sh`脚本文件，分别可以控制 Xray-Core 的启动和暂停。
4. 模块目录下有`traffic.sh`脚本文件，可以进行流量的统计与重置，<font color="blue">**需要确保配置文件中的API端口为10807**</font>。
   - 流量统计`sh traffic.sh`
   - 流量清零`sh traffic.sh reset`

# config.json 模板
这里提供一个配置模板，想了解更多可以去查看[Xray官方示例](https://xtls.github.io/config)。
基本上只需要自己提供第一个出站代理`outbounds`即可工作。

```json
{
    "log": {
        "access": "",
        "error": "",
        "loglevel": "warning"
    },
    "api": {
        "tag": "api",
        "services": [
            "StatsService"
        ]
    },
    "dns": {
        "hosts": {
            "domain:googleapis.cn": "googleapis.com",
        },
        "servers": [
            "https://1.1.1.1/dns-query",
            "1.1.1.1",
            "8.8.8.8",
            "8.8.4.4",
            {
                "address": "223.5.5.5",
                "domains": [
                    "geosite:cn"
                ],
                "expectIPs": [
                    "geoip:cn"
                ],
                "port": 53
            },
            {
                "address": "114.114.114.114",
                "domains": [
                    "geosite:cn"
                ]
            },
            "localhost"
        ]
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "inboundTag": [
                    "api"
                ],
                "outboundTag": "api"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:category-ads-all"
                ],
                "outboundTag": "block"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:cn"
                ],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "ip": [
                    "geoip:private",
                    "geoip:cn"
                ],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "domain": [
                    "domain:googleapis.cn",
                    "geosite:geolocation-!cn"
                ],
                "outboundTag": "proxy"
            },
            {
                "type": "field",
                "ip": [
                    "223.5.5.5",
                    "114.114.114.114"
                ],
                "outboundTag": "direct"
            }
        ]
    },
    "policy": {
        "system": {
            "statsInboundUplink": true,
            "statsInboundDownlink": true,
            "statsOutboundUplink": true,
            "statsOutboundDownlink": true
        }
    },
    "inbounds": [
        {
            "tag": "api",
            "port": 10807,
            "listen": "0.0.0.0",
            "protocol": "dokodemo-door",
            "settings": {
                "address": "127.0.0.1"
            }
        },
        {
            "tag": "socks-in",
            "protocol": "socks",
            "listen": "0.0.0.0",
            "port": 10808,
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            },
            "settings": {
                "auth": "noauth",
                "udp": true
            }
        },
        {
            "tag": "http-in",
            "protocol": "http",
            "listen": "0.0.0.0",
            "port": 10809,
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            },
            "settings": {
                "auth": "noauth",
                "allowTransparent": false
            }
        }
    ],
    "outbounds": [
        {},
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIP"
            }
        },
        {
            "tag": "block",
            "protocol": "blackhole",
            "settings": {
                "response": {
                    "type": "http"
                }
            }
        }
    ],
    "stats": {}
}
```
