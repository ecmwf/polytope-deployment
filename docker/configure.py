#! /usr/bin/env python3
#
# Copyright 2022 European Centre for Medium-Range Weather Forecasts (ECMWF)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.
#


import os

from jinja2 import Template
from polytope_server.common.config import ConfigParser

# Read and merge config
parser = ConfigParser()
config = parser.read(additional_yaml=["./default.yaml"])


# Write merged config

with open("./config.yaml", "w") as out_file:
    out_file.write(parser.dump())

# Read SSH keys
prv_file = config["deployment"]["build"]["git_ssh_keys"]["private"] or "~/.ssh/id_rsa"
pub_file = config["deployment"]["build"]["git_ssh_keys"]["public"] or "~/.ssh/id_rsa.pub"
with open(os.path.expanduser(prv_file)) as f:
    ssh_private = f.read()
with open(os.path.expanduser(pub_file)) as f:
    ssh_public = f.read()

# Render docker-compose.yaml configuration file with Jinja

with open("./docker-compose.yaml.in", "r") as in_file:
    template = Template(in_file.read(), trim_blocks=True, lstrip_blocks=True)

rendered = template.render(config=config, ssh_private=ssh_private, ssh_public=ssh_public)

with open("./docker-compose.yaml", "w") as out_file:
    out_file.write(rendered)


# Render polytope-nginx.conf configuration file with Jinja

with open("./polytope-nginx.conf.in", "r") as in_file:
    template = Template(in_file.read(), trim_blocks=True, lstrip_blocks=True)

rendered = template.render(config=config, ssh_private=ssh_private, ssh_public=ssh_public)

with open("./polytope-nginx.conf", "w") as out_file:
    out_file.write(rendered)
