clean:
	docker-compose down
build:
	make init
	docker-compose up -d --build
init:
	docker-compose up -d --build db
	sleep 10
	mysql -u user1 -p -h 127.0.0.1 -P 3306 < db/init.sql
up:
	docker-compose up -d 
ps:
	docker-compose ps
stop:
	docker-compose stop
shell-app:
	docker-compose exec app  /bin/bash
logs-app:
	docker-compose logs app
