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



# Installs FDB from open-source repositories, including dependencies

set -eux

apt install -y cmake gnupg build-essential libtinfo5 net-tools libnetcdf13 libnetcdf-dev bison flex

root=$(pwd)

rm -rf source
rm -rf build

mkdir -p source
mkdir -p build
mkdir -p /opt/fdb/

# Download ecbuild
git clone -c advice.detachedHead=false --depth 1 --branch 2021.03.0 https://github.com/ecmwf/ecbuild.git ./source/ecbuild
ecbuild=$root/source/ecbuild/bin/ecbuild

# Install eckit

git clone -c advice.detachedHead=false --depth 1 --branch 2021.03.0 https://github.com/ecmwf/eckit.git ./source/eckit
mkdir -p $root/build/eckit
cd $root/build/eckit
$ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH=/opt/fdb $root/source/eckit
make -j4
make install
cd $root

# Install eccodes 

git clone -c advice.detachedHead=false --depth 1 --branch 2.21.0 https://github.com/ecmwf/eccodes.git ./source/eccodes
mkdir -p $root/build/eccodes
cd $root/build/eccodes
$ecbuild --prefix=/opt/fdb -DENABLE_FORTRAN=OFF -- -DCMAKE_PREFIX_PATH=/opt/fdb $root/source/eccodes
make -j4
make install
cd $root

# Install metkit 

git clone -c advice.detachedHead=false --depth 1 --branch 2021.03.0 https://github.com/ecmwf/metkit.git ./source/metkit
mkdir -p $root/build/metkit
cd $root/build/metkit
$ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH=/opt/fdb $root/source/metkit
make -j4
make install
cd $root


# Install fdb 

git clone -c advice.detachedHead=false --depth 1 --branch 2021.08.0 https://github.com/ecmwf/fdb.git ./source/fdb
mkdir -p $root/build/fdb
cd $root/build/fdb
$ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH="/opt/fdb;/opt/fdb/eckit;/opt/fdb/metkit" $root/source/fdb
make -j4
make install
cd $root

rm -rf source
rm -rf build
