# magnolia-docker

A Docker file, Maven POM and Ant file to create, push and tag a Docker container for a Magnolia webapp bundle.

## Useful links
- you need a basic understanding about how to push/pull/link Docker containers
- [Official Docker documentation](https://docs.docker.com/)
- [Docker cheat sheet](http://xdxd.love/2015/12/23/docker-cheat-sheet/)

## Prerequisites
- download and install the Docker toolbox from `https://www.docker.com/products/docker-toolbox`
- you need a Docker repository in the [Docker hub](https://hub.docker.com) to push your Docker images
- further, you need in your Docker host: 
   - a [Postgres 9.4 Docker container](https://docs.docker.com/engine/examples/postgresql_service/)
   - shell scripts to create the Postgres databases for use with my [magnolia-postgres-bundle](https://github.com/tweckert/magnolia-postgres-bundle) can be found [here](https://github.com/tweckert/magnolia-vagrant/tree/master/vagrant-data/postgresql)
   - a [Docker volume](https://docs.docker.com/engine/tutorials/dockervolumes/) for the Magnolia repositories (stuff that Magnolia stores in the file system)
   - a Docker volume for the Postgres databases 

## Get or build a Magnolia webapp bundle
- download a pre-configured [Magnolia webapp bundle](https://documentation.magnolia-cms.com/display/DOCS/Bundles+and+webapps)
- or build a customized Magnolia webapp bundle. e.g. use the bundle in my [magnolia-postgres-bundle git repo](https://github.com/tweckert/magnolia-postgres-bundle) as a starter
   - this bundle is based on Magnolia's minimal `empty-webapp` bundle and uses Postgres 9.4, so you need to [add further Magnolia modules](https://documentation.magnolia-cms.com/display/DOCS/Creating+a+custom+bundle) as needed
   
## Creating Docker volumes
- run `docker volume create --name mgnl_repositories` to create a Docker volume for the Magnolia repositories
- run `docker volume create --name postgres_data` to create a Docker volume for the Postgres databases

## Building the Magnolia Docker container
- the Docker container is built and pushed by a Maven POM
- you need a Magnolia webapp bundle
   - adjust the path and `.war` file name in the Maven POM in the `distribution.file.srcDir`and `distribution.file.name' variables
   - adjust the the `.war` file name in line 14 in `src\main\docker\Dockerfile`
- adjust the name of your Docker repo in the Maven POM in the `docker.hub.repository` variable
- run `mvn clean pre-integration-test`  to build the Docker container
- optional parameters: 
   - `-DpushDockerHub -Ddocker.hub.user.name=YOUR_DOCKER_HUB_USERNAME -Ddocker.hub.user.password=YOUR_DOCKER_HUB_PASSWORD` to push the Docker image into the Docker hub
   - `-DtagDockerImage -Ddocker.container.tag.additional=ADDITIONAL_TAG` to set an additional tag on the Docker image, e.g. `staging` to trigger a deployment once the image is pushed in case you have a Jenkins Docker slave configured
   - `-DpushAdditionalTagDockerHub` to push the additional tag into the Docker hub
   
## Tagging the Magnolia Docker container
- setting a tag on a Docker image may trigger a Jenkins slave
- `build.xml` contains Ant tasks to pull a Docker image, add a tag, and push the image back into the Docker hub
- adjust the name of your Docker repo in the `docker.hub.repository` variable in `build.xml`
- run `ant -Ddocker.hub.user.name=YOUR_DOCKER_HUB_USERNAME -Ddocker.hub.user.password=YOUR_DOCKER_HUB_PASSWORD -Ddocker.container.tag=EXISTING_TAG -Ddocker.container.tag.additional=ADDITIONAL_TAG` to add an additonal tag to an existing Docker image

## Running the Postgres Docker container
- run `docker run -it --link postgres:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U YOUR_POSTGRES_USER`

## Running the Magnolia Docker container
- NB: the Magnolia and Postgres Docker containers need to be [linked](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/)
- run `docker run -h dockerhost -v mgnl_repositories -e AUTHOR=true -e PUBLIC=true -e HEAP_SIZE=6g -p 8080:8080 --name mgnl --link postgres:postgres -d YOUR_DOCKER_REPO:YOUR_DOCKER_CONTAINER_VERSION`