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

apt -y install curl npm
npm install -g --unsafe-perm node-red node-red-dashboard

curl -sL -o ${SERVICE_PATH} https://raw.githubusercontent.com/node-red/linux-installers/master/resources/nodered.service || failed "download service error"

sed -i 's/User=pi/User=root/g' ${SERVICE_PATH} || failed "modify service file error"
sed -i 's/Group=pi/Group=root/g' ${SERVICE_PATH} || failed "modify service file error"
sed -i 's/WorkingDirectory=\/home\/pi/WorkingDirectory=\/home\/root/g' ${SERVICE_PATH} || failed "modify service file error"
sed -i 's/EnvironmentFile=-\/home\/pi/EnvironmentFile=-\/home\/root/g' ${SERVICE_PATH} || failed "modify service file error"

systemctl daemon-reload || exit 1
chmod 664 ${SERVICE_PATH} || exit 1
systemctl enable ${SERVICE_NAME} || exit 1
systemctl start ${SERVICE_NAME} || exit 1
