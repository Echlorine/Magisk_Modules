##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print " 修改 ZRAM 分区大小 "
  ui_print " 作者:Cmite（酷安） "
  ui_print "*******************************"
}

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  MemTotalStr=`cat /proc/meminfo | grep MemTotal`
  MemTotal=${MemTotalStr:16:8}

  low_ram=`getprop ro.config.low_ram`

  # curret Zram size
  current_zRamSize=`echo "($(cat /sys/block/zram0/disksize) + $(cat /sys/block/zram1/disksize)) / 1048576" | bc`
  ui_print "current zRamSize: ${current_zRamSize}MB"

  # Zram disk - 75% for Go devices.
  # For 512MB Go device, size = 384MB, set same for Non-Go.
  # For 1GB Go device, size = 768MB, set same for Non-Go.
  # For >=2GB Non-Go devices, size = 50% of RAM size. Limit the size to 4GB.
  # And enable lz4 zram compression for Go targets.

  if [ $MemTotal -le 524288 ]; then
    zRamSizeMBytes=384
  elif [ $MemTotal -le 1048576 ]; then
    zRamSizeMBytes=768
  fi
  RamSizeGB=`echo "($MemTotal / 1048576 ) + 1" | bc`
  zRamSizeMBytes=`echo "$RamSizeGB * 1024 / 2" | bc`
  if [ $zRamSizeMBytes -gt 4096 ]; then
    zRamSizeMBytes=4096
  fi

  if [ $MemTotal -le 1572864 ]; then
    zram_size="\"zram_size_MB\": \"${zRamSizeMBytes} 1536:1024 2560:1536 3256:2252 4915:2560 6553:4048 8892:4048 12888:0\""
  elif [ $MemTotal -le 2621440 ]; then
    zram_size="\"zram_size_MB\": \"512 1536:${zRamSizeMBytes} 2560:1536 3256:2252 4915:2560 6553:4048 8892:4048 12888:0\""
  elif [ $MemTotal -le 3334144 ]; then
    zram_size="\"zram_size_MB\": \"512 1536:1024 2560:${zRamSizeMBytes} 3256:2252 4915:2560 6553:4048 8892:4048 12888:0\""
  elif [ $MemTotal -le 5032960 ]; then
    zram_size="\"zram_size_MB\": \"512 1536:1024 2560:1536 3256:${zRamSizeMBytes} 4915:2560 6553:4048 8892:4048 12888:0\""
  elif [ $MemTotal -le 6710272 ]; then
    zram_size="\"zram_size_MB\": \"512 1536:1024 2560:1536 3256:2252 4915:${zRamSizeMBytes} 6553:4048 8892:4048 12888:0\""
  fi
  ui_print "MemTotal: ${RamSizeGB}GB"
  ui_print "zRamSize: ${zRamSizeMBytes}MB"
  ui_print "${zram_size}"

  mkdir -p $MODPATH/system/etc/
  cp -a /system/etc/mcd_default.conf $MODPATH/system/etc/ || echo "error code:145 lines"
  cp -a /system/etc/mcd_default.conf $MODPATH/system/etc/mcd_default.conf.bk || echo "error code:146 lines"
  sed -i "s/\"zram_size_MB\": \"512 1536:1024 2560:1536 3256:2252 4915:2560 6553:4048 8892:4048 12888:0\",/${zram_size},/g" $MODPATH/system/etc/mcd_default.conf
  ui_print "[!] 成功备份并修改 ZRAM 大小."
  ui_print "[!] 请重启手机."
}

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code