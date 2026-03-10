#!/bin/bash

docker compose -f sensor-compose.yml down

docker image rm sctebot2_jazzy_base:latest sctebot2_jazzy_overlay:latest sctebot2_realsense_node:latest sctebot2_realsense_overlay:latest sctebot2_ydlidar_node:latest sctebot2_ydlidar_overlay:latest
