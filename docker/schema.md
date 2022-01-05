# Polytope Docker deployment configuration documentation

This reference includes documentation for some of the parameters that can be specified in the Polytope configuration file for Docker deployments using polytope-deployment.

```
deployment:
  public_endpoint_dns_name:
```

This variable can be set with the public DNS name which resolves to the host of the public-access server accepting connections to Polytope, if any. 

The public-access server may be either the nginx reverse-proxy (ingress) deployed as part of Polytope at the same host where the rest of Polytope is deployed, or a load-balancer/reverse-proxy running in the same host as Polytope or in another host. 

In both cases, Polytope will be publicly accessible if the host's IP is public and the port the server listens to is exposed, and addressable with public_endpoint_dns_name if configured accordingly in the public DNS.

If the public-access server is Polytope's ingress and a public_endpoint_dns_name is provided, that DNS name will be used as server_name in the nginx controller (only HTTP(s) connections with that name as Host will be forwarded to Polytope). If configuring the ingress to terminate https (see deployment:ingress:https), providing a public_endpoint_dns_name is mandatory and it will have to be used as subject name for the TLS certificate to be provided in deployment:ingress:https:cert_chain. If the ingress doesn't terminate https and a public_endpoint_dns_name is not provided, the ingress controller won't have a server_name (any connections to the host IP and deployment:ingress:port will be forwarded to Polytope). A Polytope docker deployment without an nginx ingress is not supported for now.

If the public-access server is a separate load-balancer or reverse-proxy, it can optionally be adjusted to terminate https, and it must forward to the Polytope ingress as http or https (according to deployment:ingress:https), with the Host header set to the public server DNS name (which is used by Polytope's ingress as server_name, hence only connections with that Host header will be forwarded to Polytope). This setup allows to have a single common server which exposes and off-loads https termination for a set of web applications hosted locally, using a single floating IP and TLS certificate for all of them (although the certificate will have to include all webapp names as subject alternative names, and these names will have to be registered in a public DNS server at least as aliases).

If a shared load-balancer setup is desired in a way that the Polytope host (and in consequence the ingress) has its own DNS name associated (and resolvable either in the local network or publicly) but the load-balancer still exposes Polytope to the Internet with its own separate DNS name, then the public_endpoint_dns_name has to be set with the Polytope host DNS name (which will be used by Polytope's ingress as server_name), and the load-balancer has to forward http[s] connections (which originally have the DNS name assocated to the load-balancer as Host) towards the Polytope ingress with the Host header set to the Polytope host DNS name. In this setup, Polytope can be seen as an independent service which is published to the local network following the first approach (public-access server is at the same host where Polytope is deployed with an ingress), and the load-balancer simply exposes it in a non-intrusive way.

If a shared load-balancer setup is desired without having an ingress deployed as part of Polytope, the rules that have been programmed in the Polytope's ingress have to be replicated in the load-balancer for proper functioning of the service. This includes multiplexing incoming connections to frontend or staging appropriately, as well as rewriting returned Location URLs to replace http by https if the load-balancer is accepting HTTPs connections. Note that removing the Polytope's ingress prevents in any case having HTTPs connections between the load-balancer and Polytope, downgrading security.

```
deployment:
  ingress:
    port:
```

Port where to expose Polytope's nginx ingress in the deployment host. Should generally be set to 80 if deployment:ingress:https is not present or 443 otherwise, but any port is supported for either http or https.

```
deployment:
  ingress:
    https_rewrite:
```

If set to true, a rule will be put in place in Polytope's ingress to rewrite all returned Locations from http to https. This has to be set to true whenever https connections are expected between clients and the public-access server accepting connections to Polytope (see deployment:public_endpoint_dns_name). In other words, set to true if a load-balancer is exposing Polytope and terminating https, or if no load-balancer exposes it but ingress:https is present.

```
deployment:
  ingress:
    https:
```

If this configuration item is present the ingress will be expecting and terminating https connections at port deployment:ingress:port. Having this item in the configuration does not necessarily imply that https_rewrite has to be enabled as well (i.e. there might be a public-access server exposing Polytope which doesn't accept https, even though the connection between that server and Polytope's ingress happens in https). If this item is present, the sub-items private_key and cert_chain have to be specified.

```
deployment:
  ingress:
    https:
      cert_chain:
```
