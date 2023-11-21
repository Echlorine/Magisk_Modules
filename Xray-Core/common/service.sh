MODPATH=${0%/*}
CONFIG_PATH="/sdcard/Documents/Configs/Xray"
traffic_log="$MODPATH/traffic.log"

until [ -f "$MODPATH/xray" ]; do
    sed -i 's/\[.*\]/\[ xray 核心丢失，请重新安装模块重启 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

until [ -f "$CONFIG_PATH/config.json" ]; do
    sed -i 's/\[.*\]/\[ 配置文件丢失，请重新设置配置文件 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
    sleep 5
done

sleep 5

cp -af $CONFIG_PATH/config.json $MODPATH/config.json
sed -i "s|\"access\": .*|\"access\": \"${MODPATH}/access.log\",|g" "$MODPATH/config.json"
sed -i "s|\"error\": .*|\"error\": \"${MODPATH}/error.log\",|g" "$MODPATH/config.json"
rm -rf $MODPATH/*.log
touch $MODPATH/access.log
touch $MODPATH/error.log
touch $traffic_log

chmod 0755 "$MODPATH/xray"
chmod 0644 "$MODPATH/config.json"
chmod 0664 "$MODPATH/access.log"
chmod 0664 "$MODPATH/error.log"
chmod 0664 $traffic_log

sleep 20

cat > "$MODPATH/traffic.sh" << EOF
query(){
    local ARGS=
    if [[ \$1 == "reset" ]]; then
        ARGS="-reset"
    fi
    DATA=\$($MODPATH/xray api statsquery --server=127.0.0.1:10807 \${ARGS} | awk '{
        if (match(\$1, /"name":/)) {
            f=1; gsub(/^"|link"|,\$/, "", \$2);
            split(\$2, p,  ">>>");
            printf "%s:%s->%s\t", p[1],p[2],p[4];
        }
        else if (match(\$1, /"value":/) && f){
            f = 0;
            gsub(/"/, "", \$2);
            printf "%.0f\n", \$2;
        }
        else if (match(\$0, /}/) && f) { f = 0; print 0; }
    }')
}

format(){
    echo -e "\$1" | awk '
        function format(num) {
            t = 0;
            num = num / 1024;
            while (num >= 1024 && t < 3) {
                num = num / 1024;
                t = t + 1;
            }
            if (t == 1) {
                f = sprintf("%4.3fMB", num);
            } else if (t == 2) {
                f = sprintf("%4.3fGB", num);
            } else if (t == 3) {
                f = sprintf("%4.3fTB", num);
            } else {
                f = sprintf("%4.3fKB", num);
            }
            return f;
        }
        {
            printf "%-30s\t%s\n", \$1, format(\$NF);
        }
    '
}

format_outbound(){
    echo -e "\$1" | awk '{
        if (match(\$1, /proxy/)){
            printf "Proxy:\t%s\n", \$NF;
        } else if (match(\$1, /direct/)){
            printf "Direct:\t%s\n", \$NF;
        } else if (match(\$1, /block/)){
            printf "Block:\t%s\n", \$NF;
        } else {
            printf "Sum:\t%s\n", \$NF;
        }
    }'
}

sum(){
    local DATA="\$1"
    local PREFIX="\$2"
    local SORTED=\$(echo "\$DATA" | grep "^\${PREFIX}" | sort -r)
    local SUM=\$(echo "\$SORTED" | awk '
        /->up/{us+=\$2}
        /->down/{ds+=\$2}
        END{
            printf "SUM->up:\t%.0f\nSUM->down:\t%.0f\nSUM->TOTAL:\t%.0f\n", us, ds, us+ds;
        }'
    )
    format "\${SORTED}"
    echo ""
    format "\${SUM}"
}

log(){
    echo "Updated in \$(echo -e \`date +%Y-%m-%d\` \`date +%H:%M:%S\`)" > ${traffic_log}
    echo >> ${traffic_log}
    echo "---------------Inbound-----------------" >> ${traffic_log}
    sum "\$DATA" "inbound" >> ${traffic_log}
    echo "---------------------------------------" >> ${traffic_log}
    echo >> ${traffic_log}
    echo "---------------Outbound----------------" >> ${traffic_log}
    sum "\$DATA" "outbound" >> ${traffic_log}
    echo "---------------------------------------" >> ${traffic_log}
}

outbound(){
    local DATA="\$1"
    local SORTED=\$(echo "\$DATA" | grep "^outbound:.*down" | sort -r)
    local SUM=\$(echo "\$SORTED" | awk '
        /->down/{ds+=\$2}
        END{
            printf "SUM->TOTAL:\t%.0f\n", ds;
        }'
    )
    format_outbound "\$(format "\${SORTED}")"
    format_outbound "\$(format "\${SUM}")"
}

if [[ \$1 == "reset" ]]; then
    rm -rf $MODPATH/*.log
    touch $MODPATH/access.log
    touch $MODPATH/error.log
    touch $traffic_log
    
    chmod 0664 "$MODPATH/access.log"
    chmod 0664 "$MODPATH/error.log"
    chmod 0664 $traffic_log
fi

query \$1
outbound "\$DATA"
log
if [[ \$1 == "reset" ]]; then
    echo >> ${traffic_log}
    echo "Last Reset Traffic in \$(echo -e \`date +%Y-%m-%d\` \`date +%H:%M:%S\`)" >> ${traffic_log}
fi
EOF

cat > "$MODPATH/stop.sh" << EOF
PIDS=\$(ps -e | grep "xray" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Kill Xray, PID: \${PID}"
        kill -9 \${PID}
    done
fi
sed -i 's/\[.*\]/\[ Xray-Core 暂停工作 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

cat > "$MODPATH/start.sh" << EOF
$MODPATH/xray run -config $MODPATH/config.json > /dev/null 2>&1 &
PIDS=\$(ps -e | grep "xray" | awk '{if(match(\$1, "root")) {print \$2}}')
if [ ! -z "\$PIDS" ]; then
    for PID in \$(echo -e "\$PIDS")
    do
        echo "Start Xray, PID: \${PID}"
    done
else
    echo "Xray 启动失败."
fi
sed -i 's/\[.*\]/\[ Xray-Core 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
EOF

chmod 0755 "$MODPATH/start.sh"
chmod 0755 "$MODPATH/stop.sh"
chmod 0755 "$MODPATH/traffic.sh"

$MODPATH/xray run -config $MODPATH/config.json > /dev/null 2>&1 &
sed -i 's/\[.*\]/\[ Xray-Core 正常工作中 \]/g' "$MODPATH/module.prop" > /dev/null 2>&1
