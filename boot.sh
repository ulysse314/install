#!/bin/bash

set -x

source /etc/ulysse314/script

DEBUG_FILE='/tmp/boot.log'
if [[ "${SSH_WIFI_PORT}" != "" ]]; then
  SSH_WIFI="-R *:${SSH_WIFI_PORT}:127.0.0.1:22"
fi
if [[ "${CAM_WIFI_PORT}" != "" ]]; then
  CAM_WIFI="-R *:${CAM_WIFI_PORT}:127.0.0.1:8090"
fi
if [[ "${SSH_4G_PORT}" != "" ]]; then
  SSH_4G="-R *:${SSH_4G_PORT}:127.0.0.1:22"
fi
if [[ "${CAM_4G_PORT}" != "" ]]; then
  CAM_4G="-R *:${CAM_4G_PORT}:127.0.0.1:8090"
fi

/home/ulysse314/scripts/update_install.sh
AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/wifi_autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_4G} ${CAM_4G} -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
echo "ok" > "${DEBUG_FILE}"
lsusb >> "${DEBUG_FILE}"
/home/ulysse314/scripts/add_route.sh &
#AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/4g_autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_4G} ${CAM_4G} -b 192.168.8.100 -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
date >> "${DEBUG_FILE}"

if [[ "${CAMERA_ID}" == "PI" ]]; then
  echo "camera: PI" >> "${DEBUG_FILE}"
  uv4l --driver raspicam --server-option --port=8081 --auto-video_nr --width 640 --height 480 --encoding jpeg -–framerate 30 1&>> "${DEBUG_FILE}"
elif [[ "${CAMERA_ID}" != "" ]]; then
  echo "camera: USB, ${CAMERA_ID}" >> "${DEBUG_FILE}"
  uv4l --driver uvc --syslog-host localhost --device-id "${CAMERA_ID}" --server-option --port=8081 --auto-video_nr 1&>> "${DEBUG_FILE}"
else
  echo "camera: None"  >> "${DEBUG_FILE}"
fi

echo done >> "${DEBUG_FILE}"
/home/ulysse314/boat/start.sh boat "${BOAT_NAME}"
