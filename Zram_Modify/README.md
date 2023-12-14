# Magisk-Zram_Modify
基于 [Magisk](https://github.com/topjohnwu/Magisk) 在类MIUI系统(JOYUI系统)上修改 Zram 大小。

# 如何使用
1. 直接刷入模块重启即可使用。模块会按照下列规则自动选择 Zram 分区大小。
```
# Zram disk - 75% for Go devices.
# For 512MB Go device, size = 384MB, set same for Non-Go.
# For 1GB Go device, size = 768MB, set same for Non-Go.
# For >=2GB Non-Go devices, size = 50% of RAM size. Limit the size to 4GB.
# And enable lz4 zram compression for Go targets.
```
2. 也可以手动修改 Zram 分区大小，模块安装好之后，可以通过修改模块文件夹(/data/adb/modules/Zram_Modify)下的
`system/etc/mcd_default.conf`文件来实现手动修改 Zram 分区大小的目的。