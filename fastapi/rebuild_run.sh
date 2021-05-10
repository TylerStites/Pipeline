#! /bin/bash
docker stop fastapi && \
docker rm fastapi && \
docker build -t fastapi . && \
docker run -d --name fastapi --net koyfin -p 80:80 fastapi && \
docker ps -a 