#!/bin/bash
set -e

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "$KOBUKI_ROOT/install/setup.bash"


exec "$@"