NAME=comment-demo
NETWORK=${NAME}-network
DB=${NAME}-db

.PHONY: db-up
db-up:
	docker run -v $(shell pwd)/migrations:/migrations --network ${NETWORK}  migrate/migrate -path=/migrations/ -database postgres://postgres:example@${DB}:5432/${NAME}?sslmode=disable up

.PHONY: db-drop
db-drop:
	docker run -v $(shell pwd)/migrations:/migrations --network ${NETWORK}  migrate/migrate -path=/migrations/ -database postgres://postgres:example@${DB}:5432/${NAME}?sslmode=disable goto 0

.PHONY: seed
seed:
	docker network create ${NETWORK}
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose down

.PHONY: clear
clear:
	make stop
	docker-compose rm
	docker network remove ${NETWORK}
