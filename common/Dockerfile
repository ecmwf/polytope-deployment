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

ARG fdb_base=blank-base
ARG mars_base_c=blank-base
ARG mars_base_cpp=blank-base
ARG gribjump_base=blank-base

#######################################################
#                     C O M M O N
#                 based on alpine linux
#######################################################

FROM python:3.10-alpine AS polytope-common

RUN apk add --no-cache --virtual .build-deps gcc musl-dev openldap openldap-dev curl

RUN set -eux \
    && addgroup --system polytope --gid 474 \
    && adduser --system polytope --ingroup polytope \
    && mkdir -p /polytope && chmod -R 777 /polytope \
    && mkdir -p /data && chmod -R 777 /data

COPY ./polytope-server/requirements.txt /polytope/
WORKDIR /polytope
RUN python -m pip install -r requirements.txt
COPY ./polytope-server/ /polytope/
RUN python -m pip install --upgrade .

#######################################################
#                N O O P   I M A G E
#######################################################
FROM python:3.10-buster AS blank-base
# create blank directories to copy from in the final stage, optional dependencies aren't built
RUN set -eux \
    && mkdir -p /root/.local \
    && mkdir -p /opt/ecmwf/mars-client \
    && mkdir -p /opt/ecmwf/mars-client-cpp \
    && mkdir -p /opt/ecmwf/mars-client-cloud \
    && mkdir -p /opt/fdb \
    && mkdir -p /opt/fdb-gribjump \
    && touch /usr/local/bin/mars

#######################################################
#                  F D B   B U I L D
#######################################################
FROM python:3.10-buster AS fdb-base
RUN apt update
# COPY polytope-deployment/common/default_fdb_schema /polytope/config/fdb/default

# Install FDB from open source repositories
RUN set -eux && \
    apt install -y cmake gnupg build-essential libtinfo5 net-tools libnetcdf13 libnetcdf-dev bison flex && \
    rm -rf source && \
    rm -rf build && \
    mkdir -p source && \
    mkdir -p build && \
    mkdir -p /opt/fdb/

# Download ecbuild
RUN set -eux && \
    git clone --depth 1 --branch 3.8.2 https://github.com/ecmwf/ecbuild.git /ecbuild

ENV PATH=/ecbuild/bin:$PATH

# Install eckit
RUN set -eux && \
    git clone --depth 1 --branch develop https://github.com/ecmwf/eckit.git /source/eckit && \
    cd /source/eckit && git checkout develop && \
    mkdir -p /build/eckit && \
    cd /build/eckit && \
    ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH=/opt/fdb /source/eckit && \
    make -j4 && \
    make install

# Install eccodes
RUN set -eux && \
    git clone --depth 1 --branch 2.33.1 https://github.com/ecmwf/eccodes.git /source/eccodes && \
    mkdir -p /build/eccodes && \
    cd /build/eccodes && \
    ecbuild --prefix=/opt/fdb -DENABLE_FORTRAN=OFF -- -DCMAKE_PREFIX_PATH=/opt/fdb /source/eccodes && \
    make -j4 && \
    make install

# Install metkit
RUN set -eux && \
    git clone --depth 1 --branch develop https://github.com/ecmwf/metkit.git /source/metkit && \
    cd /source/metkit && git checkout develop && \
    mkdir -p /build/metkit && \
    cd /build/metkit && \
    ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH=/opt/fdb /source/metkit && \
    make -j4 && \
    make install

# Install fdb \
RUN set -eux && \
    git clone --depth 1 --branch develop https://github.com/ecmwf/fdb.git /source/fdb && \
    cd /source/fdb && git checkout develop && \
    mkdir -p /build/fdb && \
    cd /build/fdb && \
    ecbuild --prefix=/opt/fdb -- -DCMAKE_PREFIX_PATH="/opt/fdb;/opt/fdb/eckit;/opt/fdb/metkit" /source/fdb && \
    make -j4 && \
    make install

RUN set -eux && \
    rm -rf /source && \ 
    rm -rf /build 

ARG ssh_prv_key
ARG ssh_pub_key

# Install pyfdb \
RUN set -eux \
    && git clone --single-branch --branch 0.0.3 https://github.com/ecmwf/pyfdb.git \
    && python -m pip install ./pyfdb --user

#######################################################
#             G R I B  J U M P   B U I L D
#######################################################

FROM fdb-base AS gribjump-base

ARG ssh_prv_key
ARG ssh_pub_key

# gribjump not open source yet, clone it.
RUN set -eux \
    # Configure SSH for private repository access
    && mkdir -p /root/.ssh \
    && echo "$ssh_prv_key" > /root/.ssh/id_rsa \
    && echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub \
    && chmod 600 /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa.pub \
    && echo "StrictHostKeyChecking=no" > /root/.ssh/config \
    && git clone --single-branch --branch develop ssh://git@github.com/ecmwf/gribjump.git \
    && rm -rf /root/.ssh


# Install fdb from local source (need a private version from internal ECMWF repository)
COPY fdb5 /source/fdb
RUN set -eux && \
    mkdir -p build \
    mkdir -p source \
    mkdir -p /build/fdb && \
    cd /build/fdb && \
    ecbuild --prefix=/opt/fdb-gribjump -- -DCMAKE_PREFIX_PATH="/opt/fdb;/opt/fdb/eckit;/opt/fdb/metkit" /source/fdb && \
    make -j4 && \
    make install && \
    rm -rf /build && \
    rm -rf /source

RUN set -eux && \
    mkdir -p /source/libaec && \
    curl -L https://gitlab.dkrz.de/k202009/libaec/uploads/3847727cd2e8c941f0d68f6822a73ed7/libaec-1.1.2.tar.gz| tar -xz -C /source/libaec --strip-components=1 && \
    cd /source/libaec && \
    mkdir -p ./build && \
    cd ./build && \
    ../configure --prefix=/opt/fdb-gribjump/libaec  && \
    make -j4 && \
    make install

# Install gribjump \
RUN set -eux && \
    mkdir -p build \
    mkdir -p /build/gribjump && \
    cd /build/gribjump && \
    ecbuild --prefix=/opt/fdb-gribjump -- -DCMAKE_PREFIX_PATH="/opt/fdb-gribjump;/opt/fdb-gribjump/libaec;/opt/fdb;/opt/fdb/eckit;/opt/fdb/metkit" /gribjump && \
    make -j4 && \
    make install && \
    rm -rf /build

# Install pygribjump
RUN set -eux \
    && cd /gribjump \
    && python -m pip install . --user \
    && rm -rf /gribjump

#######################################################
#             F D B   R E M O T E   B U I L D
#######################################################

FROM fdb-base AS fdb-remote-base

ARG ssh_prv_key
ARG ssh_pub_key

# gribjump not open source yet, clone it.
COPY fdbremote /source/fdbremote
# Install fdb from local source (need a private version from internal ECMWF repository)
RUN apt-get install -y gfortran
RUN set -eux \
    # Configure SSH for private repository access
    && mkdir -p /root/.ssh \
    && echo "$ssh_prv_key" > /root/.ssh/id_rsa \
    && echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub \
    && chmod 600 /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa.pub \
    && echo "StrictHostKeyChecking=no" > /root/.ssh/config \
    && mkdir -p build \
    && mkdir -p source \
    && mkdir -p /build/fdb \
    && cd /build/fdb \
    && ecbuild --prefix=/opt/fdbremote -- /source/fdbremote \
    && make -j4 \
    && make install \
    && rm -rf /build \
    && rm -rf /source \
    && rm -rf /root/.ssh

#######################################################
#               M A R S    B A S E
#######################################################
FROM python:3.10-buster AS mars-base
ARG mars_repo
ARG mars_client_cpp_version

RUN response=$(curl -s -w "%{http_code}" ${mars_repo}) \
    && if [ "$response" = "403" ]; then echo "Unauthorized access to ${mars_repo} "; fi

RUN set -eux \
    && curl -o stable-public.gpg.key "${mars_repo}/private-raw-repos-config/debian/buster/stable/public.gpg.key" \
    && echo "deb ${mars_repo}/private-debian-buster-stable/ buster main" >> /etc/apt/sources.list \
    && apt-key add stable-public.gpg.key \
    && apt-get update \
    && apt install -y libnetcdf13 liblapack3

FROM mars-base as mars-base-c
RUN apt install -y liblapack3 mars-client mars-client-cloud

FROM mars-base as mars-base-cpp
RUN apt update && apt install -y mars-client-cpp=${mars_client_cpp_version}
RUN set -eux \
    && python3 -m pip install git+https://github.com/ecmwf/pyfdb.git@master --user

FROM blank-base AS blank-base-c
FROM blank-base AS blank-base-cpp

#######################################################
#         S W I T C H   B A S E    I M A G E S
#######################################################

FROM ${fdb_base} AS fdb-base-final

FROM ${mars_base_c} AS mars-c-base-final

FROM ${mars_base_cpp} AS mars-cpp-base-final

FROM ${gribjump_base} AS gribjump-base-final


#######################################################
#           P Y T H O N   R E Q U I R E M E N T S
#######################################################
FROM python:3.10-slim-buster AS worker-base

# contains compilers for building wheels which we don't want in the final image
RUN apt update
RUN apt-get install -y --no-install-recommends gcc libc6-dev make gnupg2
COPY ./polytope-server/requirements.txt /requirements.txt
RUN python -m pip install -r requirements.txt --user
RUN python -m pip install geopandas --user

# polytope feature extraction (from source)
COPY --chown=polytope ./polytope /polytope-fe
RUN python -m pip install /polytope-fe --user

#covjsonkit (from source)
COPY --chown=polytope ./covjsonkit /covjsonkit
RUN python -m pip install /covjsonkit --user

# polytope-mars source
COPY --chown=polytope ./polytope-mars/ /polytope-mars
RUN python -m pip install /polytope-mars --user

#######################################################
#                    W O R K E R
#               based on debian buster
#######################################################

FROM python:3.10-slim-buster AS worker

ARG mars_config_branch
ARG mars_config_repo
ARG ssh_prv_key
ARG ssh_pub_key
ARG mars_repo


RUN set -eux \
    && addgroup --system polytope --gid 474 \
    && adduser --system polytope --ingroup polytope \
    && mkdir /polytope && chmod -R o+rw /polytope

RUN apt update
RUN apt install -y curl nano sudo ssh libgomp1 vim

# Add polytope user to passwordless sudo group during build
RUN usermod -aG sudo polytope
RUN echo "%sudo  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /polytope
USER polytope


# Copy MARS-related artifacts
COPY --chown=polytope /polytope-deployment/common/mars-wrapper.py  /polytope/bin/mars-wrapper.py 
COPY --chown=polytope /polytope-deployment/common/mars-wrapper-docker.py  /polytope/bin/mars-wrapper-docker.py

COPY --chown=polytope --from=mars-cpp-base-final   /opt/ecmwf/mars-client-cpp  /opt/ecmwf/mars-client-cpp
COPY --chown=polytope --from=mars-cpp-base-final    /root/.local /home/polytope/.local
COPY --chown=polytope --from=mars-c-base-final     /opt/ecmwf/mars-client      /opt/ecmwf/mars-client
COPY --chown=polytope --from=mars-c-base-final     /usr/local/bin/mars      /usr/local/bin/mars
RUN sudo apt update
RUN sudo apt install -y libgomp1 git libnetcdf13 liblapack3 libfftw3-3


# all of this is needed by the C client, would be nice to remove it at some point
RUN set -eux \
    && mkdir -p /home/polytope/.ssh \
    && chmod 0700 /home/polytope/.ssh \
    && ssh-keyscan git.ecmwf.int > /home/polytope/.ssh/known_hosts \
    && echo "$ssh_prv_key" > /home/polytope/.ssh/id_rsa \
    && echo "$ssh_pub_key" > /home/polytope/.ssh/id_rsa.pub \
    && chmod 600 /home/polytope/.ssh/id_rsa \
    && chmod 600 /home/polytope/.ssh/id_rsa.pub \
    && chmod 755 /polytope/bin/mars-wrapper.py \
    && chmod 755 /polytope/bin/mars-wrapper-docker.py

ENV MARS_CONFIGS_REPO=${mars_config_repo}
ENV MARS_CONFIGS_BRANCH=${mars_config_branch}
ENV PATH="/polytope/bin/:/opt/ecmwf/mars-client/bin:/opt/ecmwf/mars-client-cloud/bin:${PATH}"

# Copy FDB-related artifacts
COPY --chown=polytope --from=fdb-base-final /opt/fdb/ /opt/fdb/
COPY --chown=polytope polytope-deployment/common/default_fdb_schema /polytope/config/fdb/default
RUN mkdir -p /polytope/fdb/ && sudo chmod -R o+rw /polytope/fdb
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/fdb/lib
COPY --chown=polytope --from=fdb-base-final /root/.local /home/polytope/.local

# COPY --chown=polytope --from=fdb-remote-base /opt/fdbremote/ /opt/fdbremote/

# Copy gribjump-related artifacts, including python libraries
COPY --chown=polytope --from=gribjump-base-final /opt/fdb/ /opt/fdb/
COPY --chown=polytope --from=gribjump-base-final /opt/fdb-gribjump/ /opt/fdb-gribjump/
COPY --chown=polytope --from=gribjump-base-final /root/.local /home/polytope/.local
RUN sudo apt install -y libopenjp2-7
COPY polytope-deployment/common/default_fdb_schema /polytope/config/fdb/default

# Copy python requirements
COPY --chown=polytope --from=worker-base /root/.local /home/polytope/.local

# Install the server source
COPY --chown=polytope ./polytope-server/ /polytope/

RUN set -eux \
    && mkdir /home/polytope/data

# Remove itself from sudo group
RUN sudo deluser polytope sudo