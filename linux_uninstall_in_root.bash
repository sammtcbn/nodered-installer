#!/bin/bash
function failed()
{
    echo "$*" >&2
    exit 1
}

SERVICE_NAME=nodered
SERVICE_FN=${SERVICE_NAME}.service
SERVICE_PATH=/lib/systemd/system/${SERVICE_FN}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

if [ -e ${SERVICE_PATH} ]; then
    systemctl stop ${SERVICE_NAME}
    systemctl disable ${SERVICE_NAME}
    rm -f --preserve-root ${SERVICE_PATH}
    systemctl daemon-reload
fi

npm -g remove node-red
npm -g remove node-red-dashboard
rm -rf /root/.node-red
