TAG=local
RPC_NODE=http://127.0.0.1:26657
CHECK_INTERVAL=10
SLACK_WEBHOOK=""
LAST_EPOCH_START_TIME = $(shell osmosisd q epochs epoch-infos | sed -n 4p | cut -c 28-60)

start:
	RPC_NODE=$(RPC_NODE) uvicorn main:app --reload --host 0.0.0.0 --port 8080

build:
	docker build -t rpc-sync-controller:$(TAG) .

run:
	docker run -ti -p 8080:8080 -e RPC_NODE=$(RPC_NODE) -e CHECK_INTERVAL=$(CHECK_INTERVAL) --network host --name controller rpc-sync-controller:$(TAG)

rund:
	docker run -d -p 8080:8080 -e RPC_NODE=$(RPC_NODE) -e CHECK_INTERVAL=$(CHECK_INTERVAL) --network host --name controller rpc-sync-controller:$(TAG)

alarm:
	docker run -ti -p 8080:8080 -e SLACK_WEBHOOK=${SLACK_WEBHOOK} -e RPC_NODE=$(RPC_NODE) -e CHECK_INTERVAL=$(CHECK_INTERVAL) --network host --name controller rpc-sync-controller:$(TAG)

alarmd:
	docker run -d -ti -p 8080:8080 -e SLACK_WEBHOOK=${SLACK_WEBHOOK} -e RPC_NODE=$(RPC_NODE) -e LAST_EPOCH_START_TIME="${LAST_EPOCH_START_TIME}" -e CHECK_INTERVAL=$(CHECK_INTERVAL) --network host --name controller rpc-sync-controller:$(TAG)

exec:
	docker run -ti -p 8080:8080 -e RPC_NODE=$(RPC_NODE) -e CHECK_INTERVAL=$(CHECK_INTERVAL) --network host --name controller --entrypoint bash rpc-sync-controller:$(TAG)

stop:
	docker stop -t 0 controller

remove: stop
	docker rm controller
