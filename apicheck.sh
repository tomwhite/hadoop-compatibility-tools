#!/bin/bash

# A script for running SigTest (http://sigtest.java.net/) against different
# versions of Hadoop projects to generate an API compatibility report.

#set -x

PRG="${0}"
while [ -h "${PRG}" ]; do
  ls=`ls -ld "${PRG}"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "${PRG}"`/"$link"
  fi
done
BASEDIR=`dirname ${PRG}`
BASEDIR=`pwd ${BASEDIR}`

for i in $*
do
  case $i in
  --project=*)
    PROJECT=${i#*=}
    ;;
  --package=*)
    PACKAGE=${i#*=}
    ;;
  --baseline-version=*)
    BASELINE_VERSION=${i#*=}
    ;;
  --baseline-tar=*)
    BASELINE_TAR=${i#*=}
    ;;
  --baseline-dir=*)
    BASELINE_DIR=${i#*=}
    ;;
  --baseline-classpath-includes=*)
    BASELINE_CLASSPATH_INCLUDES=${i#*=}
    ;;
  --baseline-classpath-excludes=*)
    BASELINE_CLASSPATH_EXCLUDES=${i#*=}
    ;;
  --new-version=*)
    NEW_VERSION=${i#*=}
    ;;
  --new-tar=*)
    NEW_TAR=${i#*=}
    ;;
  --new-dir=*)
    NEW_DIR=${i#*=}
    ;;
  --new-classpath-includes=*)
    NEW_CLASSPATH_INCLUDES=${i#*=}
    ;;
  --new-classpath-excludes=*)
    NEW_CLASSPATH_EXCLUDES=${i#*=}
    ;;
  --generate-excludes)
    GENERATE_EXCLUDES=true
    ;;
  --excluded-annotations=*)
    EXCLUDED_ANNOTATIONS=${i#*=}
    ;;
  --excludes-file=*)
    EXCLUDES_FILE=${i#*=}
    ;;
  --hadoop-annotation-tools-jar=*)
    HADOOP_ANNOTATION_TOOLS_JAR=${i#*=}
    ;;
  --java-tools-classpath=*)
    JAVA_TOOLS_CLASSPATH=${i#*=}
    ;;
  --work-dir=*)
    WORK_DIR=${i#*=}
    ;;
  --output-dir=*)
    OUTPUT_DIR=${i#*=}
    ;;
  *)
    # unknown option
    ;;
  esac
done

OUTPUT_DIR=${OUTPUT_DIR:-$BASEDIR/output}
WORK_DIR=${WORK_DIR:-$BASEDIR/work}
BASELINE_DIR=$WORK_DIR/${BASELINE_DIR-$(basename $(basename $BASELINE_TAR) .tar.gz)}
NEW_DIR=$WORK_DIR/${NEW_DIR-$(basename $(basename $NEW_TAR) .tar.gz)}

mkdir -p $OUTPUT_DIR
mkdir -p $WORK_DIR

if [ ! -d $BASELINE_DIR ]; then
  cd $WORK_DIR
  curl -L -O $BASELINE_TAR
  tar zxf $(basename $BASELINE_TAR)
  cd -
fi

if [ ! -d $NEW_DIR ]; then
  cd $WORK_DIR
  curl -L -O $NEW_TAR
  tar zxf $(basename $NEW_TAR)
  cd -
fi

if [ ! -d $WORK_DIR/sigtest-2.2 ]; then
  cd $WORK_DIR
  curl -O http://download.java.net/sigtest/2.2/Rel/sigtest-2_2-MR-bin-b17-21_mar_2011.zip
  unzip sigtest-2_2-MR-bin-b17-21_mar_2011.zip
  cd -
fi

function generate_excludes() {
  if $GENERATE_EXCLUDES ; then
    # Generate exclusions by analysing classfiles
    java -cp "$HADOOP_ANNOTATION_TOOLS_JAR" name.tomwhite.hat.GenerateSigTestExcludes $1 $EXCLUDED_ANNOTATIONS > $WORK_DIR/generated_excludes
  else
    touch $WORK_DIR/generated_excludes
  fi
  EXCLUDES=$(cat $EXCLUDES_FILE $WORK_DIR/generated_excludes | awk '{print "-Exclude " $1}' | tr '\n' ' ')	
}

# Setup

if [ -z $BASELINE_CLASSPATH_EXCLUDES ]; then
  BASELINE_LIB_CLASSPATH=$(eval ls -d $BASELINE_DIR/$BASELINE_CLASSPATH_INCLUDES | tr '\n' ':')
else
  BASELINE_LIB_CLASSPATH=$(comm -3 <(eval ls -d $BASELINE_DIR/$BASELINE_CLASSPATH_INCLUDES) <(eval ls -d $BASELINE_DIR/$BASELINE_CLASSPATH_EXCLUDES) | tr '\n' ':')
fi
generate_excludes $BASELINE_LIB_CLASSPATH

java -cp $WORK_DIR/sigtest-2.2/lib/sigtestdev.jar \
  com.sun.tdk.signaturetest.Setup \
  -Classpath $JAVA_TOOLS_CLASSPATH:$BASELINE_LIB_CLASSPATH \
  -FileName $OUTPUT_DIR/$PROJECT-$BASELINE_VERSION.sig \
  -Package $PACKAGE \
  -ApiVersion $BASELINE_VERSION \
  -Static \
  -nonclosedfile \
  -KeepFile \
  $EXCLUDES

# API check
if [ -z $BASELINE_CLASSPATH_EXCLUDES ]; then
  NEW_LIB_CLASSPATH=$(eval ls -d $NEW_DIR/$NEW_CLASSPATH_INCLUDES | tr '\n' ':')
else
  NEW_LIB_CLASSPATH=$(comm -3 <(eval ls -d $NEW_DIR/$NEW_CLASSPATH_INCLUDES) <(eval ls -d $NEW_DIR/$NEW_CLASSPATH_EXCLUDES) | tr '\n' ':')
fi
generate_excludes $NEW_LIB_CLASSPATH

java -cp $WORK_DIR/sigtest-2.2/lib/apicheck.jar \
  com.sun.tdk.apicheck.Main \
  -Classpath $JAVA_TOOLS_CLASSPATH:$NEW_LIB_CLASSPATH \
  -FileName $OUTPUT_DIR/$PROJECT-$BASELINE_VERSION.sig \
  -Package $PACKAGE \
  -ApiVersion $NEW_VERSION \
  -Static \
  -Mode bin \
  -Backward \
  $EXCLUDES \
  -Out $OUTPUT_DIR/apicheck-$PROJECT-$BASELINE_VERSION-$NEW_VERSION.txt
