#!/bin/bash
set -e

# udevadm control --reload-rules
# udevadm trigger

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "$ASTRA_ROOT/install/setup.bash"

exec "$@"
