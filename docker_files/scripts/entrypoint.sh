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
if [ -d /realsense_ws ]
then

    echo "Updating rosdep..."
    rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y

    echo "Building realsense_ws workspace..."
    cd /realsense_ws && colcon build --symlink-install

    . /realsense_ws/install/setup.bash
    echo "Sourced realsense_ws workspace..."
fi

# source realsense_overlay if built
if [ -d /ydlidar_ws ]
then

    echo "Updating rosdep..."
    rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y

    # build the workspace on entry...
    # This is a hack since it seems building a bound volume folder does not work for unkown reasons and
    # copying from folders above the level of the compose files is forbidden for security reasons.
    echo "Building ydlidar_ws workspace..."
    cd /ydlidar_ws && colcon build --symlink-install

    . /ydlidar_ws/install/setup.bash
    echo "Sourced ydlidar_ws workspace..."
fi

# execute the command passed into this entrypoint
exec "$@"