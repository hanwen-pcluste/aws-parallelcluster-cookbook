#!/bin/sh

set -ex

if
  [ -z "${DEVICE_NAME}" ] ||          # name of the device
  [ -z "${DEVICE_NUMBER}" ]         # number of the device
then
  echo 'One or more environment variables missing'
  exit 1
fi
echo "Device name: ${DEVICE_NAME}, Device number: ${DEVICE_NUMBER}"

[ "$DEVICE_NUMBER" -eq "0" ] && exit 0

echo "helllllllo"
sudo cp -nr /run/systemd/network /etc/systemd
echo "helllllllo2"
cd /etc/systemd/network
files_list=$(find . -type f | grep "$DEVICE_NAME")
sudo sed -i "s/Table=.*/Table=200${DEVICE_NUMBER}/g" $files_list
echo "hellllllloend"