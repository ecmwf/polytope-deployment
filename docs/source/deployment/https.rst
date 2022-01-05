.. _https:

Enabling HTTPs
==============

When exposing *polytope-server* to external users connecting via the internet, HTTPs should be enabled. In order for HTTPs to be served, an ingress has to be deployed.

If deploying *polytope-server* ad-hoc or using the local deployment in *polytope-deployment*, an nginx ingress (or equivalent) can be deployed and configured to expose the frontend endpoint in the deployment host/platform with HTTPs.

In docker deployments, an ingress can be deployed by populating the ``deployment > ingress`` section in Polytope's configuration file, whereas in Kubernetes deployments an ingress is always deployed.

A DNS name for the Polytope service and a certificate associated to that name have to be obtained and configured in the ingress. For docker deployments, both the DNS name and certificates can be provided in the Polytope configuration file, under ``deployment > public_endpoint_dns_name`` and ``deployment > ingress > ingress``, respectively. For kubernetes deployments, the certificates need to be set manually in the ingress backend running on the cluster, and the DNS name can be configured automatically under ``deployment > public_endpoint_dns_name`` in the Polytope's configuration file, and an ingress rule will be put in place automatically.