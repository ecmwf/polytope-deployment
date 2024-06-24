# Local Deployment

A local deployment is very helpful for development. However, this deployment does not scale beyond 1 process per service (e.g. 1 frontend, 1 worker, etc.). It uses Supervisor to manage the services.

## Prerequisites
  * Python ≥3.7
  * `pip install supervisor jinja2`
  * `pip install [-e] /path/to/polytope/source`
  * mongodb and rabbitmq installed
    * or already running (set hostname/port in polytope config)
  * mars client
  * fdb

## Configure                                                                                                         

```                                                                                                               cd ./local
configure.py -f /path/to/config.yaml -f more_config
```

The `configure.py` tool takes any number of polytope configuration files which will be merged, the same way the native services do. In addition, you can supply configuration specific to this deployment by adding items under the `deployment` key in the configuration. To see what you can customise, look at the default configuration in `./local/default.yaml`. For example, you can choose not to deploy rabbitmq and mongodb if you already have those services running elsewhere.                                                             
`configure.py` will generate `supervisord.confl` and `config.yaml` used in the next step.                                             
## Deploy                                                                                                                             
```
supervisord
supervisorctl reload
supervisorctl start all
supervisorctl status
```                                                                                                                                   
Here are some example commands for managing the processes:                                                                            
```                                                                                                               supervisorctl tail worker 
supervisorctl restart frontend
supervisorctl fg broker
```                                                                                                                                   
You can re-run `configure.py` and then `supervisorctl reload` to update the deployment.
