# blockchain-network

# Clone this git

```
  cd blockchain-network
  git clone git@github.com:diieegoo01/blockchain-network.git
```

# Install Portainer.

```
    docker volume create portainer_data
    docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

Open url: http://localhost:9000

# build tools