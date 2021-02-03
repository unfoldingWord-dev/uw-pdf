# Docker Container for Building uW PDF Files

Includes Python3 and ConText


### Add yourself to the docker group
```bash
sudo usermod -a -G docker YOUR_USER
sudo reboot
```

### Build the Docker container
```bash
# cd ~/Projects/uW-docker
# docker build -t uw-pdf - < Dockerfile
# docker-compose build --force-rm
make baseContainer
make mainContainer
make pushBaseImage
make pushMainImage
```

### Show running containers
```bash
docker container ls
```

### Show all containers, running or not
```bash
docker container ls -a
```

### Run the Docker container, opening shell
```bash
docker run --name uw-pdf --rm -p 8080:80 -i -t uw-pdf bash
exit
```

### Run the Docker container in background and execute commands
```bash
docker pull unfoldingWord/uw-pdf:latest
docker run --name uw-pdf --rm -p 8080:80 -dit --cpus=0.5 unfoldingWord/uw-pdf:latest
docker run --name uw-pdf -p 8080:80 -dit --cpus=0.5 --restart unless-stopped unfoldingWord/uw-pdf:latest

# simple commands
docker exec uw-pdf pwd

# chained or piped commands
docker exec uw-pdf sh -c "echo 'hello' > hello.txt"

# copy a file
docker cp uw-pdf:/opt/hello.txt ~/Desktop/hello.txt

# stop the container
docker stop uw-pdf
```

### Remove a container and its image
```bash
docker rm -v 840cbddced04
docker rmi uw-pdf
```

### Remove all containers and images
```bash
# Delete all containers
docker rm $(docker ps -a -q)

# Delete all images
docker rmi $(docker images -q)
```
