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


#######################################################
#                     C O M M O N
#                 based on alpine linux
#######################################################

FROM registry.hub.docker.com/library/python:3.8-alpine3.11 AS polytope-common
ARG proxy=

# Set the proxy
ENV http_proxy=$proxy
ENV https_proxy=$proxy
ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy

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

# Unset the proxy
ENV http_proxy=
ENV https_proxy=
ENV HTTP_PROXY=
ENV HTTPS_PROXY=

#######################################################
#                    W O R K E R
#               based on debian buster
#######################################################

FROM python:3.8-buster AS worker
ARG proxy
ARG ssh_prv_key
ARG ssh_pub_key
ARG install_mars
ARG install_fdb
ARG mars_repo
ARG mars_config_repo
ARG mars_config_branch
ARG fdb_repo

# Set the proxy
ENV http_proxy=$proxy
ENV https_proxy=$proxy
ENV HTTP_PROXY=$proxy
ENV HTTPS_PROXY=$proxy

RUN set -eux \
    && addgroup --system polytope --gid 474 \
    && adduser --system polytope --ingroup polytope \
    && mkdir /polytope && chmod -R o+rw /polytope

RUN apt update
RUN apt install -y curl nano sudo

# Add polytope user to passwordless sudo group during build
RUN usermod -aG sudo polytope
RUN echo "%sudo  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


WORKDIR /polytope
USER polytope


############## M A R S ##############
# Install MARS from ECMWF repositories (only for ECMWF)

COPY --chown=polytope polytope-deployment/common/install_mars.sh ./install_mars.sh
COPY --chown=polytope polytope-deployment/common/mars-wrapper.py /polytope/bin/mars-wrapper.py 
COPY --chown=polytope polytope-deployment/common/mars-wrapper-docker.py /polytope/bin/mars-wrapper-docker.py

RUN set -ex \
	&& if [ $(echo "$install_mars" | tr '[:upper:]' '[:lower:]') = "true" ]; then sudo -E ./install_mars.sh "$mars_repo"; fi

ENV MARS_CONFIGS_REPO=${mars_config_repo}
ENV MARS_CONFIGS_BRANCH=${mars_config_branch}
ENV PATH="/polytope/bin/:/opt/ecmwf/mars-client/bin:/opt/ecmwf/mars-client-cloud/bin:${PATH}"

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

############## F D B ##############
# Install FDB from OpenSource repositories

COPY --chown=polytope polytope-deployment/common/install_fdb.sh ./install_fdb.sh
COPY --chown=polytope polytope-deployment/common/default_fdb_schema /polytope/config/fdb/default

RUN set -ex \
	&& if [ $(echo "$install_fdb" | tr '[:upper:]' '[:lower:]') = "true" ]; then sudo -E ./install_fdb.sh; fi

RUN mkdir -p /polytope/fdb/ && sudo chmod -R o+rw /polytope/fdb

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/fdb/lib

# PyFDB not yet open source
RUN set -eux \
    && git clone --single-branch --branch develop "$fdb_repo" \
    && cd pyfdb && git checkout 3de8c3854b199a462ef5a4ae60dd5e23cb3bfefd && cd .. \
    && python -m pip install ./pyfdb


############## P O L Y T O P E ##############
# Install Polytope from source

COPY --chown=polytope ./polytope-server/ /polytope/
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade .

# RUN chmod -R o+rx /usr/local/bin \

# Unset the proxy
ENV http_proxy=
ENV https_proxy=
ENV HTTP_PROXY=
ENV HTTPS_PROXY=

RUN set -eux \
    && mkdir /home/polytope/data

# Remove itself from sudo group
RUN sudo deluser polytope sudo
