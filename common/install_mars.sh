#!/bin/bash
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


# Installs MARS client from ECMWF repositories

set -eux

MARS_REPO="$1"

curl -o stable-public.gpg.key "${MARS_REPO}/private-raw-repos-config/debian/buster/stable/public.gpg.key"
echo "deb ${MARS_REPO}/private-debian-buster-stable/ buster main" >> /etc/apt/sources.list
apt-key add stable-public.gpg.key
apt-get update
apt install -y libnetcdf13 liblapack3
apt install -y mars-client-cpp=0.0.3.0