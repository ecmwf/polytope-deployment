.. _deployment:

Deployment
==========

To deploy a Polytope server, you can do it either manually, or using one of the deployment frameworks supported by `polytope-deployment <https://github.com/ecmwf-projects/polytope-deployment>`_.

Deploying with polytope-deployment
----------------------------------

`polytope-deployment <https://github.com/ecmwf-projects/polytope-deployment>`_ contains sample deployment environments for the Polytope server. You can always deploy Polytope manually, on an ad-hoc basis, by just launching the services (e.g. `python -m polytope_server.frontend`), but the resources in this repository help streamline the process.

`polytope-deployment` has frameworks for deploying locally using supervisord, on Kubernetes, or on Docker Swarm. You can add deployment configuration to the same configuration file as you use to configure polytope-server (under *deployment*), and the deployment frameworks will intelligently use this merged configuration to create the whole service. 

For more details about these deployment frameworks look in ``polytope-deployment/<framework>``. There is a readme which describes the pre-requisites and deployment strategy and a ``default.yaml`` configuration which shows you the baseline configuration that you can use to customise the deployment.

Each framework contains a ``configure.py`` script which will read the service and deployment configuration and prepare the environment.

Deploying ad-hoc
-----------------

If deploying polytope-server manually, you need to have:

* Python >= 3.7
* jinja2 and polytope-server python modules
* mongodb and rabbitmq running at a reachable network location
* a datasource to connect the server to, `FDB <https://github.com/ecmwf/fdb/>`_ for example, and the relevant clients installed for those datasources

You then need to put together a Polytope configuration file (see :ref:`server_configuration`).

Finally you can run each of the microservices with e.g. ``python -m polytope_server.frontend``. This is not too different to the local deployment in *polytope-deployment*.

