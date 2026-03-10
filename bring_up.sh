#!/bin/bash

clear && docker compose -f base-compose.yml up

clear && docker compose -f sensor-compose.yml up
