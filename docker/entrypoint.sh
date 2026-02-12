#!/bin/bash

echo "DOCKER ROS2 CONTAINER TESTS"

. /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS2 ${ROS_DISTRO}"

# source workspace if built
if [ -f /docker_ros2_ws/install/setup.bash ]
then
    . /docker_ros2_ws/install/setup.bash
    echo "Sourced docker_ros2_ws workspace..."
fi

# source overlay if built
if [ -f /overlay_ws/install/setup.bash ]
then
    . /overlay_ws/install/setup.bash
    echo "Sourced overlay_ws workspace..."
fi

# source realsense_overlay if built
if [ -f /realsense_ws/install/setup.bash ]
then
    . /realsense_ws/install/setup.bash
    echo "Sourced realsense_ws workspace..."
fi

# execute the command passed into this entrypoint
exec "$@"