# ref: 
# https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/
# https://github.com/sea-bass/turtlebot3_behavior_demos/blob/main/dependencies.repos
ARG DOCKER_ROS_DISTRO=jazzy

# ref: 
# https://roboticseabass.com/2021/04/21/docker-and-ros/
####################
# NVIDIA BASE IMAGE
####################
# none

# sudo apt update && sudo apt install curl -y
# export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
# curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
# sudo dpkg -i /tmp/ros2-apt-source.deb

####################
### BASE IMAGE
####################
FROM ros:${DOCKER_ROS_DISTRO} AS base
# THIS IS SET BY THE ROS BASED IMAGE
# ENV ROS_DISTRO=${DOCKER_ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# Install packages #
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash curl git wget rsync unzip apt-transport-https \
  libqt5svg5-dev python3-pip python3-tk python3-pyqt5.qtwebengine

# Install python modules
# none

# Modify DDS middleware
# none

# Create Colcon workspace with external dependencies
RUN mkdir -p /docker_ros2_ws/src
WORKDIR /docker_ros2_ws/src
COPY dependencies.repos .
RUN vcs import < dependencies.repos

# Build the base Colcon workspace, installing dependencies first.
WORKDIR /docker_ros2_ws
RUN . /opt/ros/${ROS_DISTRO}/setup.bash \
  && apt-get update -y \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
  && colcon build --symlink-install
ENV SCTEBOT2_MODEL=1

# Set up the entrypoint
WORKDIR /docker_ros2_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

####################
### OVERYLAY IMAGE
####################
FROM base AS overlay

# Create an onverlay Colcon workspace
RUN mkdir -p /overlay_ws/src
WORKDIR /overlay_ws

# COPY ./package1 ./src/package1
# COPY ./package2 ./src/package2

RUN . /docker_ros2_ws/install/setup.bash \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
  && colcon build --symlink-install

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

####################
### DEV IMAGE
####################
FROM overlay AS dev

# Dev container arguments
ARG USERNAME=devuser
ARG UID=1000
ARG GID=${UID}

# Install extra tools for development
RUN apt-get update && apt-get install -y --no-install-recommends \
  gdb gdbserver nano

# In Ubuntu 24.04, there is already a user named "ubuntu" with UID 1000.
# Delete this in the (common) event that the user on the host also has this UID.
RUN touch /var/mail/ubuntu \
  && chown ubuntu /var/mail/ubuntu \
  && userdel -r ubuntu

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
  && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
  && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME} \
  && mkdir -p /home/${USERNAME} \
  && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /overlay_ws/

# Set up the entrypoint, including it in the .bashrc for interactive shells
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc

####################
### REALSENSE OVERLAY
####################
FROM base AS realsense_overlay

RUN apt-get update && apt-get install -y --no-install-recommends \
  libglfw3 libglfw3-dev ros-${ROS_DISTRO}-diagnostic-updater

# Install Realsense SDK https://github.com/realsenseai/librealsense/blob/v2.56.4/doc/distribution_linux.md
RUN mkdir -p /etc/apt/keyrings \
  && curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null \
  && echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
  sudo tee /etc/apt/sources.list.d/librealsense.list \
  && apt-get update

RUN apt-get update && apt-get install -y librealsense2 ros-jazzy-realsense2-*

RUN mkdir -p /realsense_ws/src
WORKDIR /realsense_ws

RUN . /docker_ros2_ws/install/setup.bash \
  && rosdep update \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
  && colcon build --symlink-install \
  && . /realsense_ws/install/setup.bash

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

####################
### REALSENSE NODE
####################
FROM realsense_overlay AS realsense_node

# realsense container arguments
ARG USERNAME=realsense_user
ARG UID=1000
ARG GID=${UID}

# In Ubuntu 24.04, there is already a user named "ubuntu" with UID 1000.
# Delete this in the (common) event that the user on the host also has this UID.
RUN touch /var/mail/ubuntu \
  && chown ubuntu /var/mail/ubuntu \
  && userdel -r ubuntu

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
  && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
  && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME} \
  && mkdir -p /home/${USERNAME} \
  && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /realsense_ws/

# Set up the entrypoint, including it in the .bashrc for interactive shells
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc
