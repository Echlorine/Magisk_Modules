# This script will be executed in late_start service mode
# More info in the main Magisk thread

MODPATH=${0%/*}
logFile="$MODPATH/kill.log"


echo "rm -f \"$MODPATH/disable\"" > "$MODPATH/start.sh"
echo "touch \"$MODPATH/disable\"" > "$MODPATH/stop.sh"
chmod 0755 "$MODPATH/start.sh"
chmod 0755 "$MODPATH/stop.sh"

cat /dev/null > ${logFile}
chmod 0664 $logFile
chmod 0755 "$MODPATH/AndroidFree"

while true ; do
    sleep 30
    "$MODPATH/AndroidFree" > /dev/null 2>&1
done