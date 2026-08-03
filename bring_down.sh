#!/bin/bash

clear && docker compose -f base-compose.yml down

clear && docker compose -f sensor-compose.yml down