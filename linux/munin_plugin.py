#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import logging
import os
import pprint
import re
import socket
import sys

sys.path.append("/home/ulysse314/boat")

import config

def toInteger(value):
  return int(re.sub(r'[^\d-]+', '', value))

def printValue(name, first, second = None):
  global j
  if first not in j:
    return
  x = j[first]
  if second != None:
    if second not in x:
      return
    x = x[second]
  print(name + " " + str(x))

SETTINGS_DIR = "/etc/ulysse314/"
CONFIG_FILE = os.path.join(SETTINGS_DIR, "ulysse314.ini")
with open(os.path.join(SETTINGS_DIR, "name"), "r") as file:
  BOAT_NAME = file.readline().strip()
config.load(BOAT_NAME)

ip = "127.0.0.1"
port = config.values["munin_port"]
s = socket.socket()
s.connect((ip,port))
s.send(b'')
a = s.recv(2000)
s.close()
j = json.loads(a.decode("utf-8"))

if len(sys.argv) == 2 and sys.argv[1] == "config":
  print("multigraph ulysse314_temperature")
  print("graph_title Temperatures")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("graph_args --lower-limit 0 --upper-limit 100")
  print("dof.label DOF")
  print("pi.label PI")
  print("leftmotor.label Left Motor")
  print("rightmotor.label Right Motor")
  print("battery.label Battery")
  print("")
  print("multigraph ulysse314_battery")
  print("graph_title Battery")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("volt.label Volt")
  print("ampere.label Ampere")
  print("")
  print("multigraph ulysse314_pi")
  print("graph_title PI usage")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("disk.label Disk %")
  print("ram.label RAM %")
  print("cpu.label CPU %")
  print("")
  print("multigraph ulysse314_gps_4g")
  print("graph_title GPS/4G")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("gps_sat_tracked.label Satellite Tracked")
  print("gps_sat.label Satellite")
  print("cellular_signal.label Cellular Signal")
  print("cellular_network_type.label Network Type")
  print("")
  print("multigraph ulysse314_received_signal")
  print("graph_title Received signal")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("rsrp.label RSRP")
  print("rsrq.label RSRQ")
  print("rssi.label RSSI")
  print("")
  print("multigraph ulysse314_gps")
  print("graph_title GPS")
  print("graph_category ulysse314")
  print("graph_data_size custom 576, 6 107280")
  print("gps_lat.label Lat")
  print("gps_lon.label Lon")
elif len(sys.argv) == 2 and sys.argv[1] == "values":
  pprint.pprint(j)
else:
  print("multigraph ulysse314_temperature")
  print("dof.value " + str(j["dof"]["temp"]))
  print("pi.value " + str(j["pi"]["temp"]))
  print("leftmotor.value " + str(j["motor"]["lefttemp"]))
  print("rightmotor.value " + str(j["motor"]["righttemp"]))
  printValue("battery.value", "battery", "temp")
  print("")
  print("multigraph ulysse314_battery")
  printValue("volt.value", "battery", "volt")
  printValue("ampere.value", "battery", "ampere")
  print("")
  print("multigraph ulysse314_pi")
  print("disk.value " + str(j["pi"]["disk"]["used%"]))
  print("ram.value " + str(j["pi"]["ram"]["used%"]))
  print("cpu.value " + str(j["pi"]["cpu%"]))
  print("")
  print("multigraph ulysse314_gps_4g")
  print("gps_sat_tracked.value " + str(j["gps"]["tracked"]))
  print("gps_sat.value " + str(j["gps"]["sat"]))
  print("cellular_signal.value " + str(j["cellular"]["SignalIcon"]))
  print("cellular_network_type.value " + str(j["cellular"]["CurrentNetworkType"]))
  print("")
  print("multigraph ulysse314_received_signal")
  print("rsrp.value " + str(-toInteger(j["cellular"]["rsrp"])))
  print("rsrq.value " + str(-toInteger(j["cellular"]["rsrq"])))
  print("rssi.value " + str(-toInteger(j["cellular"]["rssi"])))
  print("")
  print("multigraph ulysse314_gps")
  printValue("gps_lat.value", "gps", "lat")
  printValue("gps_lon.value", "gps", "lon")