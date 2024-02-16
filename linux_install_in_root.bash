#!/bin/bash
# ref to https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered
function failed()
{
    echo "$*" >&2
    exit 1
}

SERVICE_NAME=nodered
SERVICE_FN=${SERVICE_NAME}.service
SERVICE_PATH=/lib/systemd/system/${SERVICE_FN}

OLD_WORK_DIR="WorkingDirectory=\/home\/pi"
NEW_WORK_DIR="WorkingDirectory=\/root"

OLD_USER="User=pi"
NEW_USER="User=root"

OLD_GROUP="Group=pi"
NEW_GROUP="Group=root"

OLD_ENV_FILE="EnvironmentFile=-\/home\/pi"
NEW_ENV_FILE="EnvironmentFile=-\/root"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

apt -y update
apt -y install curl npm
npm install -g --unsafe-perm node-red node-red-admin node-red-dashboard

curl -sL -o ${SERVICE_PATH} https://raw.githubusercontent.com/node-red/linux-installers/master/resources/nodered.service || failed "download service error"

sed -i "s/$OLD_USER/$NEW_USER/g"         ${SERVICE_PATH} || failed "modify service file error"
sed -i "s/$OLD_GROUP/$NEW_GROUP/g"       ${SERVICE_PATH} || failed "modify service file error"
sed -i "s/$OLD_WORK_DIR/$NEW_WORK_DIR/g" ${SERVICE_PATH} || failed "modify service file error"
sed -i "s/$OLD_ENV_FILE/$NEW_ENV_FILE/g" ${SERVICE_PATH} || failed "modify service file error"

systemctl daemon-reload || exit 1
chmod 664 ${SERVICE_PATH} || exit 1
systemctl enable ${SERVICE_NAME} || exit 1
systemctl start ${SERVICE_NAME} || exit 1
