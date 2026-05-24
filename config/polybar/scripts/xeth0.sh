#!/bin/bash

# Cambia según tu interfaz Ethernet (puede ser eth0, enpXsX, etc)
interface="eth0"
color="#ff9966"

if ip link show "$interface" 2>/dev/null | grep -q "state UP"; then
  local_ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

  if [ -n "$local_ip" ]; then
    echo "%{F$color}ETH0 %{F-}$local_ip"
  else
    echo "%{F$color}ETH0 %{F-}0.0.0.0/0"
  fi
fi
