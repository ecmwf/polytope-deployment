##
## Copyright 2022 European Centre for Medium-Range Weather Forecasts (ECMWF)
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## In applying this licence, ECMWF does not waive the privileges and immunities
## granted to it by virtue of its status as an intergovernmental organisation nor
## does it submit to any jurisdiction.
##


nodeport=`kubectl get svc frontend -o=jsonpath='{.spec.ports[?(@.port==32002)].nodePort}'`
stagingnodeport=`kubectl get svc staging -o=jsonpath='{.spec.ports[?(@.port==9000)].nodePort}'`
ingress=`kubectl get ingress polytope-ingress -o=jsonpath='{.spec.rules[0].host}'`
master=`kubectl get nodes | grep master | awk '{print $1}'`
echo "Service is reachable at "$master":"$nodeport
echo "Service is reachable at "$ingress":80"
echo "Staging is reachable at  "$master":"$stagingnodeport

echo "curl "$master":"$nodeport"/api/v1/test"
echo ">>>" `curl -s $master:$port/api/v1/test`