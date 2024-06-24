#!/bin/sh

set -ex

if
  [ -z "${DEVICE_NAME}" ] ||          # name of the device
  [ -z "${DEVICE_NUMBER}" ]         # number of the device
  [ -z "${DEVICE_IP_ADDRESS}" ]         # ip of the device
then
  echo 'One or more environment variables missing'
  exit 1
fi
echo "Device name: ${DEVICE_NAME}, Device number: ${DEVICE_NUMBER}"

[ "$DEVICE_NUMBER" -eq "0" ] && exit 0

sudo cp -nr /run/systemd/network /etc/systemd
cd /etc/systemd/network
ROUTE_TABLE=200${DEVICE_NUMBER}
files_list=$(find . -type f | grep "$DEVICE_NAME")
sudo sed -i "s/Table=.*/Table=${ROUTE_TABLE}/g" $files_list

if ! grep "RoutingPolicyRule" $files_list; then
/bin/cat <<EOF >rule-${DEVICE_NAME}
[RoutingPolicyRule]
From=${DEVICE_IP_ADDRESS}
Priority=10001
Table=${ROUTE_TABLE}
EOF
fi