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
from shutil import copyfile

from jinja2 import Template
from polytope_server.common.config import ConfigParser

# Read and merge config

parser = ConfigParser()
config = parser.read(additional_yaml=["./default.yaml"])

# Create the working directory

work_dir = config["deployment"]["working_directory"]
os.makedirs(work_dir, exist_ok=True)
os.makedirs(os.path.join(work_dir, "fdb"), exist_ok=True)
os.makedirs(os.path.join(work_dir, "fdb", "data"), exist_ok=True)
os.makedirs(os.path.join(work_dir, "logs"), exist_ok=True)

# Copy default fdb config into workdir

os.makedirs(os.path.join(work_dir, "config"), exist_ok=True)
os.makedirs(os.path.join(work_dir, "config", "fdb"), exist_ok=True)
copyfile("../common/default_fdb_schema", os.path.join(work_dir, "config", "fdb", "default"))

# Write merged config

with open(os.path.join(work_dir, "./config.yaml"), "w") as out_file:
    out_file.write(parser.dump())

# Render supervisord.conf configuration file with Jinja

with open("./supervisord.conf.in", "r") as in_file:
    template = Template(in_file.read(), trim_blocks=True, lstrip_blocks=True)

rendered = template.render(config=config, temp_dir=os.path.abspath("./temp"))

with open("./supervisord.conf", "w") as out_file:
    out_file.write(rendered)
