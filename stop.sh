# Exit on first error, print all commands.
set -ev
docker stack rm hyperledger-zk
docker stack rm hyperledger-kafka
docker stack rm hyperledger-orderer
docker stack rm hyperledger-couchdb
docker stack rm hyperledger-peer
docker stack rm hyperledger-ca
docker stack rm hyperledger-cli
