#!/bin/bash

# Cambia según tu interfaz VPN
interface="tun0"
color="#ff9966"

if ip link show "$interface" 2>/dev/null | grep -q "state UNKNOWN"; then
  local_ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

  if [ -n "$local_ip" ]; then
    echo "%{F$color}TUN0 %{F-}$local_ip"
  fi
else
  echo "%{F$color}TUN0 %{F-}0.0.0.0/0"
fi
