MODPATH=${0%/*}
CONFIG_PATH="/sdcard/Documents/Configs/frps"

until [ -f "$MODPATH/frps" ]; do
    sed -i 's/\[.*\]/\[ 文件frps丢失，请重新安装模块重启 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

until [ -f "$CONFIG_PATH/frps.toml" ]; do
    sed -i 's/\[.*\]/\[ 配置文件丢失，请重新设置配置文件 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

cp -af $CONFIG_PATH/frps.toml $MODPATH/frps.toml
sed -i "s|log.to.*|log.to = \"${MODPATH}/frps.log\"|g" "$MODPATH/frps.toml"
rm -rf $MODPATH/frps*.log
touch "$MODPATH/frps.log"

chmod 0755 "$MODPATH/frps"
chmod 0644 "$MODPATH/frps.toml"
chmod 0664 "$MODPATH/frps.log"

sleep 20

cat > "$MODPATH/stop.sh" << EOF
PIDS=\$(ps -e | grep "frps" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Kill frps, PID: \${PID}."
        kill -9 \${PID}
    done
fi
sed -i 's/\[.*\]/\[ Frp 暂停工作 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

cat > "$MODPATH/start.sh" << EOF
$MODPATH/frps -c $MODPATH/frps.toml > /dev/null 2>&1 &
PIDS=\$(ps -e | grep "frps" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Start frps, PID: \${PID}."
    done
else
    echo "frps 启动失败."
fi
sed -i 's/\[.*\]/\[ Frp 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

chmod 0755 "$MODPATH/start.sh"
chmod 0755 "$MODPATH/stop.sh"

$MODPATH/frps -c $MODPATH/frps.toml > /dev/null 2>&1 &
sed -i 's/\[.*\]/\[ Frp 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
