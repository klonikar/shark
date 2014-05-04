#!/usr/bin/env bash

# Copyright (C) 2012 The Regents of The University California.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# (Required) Amount of memory used per slave node. This should be in the same
# format as the JVM's -Xmx option, e.g. 300m or 1g.
export SPARK_MEM=8g

# (Required) Set the master program's memory
export SHARK_MASTER_MEM=1g

# (Required) Point to your Scala installation.
export SCALA_HOME="$HOME/scala-2.9.3"

# (Required) Point to the patched Hive binary distribution
export HIVE_HOME="$HOME/shark-0.8.0-bin-cdh4/hive-0.9.0-shark-0.8.0-bin"

# (Optional) Specify the location of Hive's configuration directory. By default,
# it points to $HIVE_HOME/conf
export HIVE_CONF_DIR="$HIVE_HOME/conf"

# For running Shark in distributed mode, set the following:
export HADOOP_HOME="/usr/lib/hadoop"
export SPARK_HOME="$HOME/spark-0.8.0"
export MASTER="spark://localhost:7077"
# Only required if using Mesos:
#export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so 

# (Optional) Extra shared library path: Useful if you use JNI
#export SPARK_LIBRARY_PATH="/usr/lib/:"
#export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"

# Java options
# On EC2, change the local.dir to /mnt/tmp
SPARK_JAVA_OPTS="-Dspark.local.dir=/tmp "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
#SPARK_JAVA_OPTS+="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "

export SPARK_JAVA_OPTS
source $SPARK_HOME/conf/spark-env.sh
