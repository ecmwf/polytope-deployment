# polytope-deployment

This repository contains sample deployment environments for the Polytope server. You can always deploy Polytope manually, on an ad-hoc basis, by just launching the services (e.g. `python -m polytope_server.frontend`), but the resources in this repository help streamline the process.

:warning: This project is BETA and will be experimental for the forseable future. Interfaces and functionality are likely to change, and the project itself may be scrapped. DO NOT use this software in any project/software that is operational.

We provide the following deployment types:

* locally, under a single host
* using Kubernetes
* using Docker Swarm

You can either use these deployments directly, since they are designed to be somewhat configurable, or use them as examples to create your own deployment.

See the readme files under local, docker and kubernetes folder for an explanation of their pros/cons and deployment steps to follow.


## Enabling HTTPs

When exposing polytope-server to external users connecting via the internet, HTTPs should be enabled. In order for HTTPs to be served, an ingress has to be deployed.

If deploying polytope-server ad-hoc or using the local deployment in polytope-deployment, an nginx ingress (or equivalent) can be deployed separately and configured to expose the frontend endpoint in the deployment host/platform with HTTPs.

In docker deployments, an ingress can be deployed automatically by populating the `deployment: ingress` section in Polytope's configuration file, whereas in Kubernetes deployments an ingress is always deployed.

A DNS name for the Polytope service and a certificate associated to that name have to be obtained and configured in the ingress.

Check the respective deployment readmes for more information.
