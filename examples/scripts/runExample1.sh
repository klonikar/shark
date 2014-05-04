#!/bin/sh
SC_VERSION=$SCALA_VERSION
if [ -z "$SC_VERSION" ]; then
    SC_VERSION=2.9.3
fi
SP_VERSION=$SPARK_VERSION
if [ -z "$SP_VERSION" ]; then
    SP_VERSION=0.8.0
fi
SH_VERSION=$SHARK_VERSION
if [ -z "$SH_VERSION" ]; then
    SH_VERSION=0.8.0
fi
H_VERSION=$HIVE_VERSION
if [ -z "$H_VERSION" ]; then
    H_VERSION=0.9.0
fi

export SCALA_VERSION=$SC_VERSION
export SPARK_VERSION=$SP_VERSION
export SHARK_VERSION=$SH_VERSION
export HIVE_VERSION=$H_VERSION

SP_HOME=$SPARK_HOME
if [ -z "$SP_HOME" ]; then
    SP_HOME=${HOME}/spark-$SPARK_VERSION
fi
SH_HOME=$SHARK_HOME
if [ -z "$SH_HOME" ]; then
    SH_HOME=${HOME}/shark-$SHARK_VERSION-bin-cdh4
fi
SC_HOME=$SCALA_HOME
if [ -z "$SC_HOME" ]; then
    SC_HOME=${HOME}/scala-$SCALA_VERSION
fi
H_HOME=$HIVE_HOME
if [ -z "$H_HOME" ]; then
    H_HOME=$SH_HOME/hive-${HIVE_VERSION}-shark-${SHARK_VERSION}-bin
fi

export SCALA_HOME=$SC_HOME
export SPARK_HOME=$SP_HOME
export SHARK_HOME=$SH_HOME
export HIVE_HOME=$H_HOME

SPARK_CLASSPATH=$SHARK_HOME/shark-${SHARK_VERSION}/target/scala-${SCALA_VERSION}/shark_${SCALA_VERSION}-${SHARK_VERSION}.jar:$SPARK_HOME/core/target/spark-core_${SCALA_VERSION}-${SPARK_VERSION}-incubating.jar:$SCALA_HOME/lib/scala-library.jar:$SHARK_HOME/shark-${SHARK_VERSION}/lib/JavaEWAH-0.4.2.jar

export ADD_JARS=$SHARK_HOME/shark-${SHARK_VERSION}/target/scala-${SCALA_VERSION}/shark_${SCALA_VERSION}-${SHARK_VERSION}.jar

for jar in `find $SHARK_HOME/shark-${SHARK_VERSION}/lib -name '*jar'`; do
  SPARK_CLASSPATH+=:$jar
done
for jar in `find $SHARK_HOME/shark-${SHARK_VERSION}/lib_managed/jars -name '*jar'`; do
  SPARK_CLASSPATH+=:$jar
done
for jar in `find $SHARK_HOME/shark-${SHARK_VERSION}/lib_managed/bundles -name '*jar'`; do
  SPARK_CLASSPATH+=:$jar
done
for jar in `find $HIVE_HOME/lib -name '*jar'`; do
  # Ignore the logging library since it has already been included with the Spark jar.
  if [[ "$jar" != *slf4j* ]]; then
    SPARK_CLASSPATH+=:$jar
  fi
done

# Compile and build jar
rm -f shark/example/java/Example1*.class
javac -d . -cp "$SPARK_CLASSPATH:$HIVE_HOME/lib/hive-metastore-${HIVE_VERSION}-shark-${SHARK_VERSION}.jar" ../java/Example1.java
#export CLASSPATH=$SPARK_CLASSPATH:$HIVE_HOME/lib/hive-metastore-${HIVE_VERSION}-shark-${SHARK_VERSION}.jar
#javac -d . ../java/Example1.java
rm -f shark_example.jar
jar cvf shark_example.jar shark/example/java/Example1*.class
# copy jar to slaves. For some reason, it is not happening through spark.
./copy_to_slaves.sh shark_example.jar

SPARK_CLASSPATH+=:$HOME/shark_example.jar

export SPARK_MEM=8g
export SPARK_WORKER_CORES=8

# (Required) Set the master program's memory
export SHARK_MASTER_MEM=1g

export SPARK_LIBRARY_PATH="-Djava.library.path="

SPARK_JAVA_OPTS="-Dspark.local.dir=/tmp "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
SPARK_JAVA_OPTS+="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "

JAVA_OPTS="$SPARK_JAVA_OPTS"
JAVA_OPTS+=" -Djava.library.path=$SPARK_LIBRARY_PATH"
JAVA_OPTS+=" -Xms$SHARK_MASTER_MEM -Xmx$SHARK_MASTER_MEM"
export JAVA_OPTS

# Important. Without this, you will need to call sc.addJar for many jars
export SPARK_CLASSPATH

export CLASSPATH+=$SPARK_CLASSPATH # Needed for spark-shell
java -cp "$SPARK_CLASSPATH" "$JAVA_OPTS" shark.example.java.Example1
