# Kubernetes Deployment

Kubernetes can be used to deploy the full polytope stack, including multiple parallel workers and frontends. The main difference to a local deployment is that the services are containerised, and you have to build the Docker images for these containers before deploying. Skaffold orchestrates the building of all the Docker images, which are then deployed with Helm.

## Prerequisites

* Python ≥ 3.7
* `pip install hiyapyco pykwalify`
* `pip install -e /path/to/polytope/source`
* Docker ≥ 18.x
* Helm ≥ 3.0.2
* Skaffold ≥ 1.13.2
* kubectl configured to point to a Kubernetes cluster
* `docker login <registry>`
* `helm dependency build`

## Configure

```
cd ./kubernetes
configure.py -f /path/to/config.yaml -f more_config
```

The `configure.py` tool takes any number of polytope configuration files which will be merged, the same way the native services do. In addition, you can supply configuration specific to this deployment by adding items under the `deployment` key in the configuration. To see what you can customise, look at the default configuration in `./kubernetes/default.yaml`.

`configure.py` will generate `values.yaml` and `skaffold.yaml` used in the next step.

## Deploy

Skaffold orchestrates the building of all the docker images. These are then deployed with Helm.

### Generate polytope-registry-cred secret
For this step you need a file that looks like this:
```json
{
	"auths": {
		"eccr.ecmwf.int": {
			"auth": "base64 of username:password"
		}
	}
}
``` in principle your `~/.docker/config.json` should look like this, but since it often won't, the easiest thing is to just create a dummy one yourself. The command to run to generate the value for the auth key is:
```sh
echo -n 'username:password' | base64
```
The single quotes and -n argument to echo are important to prevent echo trying to quote the string and to suppress the automatic newline. Paste the result into the file above and use that in place of "${HOME}/.docker/config.json" in the create secret command below.

### Build

```sh
skaffold build
kubectl create secret generic polytope-registry-cred \
    --from-file=.dockerconfigjson=${HOME}/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson 2>&1
helm install polytope .
```

Here are some handy commands for managing the deployment:

```
kubectl get pods
kubectl logs worker-<hash>
kubectl get svc
./whereis.sh
helm ls
helm rollback polytope <revision>
```

You can re-run `configure.py` for configuration changes, or rebuild the images with `skaffold build` if you change the polytope code. You can redeploy with `helm upgrade --reset-values polytope .`.

You can also use Helm via Skaffold, and use some of its extra features -- especially `skaffold dev` which can be quite nice for development.

The helpful `./whereis.sh` script will quickly tell you how to reach your deployed polytope server.


# Setting up HTTPs

In order for HTTPs to be served, an ingress has to be deployed. In Kubernetes deployments an ingress is always deployed.

A DNS name for the Polytope service and a certificate associated to that name have to be obtained and configured in the ingress. For kubernetes deployments, the certificates need to be set manually in the ingress backend running on the cluster, and the DNS name can be configured automatically under `deployment: public_endpoint_dns_name:` in the Polytope's configuration file, and an ingress rule will be put in place automatically.

Depending on the specific deployment setup, the `deployment: ingress: https_rewrite:` configuration flag will need to be enabled.

See more information on these deployment configuration parameters in `schema.md`.
