# Docker Swarm Deployment

Docker Swarm can be used to deploy the full polytope stack, including multiple parallel workers and frontends. As with a Kubernetes deployment, the services are containerised, and you have to build the Docker images before deploying. The build is performed with docker-compose.

## Prerequisites

* Docker ≥ 18.x
* docker-compose
* Python ≥ 3.7
* `pip install hiyapyco pykwalify`
* `docker login <registry>`
* docker in swarm mode (`docker swarm init`)

## Configure

```
cd ./docker
configure.py -f /path/to/config.yaml -f more_config
```

The `configure.py` tool takes any number of polytope configuration files which will be merged, the same way the native services do. In addition, you can supply configuration specific to this deployment by adding items under the `deployment` key in the configuration. To see what you can customise, look at the default configuration in `./docker/default.yaml`.

`configure.py` will generate `docker-compose.yaml` and `config.yaml` used in the next step.

## Deploy

```
docker-compose build
docker stack deploy polytope -c docker-compose.yaml
```

Here are some handy commands for managing the stack:

```
docker stack services polytope
docker service logs polytope_worker
./whereis.sh
```

## Setting up HTTPs

In order for HTTPs to be served, an ingress has to be deployed. In docker deployments, an ingress can be deployed automatically by populating the `deployment: ingress:` section in Polytope's configuration file.

A DNS name for the Polytope service and a certificate associated to that name have to be obtained and configured in the ingress. For docker deployments, both the DNS name and certificates can be provided in the Polytope configuration file, under `deployment: public_endpoint_dns_name:` and `deployment: ingress: https:`, respectively.

See more information on these deployment configuration parameters in `schema.md`.
