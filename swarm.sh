export DIGITALOCEAN_ACCESS_TOKEN=$(cat digitalocean_token.txt)
export DIGITALOCEAN_PRIVATE_NETWORKING=true 
export DIGITALOCEAN_IMAGE=debian-8-x64  

docker-machine create -d digitalocean consul

export KV_IP=$(docker-machine ssh consul 'ifconfig eth1 | grep "inet addr:" | cut -d: -f2 | cut -d" " -f1')
eval $(docker-machine env consul)

docker run -d -p ${KV_IP}:8500:8500 -h consul --restart always gliderlabs/consul-server -bootstrap 

docker-machine create -d digitalocean --swarm \
  --swarm-master \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  master

docker-machine create \
  -d digitalocean \
  --swarm \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  slave

