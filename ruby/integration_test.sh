#! /bin/bash
DB_NAME=comment-demo

docker run -d --name comment-integration-db -p 54321:5432 -e POSTGRES_PASSWORD=example -e POSTGRES_DB=${DB_NAME} -e TZ=UTC -e PGTZ=UTC postgres:12
sleep 3
docker run --network=host -v $(dirname $(pwd))/migrations:/migrations migrate/migrate -path=/migrations/ -database postgres://postgres:example@localhost:54321/${DB_NAME}?sslmode=disable up
rake integration

docker rm -f comment-integration-db