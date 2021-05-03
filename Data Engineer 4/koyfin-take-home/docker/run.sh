#!/bin/bash

PWD="${PWD}"
DATA_DIR="${PWD}/data/"
SPARK_VERSION='2.4.5'
ELASTIC_SEARCH_VERSION='7.3.2'

if [ "$2" != "" ]; then
  SPARK_VERSION="$2"
fi

if [ "$3" != "" ]; then
  ELASTIC_SEARCH_VERSION="$3"
fi

SPARK_HOME="${PWD}/spark-${SPARK_VERSION}"
DOCKER_COMPOSE_FILE='docker-compose-all.yaml'
DOCKER_NETWORK_NAME='koyfin'

export SPARK_VERSION=${SPARK_VERSION}
export SPARK_HOME=${SPARK_HOME}

echo "Current Context: SPARK_HOME=${SPARK_HOME} which is running SPARK_VERSION=${SPARK_VERSION}"

function installSpark() {
    if test ! -d "${PWD}/spark-${SPARK_VERSION}"
    then
    echo "using curl to download spark 2.4.5"
      curl -XGET "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" > "${PWD}/install/spark-${SPARK_VERSION}.tgz"
      cd "${PWD}/install" && tar -xvzf spark-${SPARK_VERSION}.tgz && rm spark-${SPARK_VERSION}.tgz
      mv spark-${SPARK_VERSION}-bin-hadoop2.7 ../spark-${SPARK_VERSION}
      cd ..
    else
      echo "Spark is already installed under ${PWD}/spark-${SPARK_VERSION}"
    fi
    echo "${PWD}"
}


function sparkConf() {
    cp "${PWD}/install/spark-defaults.conf" "${PWD}/spark-${SPARK_VERSION}/conf/"
}

function init() {
   installSpark
   sparkConf
}

function createNetwork() {
  cmd="docker network ls | grep ${DOCKER_NETWORK_NAME}"
  eval $cmd
  retVal=$?
  if [ $retVal -ne 0 ]; then
    docker network create -d bridge ${DOCKER_NETWORK_NAME}
  else
    echo "docker network already exists ${DOCKER_NETWORK_NAME}"
  fi
}

function cleanDocker() {
    docker rm -f `docker ps -aq` # deletes the old containers
}

function start() {
    #init
    export SPARK_HOME=${PWD}/"spark-${SPARK_VERSION}"
    echo "Your Spark Home is set to ${SPARK_HOME}"
    cleanDocker
    createNetwork
    
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans redis5
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans zeppelin

    docker run -d --name elasticsearch --hostname elasticsearch --net ${DOCKER_NETWORK_NAME} -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" "elasticsearch:${ELASTIC_SEARCH_VERSION}"
    docker run -d --name kibana --net ${DOCKER_NETWORK_NAME} -p 5601:5601 "kibana:${ELASTIC_SEARCH_VERSION}"
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans zeppelin

    echo "ElasticSearch is now running on port 9200 for the http API and port 9300 for transport api"
    echo "Kibana is now running on port 5601: http://localhost:5601. So you can create indices and dashboards there"
    echo "Apache Zeppelin is now running on port 8080 at http://localhost:8080/. Now you can harness the power of Notebooks to mess with ElasticSearch from Spark"
    echo "Let's get Started!"
}

function stop() {
    docker-compose -f ${DOCKER_COMPOSE_FILE} down
    docker stop elasticsearch
    docker stop kibana
}

function info() {
    CONTAINER=$2
    echo "INSPECT THIS ${CONTAINER}"
    docker inspect ${CONTAINER}
}

case "$1" in
    install)
        init
    ;;
    start)
        start
    ;;
    stop)
        stop
    ;;
    info)
        info
    ;;
    *)
        echo $"Usage: $0 {install | start | stop | info {CONTAINER_NAME}"
    ;;
esac
