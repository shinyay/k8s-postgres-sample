#!/usr/bin/env fish

echo "RUN PostgreSQL Container"
docker run -d --rm --name postgres -e POSTGRES_USER=dev -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=dev -p 5432:5432 postgres:alpine

echo "RUN PGAdmin Container"
docker run -d --rm --name pgadmin -e PGADMIN_DEFAULT_EMAIL=dev -e PGADMIN_DEFAULT_PASSWORD=dev -p 80:80 dpage/pgadmin4

docker ps -a
