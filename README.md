# blockchain-network

### Pre-reqs

* 1 or more machines with Linux
* Install Docker >= 1.13
* Install [Golang](https://golang.org/doc/install) >= 1.9
* Install [Nodejs](https://nodejs.org/en/download/) and [Yarn](https://yarnpkg.com/lang/en/docs/install/#mac-stable)


# Clone this git

```
  cd blockchain-network
  git clone git@github.com:diieegoo01/blockchain-network.git
```

# Install Portainer. Portainer es un visualizador de containers de un host.

```
    docker volume create portainer_data
    docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

Open url: http://localhost:9000

# build tools
_Require libltdl_  
Ubuntu: `sudo apt install libltdl-dev`  
Centos: `yum install libtool-ltdl-devel`

## Instructions


### [Create Docker Swarm cluster](https://docs.docker.com/engine/swarm/swarm-tutorial/)

* Create one or more master hosts and other worker hosts
  * Open ports for Swarm. On ALL hosts, (eg, CentOS)

```
  # if run on local, no need
  firewall-cmd --permanent --zone=public --add-port=2377/tcp --add-port=7946/tcp --add-port=7946/udp --add-port=4789/udp
  firewall-cmd --reload
```

* I think opening swarm ports only is sufficient because all nodes communicates thru overlay network.

- on master host,
  If you can not run swarm mode, you must set --live-restore to false in /etc/docker/daemon.json  
  For those who can’t find /etc/docker/daemon.json try /etc/sysconfig/docker
  live-restore option is there:
  OPTIONS=’–selinux-enabled --log-driver=journald --live-restore’

```
  docker swarm init
```

* You can see like below,

```
  Swarm initialized: current node (dxn1zf6l61qsb1josjja83ngz) is now a manager.

  To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0q7mhbliu4lp7lehsavwzkv2di8214bvp7d29d33zxbbn6gm88-dz9bdw752l2296ni4ia2nsudk 192.168.65.3:2377

  To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

* Use last command to join worker host to Swarm cluster
  eg, on worker hosts,

```
    docker swarm join --token SWMTKN-1-0q7mhbliu4lp7lehsavwzkv2di8214bvp7d29d33zxbbn6gm88-dz9bdw752l2296ni4ia2nsudk 192.168.65.3:2377
```

### Create overlay network

* Create overlay network which will be used as path between hyperledger nodes
  * on Master host,

```
    docker network create --attachable --driver overlay --subnet=10.200.1.0/24 hyperledger
```

### Download Hyperledger Fabric v1.1 images and Bin:
```
    curl -sSL http://bit.ly/2ysbOFE | bash -s 1.1.0 1.1.0 0.4.10

```

* Generate artifacts

```
  ./generate.sh -c
```
Se generan todos los certificados de la organización. en carpeta config/ y /crypto-config. Recordar cambiar la ruta del certificado _sk en docker composer del CA. Ejemplo: - FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/46b93201b21aa6d399adf542dc9f3d890f2c8288c258bb99ad3aaf1dc889146d_sk

* Attach to cli container

```
  docker exec -it $(docker ps --format "table {{.ID}}" -f "label=com.docker.stack.namespace=hyperledger-cli" | tail -1) bash
```

* Create a channel

```
  export CHANNEL_NAME=mychannel
  export ORG=agiletech.vn
  peer channel create -o orderer0.${ORG}:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$ORG/orderers/orderer0.${ORG}/msp/tlscacerts/tlsca.${ORG}-cert.pem
```

* Join a channel

```
  peer channel join -b mychannel.block
  peer channel list
```

* Install & Initiate Chaincode

```
  peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/sacc
  peer chaincode instantiate -o orderer0.agiletech.vn:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/agiletech.vn/orderers/orderer0.agiletech.vn/msp/tlscacerts/tlsca.agiletech.vn-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["a", "100"]}'
```