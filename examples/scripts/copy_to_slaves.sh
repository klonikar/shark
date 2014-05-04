#!/bin/sh
# copies a file to all slave hosts named in slaves file
S_HOME=$SPARK_HOME
if [ -z "$S_HOME" ]; then
    S_HOME=${HOME}/spark-0.8.0
fi

echo Copying files from $S_HOME to slaves

SLAVES_FILE="${S_HOME}/conf/slaves";

for i in `cat $SLAVES_FILE`
do
  if [[ $i == '#'* ]]
  then
    echo "skipping $i";
    continue;
  fi

  echo "copying $1 to: $i"
  scp -r $1 $i:$HOME/$1
done
