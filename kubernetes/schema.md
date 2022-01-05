# Polytope Kubernetes deployment configuration documentation

This reference includes documentation for some of the parameters that can be specified in the Polytope configuration file for Kubernetes deployments using polytope-deployment.

```
deployment:
  public_endpoint_dns_name:
```

This variable takes the public DNS name which resolves to the public-access server accepting connections to Polytope, if any. 

The public-access server may be at any of the Kubernetes cluster nodes, where the nginx controller is exposed via a NodePort. In that case, the node's name or any DNS name resolving to that host's IP has to be specified as public_endpoint_dns_name. The specified name will be used as server_name in the nginx controller, and Polytope will be accessible via public_endpoint_dns_name:(deployment:ingress:port). Terminating HTTPS is not supported for now in this setup. An ingress-less setup is not supported for now.

The public-access server may otherwise be a load-balancer or reverse-proxy which optionally terminates https and forwards to the Kubernetes' ingress controller as http, with the Host header set to the public server DNS name (which is used by the ingress controller as server_name, hence only connections with that Host header will be forwarded to Polytope). This setup allows to have a single common server which exposes and off-loads https termination for a set of web applications hosted locally, using a single floating IP and TLS certificate for all of them (although the certificate will have to include all webapp names as subject alternative names, and these names will have to be registered in a public DNS server at least as aliases).

If a shared load-balancer setup is desired in a way that the Kubernetes' ingress has its own DNS name associated (either in the local network or publicly accessible) but the load-balancer still exposes Polytope to the Internet with its separate DNS name, then the public_endpoint_dns_name has to be set with the Kubernetes' ingress host DNS name (which will be used by the ingress controller as server_name), and the load-balancer has to forward http[s] connections (which originally have the DNS name assocated to the load-balancer as Host) towards the ingress controller (with the Host header set to the Kubernetes' ingress host DNS name). In this setup, Polytope can be seen as an independent service which is published to the local network following the first approach (public-access server is at one of the Kubernetes cluster nodes where nginx is exposed), and the load-balancer simply exposes it in a non-intrusive way.

A shared load-balancer setup without having a Kubernetes ingress involved is not supported for now. However the ingress can be bypassed by replicating the rules that have been programmed in the Polytope's Kubernetes ingress in the load-balancer. This includes multiplexing incoming connections to frontend or staging appropriately, as well as rewriting returned Location URLs to replace http by https if the load-balancer is accepting HTTPs connections. Note that bypassing the Polytope's Kubernetes ingress prevents in any case having HTTPs connections between the load-balancer and Polytope, downgrading security.

```
deployment:
  ingress:
    https_rewrite:
```

If set to true, a rule will be put in place in Polytope's ingress to rewrite all returned Locations from http to https. This has to be set to true whenever https connections are expected between clients and the public-access server accepting connections to Polytope (see deployment:public_endpoint_dns_name). In other words, set to true if a load-balancer external to the Kubernetes cluster is exposing Polytope and terminating https.
