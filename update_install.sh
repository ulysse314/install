#!/bin/bash
# update_install.sh

set -x

source /etc/ulysse314/script

update_git() {
  REPOSITORY="$1"
  GIT_PATH="$2"
  URL="https://github.com/ulysse314/${REPOSITORY}.git"
  pushd .
  cd "${MAIN_DIR}/${GIT_PATH}"
  if [ ! -d "${MAIN_DIR}/${GIT_PATH}/${REPOSITORY}" ]; then
    git clone "${URL}"
  else
    cd "${REPOSITORY}"
    git pull --rebase
  fi
  popd
}

update_dir() {
  DIR_PATH=`dirname $1`
  rsync -aqv --delete-after -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:$1" "${MAIN_DIR}/${DIR_PATH}/"
  chown -R ulysse314:ulysse314 "${MAIN_DIR}/${DIR_PATH}/"
}

apt update
apt upgrade -y
apt autoremove -y

apt install -y emacs-nox python3 autossh screen git python3-aiohttp python3-xmltodict gpsd python3-psutil python3-pip munin nginx libfl2 rsync
pip3 install pyserial-asyncio
pip3 install adafruit-pca9685
pip3 install netifaces

if [ -f "${MAIN_DIR}/scripts/crontab" ]; then
  cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
  cat "${MAIN_DIR}/scripts/crontab" >> /tmp/crontab
  mv /tmp/crontab /etc/crontab
fi

if [ ! -f /var/www/html/munin ]; then
  ln -s /var/cache/munin/www /var/www/html/munin
fi
if [ ! -e /etc/munin/plugins/ulysse314.py ]; then
  ln -s "${MAIN_DIR}/scripts/linux/munin_plugin.py" /etc/munin/plugins/ulysse314.py
fi
if [ ! -f /etc/udev/rules.d/99-feather-symlink.rules ]; then
  ln -s "${MAIN_DIR}/scripts/linux/udev-rules" /etc/udev/rules.d/99-feather-symlink.rules
fi
if [ ! -d "${MAIN_DIR}/arduino" ]; then
  mkdir "${MAIN_DIR}/arduino"
fi
if [ ! -d "${MAIN_DIR}/arduino/libraries" ]; then
  mkdir "${MAIN_DIR}/arduino/libraries"
fi

# arduino dirs
update_dir arduino/app
update_dir arduino/arduino15
# ulysse git
update_git boat
update_git scripts
# arduino git
update_git Adafruit_BME680 arduino/libraries
update_git Adafruit_GPS arduino/libraries
update_git Arduino-MemoryFree arduino/libraries
update_git ArduinoADS1X15 arduino/libraries
update_git ArduinoINA219 arduino/libraries
update_git ArduinoPCA9685 arduino/libraries
update_git OneWire arduino/libraries

cp "${MAIN_DIR}/scripts/authorized_keys" "/root/.ssh/authorized_keys"
cp "${MAIN_DIR}/scripts/authorized_keys" "${MAIN_DIR}/.ssh/authorized_keys"
chown ulysse314:ulysse314 "${MAIN_DIR}/.ssh/authorized_keys"
scp -P "${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:known_hosts" /root/.ssh/known_hosts
rsync -aqv --delete-after --exclude "name" -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:ulysse314" "/etc/"

# Camera
grep uv4l /etc/apt/sources.list | grep stretch
if [[ "$?" != "0" ]]; then
  curl http://www.linux-projects.org/listing/uv4l_repo/lpkey.asc | sudo apt-key add -
  cat /etc/apt/sources.list | grep -v uv4l > /tmp/sources.list
  cat /tmp/sources.list > /etc/apt/sources.list
  echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/stretch stretch main" >> /etc/apt/sources.list
  apt update
fi
grep start_x /boot/config.txt
if [[ "$?" != "0" ]]; then
  echo "start_x=1" >> /boot/config.txt
else
  sed -i "s/start_x=0/start_x=1/g" /boot/config.txt
fi
grep gpu_mem /boot/config.txt
if [[ "$?" != "0" ]]; then
  echo "gpu_mem=128" >> /boot/config.txt
fi
apt install -y uv4l uv4l-raspicam uv4l-raspicam-extras uv4l-server uv4l-uvc uv4l-xscreen uv4l-mjpegstream uv4l-dummy uv4l-raspidisp uv4l-tc358743-extras

date > /tmp/last_update_install.txt
