#!/bin/bash
set -e

wget https://raw.githubusercontent.com/AIResearchLab/astra_legacy_ros/main/astra_camera/scripts/56-orbbec-usb.rules
cp 56-orbbec-usb.rules /etc/udev/rules.d/56-orbbec-usb.rules
udevadm control --reload-rules
udevadm trigger

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "$ASTRA_ROOT/install/setup.bash"

exec "$@"