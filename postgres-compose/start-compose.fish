#!/usr/bin/env fish

echo "RUN PostgreSQL and PGAdmin Container"
docker-compose up -d

docker ps -a
