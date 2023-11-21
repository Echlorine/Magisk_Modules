MODPATH=${0%/*}
CONFIG_PATH="/sdcard/Documents/Configs/Frpc"

until [ -f "$MODPATH/frpc" ]; do
    sed -i 's/\[.*\]/\[ 文件frpc丢失，请重新安装模块重启 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

until [ -f "$CONFIG_PATH/frpc.toml" ]; do
    sed -i 's/\[.*\]/\[ 配置文件丢失，请重新设置配置文件 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

cp -af $CONFIG_PATH/frpc.toml $MODPATH/frpc.toml
sed -i "s|log.to.*|log.to = \"${MODPATH}/frpc.log\"|g" "$MODPATH/frpc.toml"
rm -rf $MODPATH/frpc*.log
touch "$MODPATH/frpc.log"

chmod 0755 "$MODPATH/frpc"
chmod 0644 "$MODPATH/frpc.toml"
chmod 0664 "$MODPATH/frpc.log"

sleep 20

cat > "$MODPATH/stop.sh" << EOF
PIDS=\$(ps -e | grep "frpc" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Kill frpc, PID: \${PID}."
        kill -9 \${PID}
    done
fi
sed -i 's/\[.*\]/\[ Frp 暂停工作 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

cat > "$MODPATH/start.sh" << EOF
$MODPATH/frpc -c $MODPATH/frpc.toml > /dev/null 2>&1 &
PIDS=\$(ps -e | grep "frpc" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Start frpc, PID: \${PID}."
    done
else
    echo "frpc 启动失败."
fi
sed -i 's/\[.*\]/\[ Frp 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

chmod 0755 "$MODPATH/start.sh"
chmod 0755 "$MODPATH/stop.sh"

$MODPATH/frpc -c $MODPATH/frpc.toml > /dev/null 2>&1 &
sed -i 's/\[.*\]/\[ Frp 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
